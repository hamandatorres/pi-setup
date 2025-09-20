# HTTP to HTTPS redirect
server {
    listen 80;
    listen [::]:80;
    server_name chavezperez.com www.chavezperez.com;
    return 301 https://$server_name$request_uri;
}

# HTTPS configuration
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name chavezperez.com www.chavezperez.com;
    
    root /var/www/chavezperez.com/public_html;
    index index.php index.html index.htm;
    
    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/chavezperez.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/chavezperez.com/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
    
    # Security headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header Referrer-Policy "strict-origin-when-cross-origin";
    
    # Logging
    access_log /var/www/chavezperez.com/logs/access.log;
    error_log /var/www/chavezperez.com/logs/error.log;
    
    # Main location
    location / {
        try_files $uri $uri.html $uri/ =404;
    }
    
    # Webhook endpoint (restricted to GitHub)
    location = /webhook.php {
        allow 140.82.112.0/20;
        deny all;
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
    }
    
    # PHP handling
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
    
    # Node.js app proxy
    location /nodeapp/ {
        proxy_pass http://localhost:3000/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
    
    # .NET app proxy
    location /dotnet/ {
        proxy_pass http://localhost:5000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Security: deny access to sensitive files
    location ~ /\. {
        deny all;
    }
    
    location ~ ^/(README|CHANGELOG|composer\.(json|lock))$ {
        deny all;
    }
    
    # Custom error pages
    error_page 404 /404.html;
    location = /404.html {
        root /var/www/chavezperez.com/public_html;
        internal;
    }
}
