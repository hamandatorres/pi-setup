#Safer Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias home='cd ~'

#Safer File Operations
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

#Useful Listing
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

#System Updates
alias update='sudo apt update && sudo apt upgrade'
alias install='sudo apt install'
alias remove='sudo apt remove'

#Clear the Screen
alias cls='clear'

#Quick Shutdown/Reboot
alias reboot='sudo reboot'
alias shutdown='sudo shutdown now'

#Disk Usage
alias df='df -h'
alias du='du -h'
alias duh='du -h --max-depth=1'

#Networking
alias ports='netstat -tulanp'
alias myip='hostname -I'

#Raspberry Pi Specific
alias rpi-update='sudo rpi-update'
alias rpi-config='sudo raspi-config'
alias vcgencmd='vcgencmd'

#Raspberry Pi-Specific Qol
alias temp='vcgencmd measure_temp'
alias volt='vcgencmd measure_volts'
alias freq='vcgencmd measure_clock arm'
alias rpi-status='vcgencmd get_config int'


alias top='htop'
alias dusage='ncdu'

alias tmux="tmux -f ~/.config/tmux/tmux.conf"
