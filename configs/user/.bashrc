# ~/.bashrc: executed by bash(1) for non-login shells.
# Modular Bash Configuration for Carlos
# Last updated: $(date +%Y-%m-%d)

# ============================================================================
# EARLY EXIT & BASIC CHECKS
# ============================================================================

# If not running interactively, don't do anything


# Set the base configuration directory
BASH_CONFIG_DIR="$HOME/.config/bash"

# Create config directory if it doesn't exist
if [ ! -d "$BASH_CONFIG_DIR" ]; then
    mkdir -p "$BASH_CONFIG_DIR"
fi

# ============================================================================
# MODULE LOADING FUNCTION
# ============================================================================

# Function to safely load bash modules
load_bash_module() {
    local module="$1"
    local module_file="$BASH_CONFIG_DIR/${module}.bash"
    
    if [ -f "$module_file" ]; then
        source "$module_file"
    else
        echo "Warning: Bash module '$module' not found at $module_file" >&2
    fi
}

# Function to conditionally load modules
load_if_exists() {
    local module="$1"
    local module_file="$BASH_CONFIG_DIR/${module}.bash"
    
    if [ -f "$module_file" ]; then
        source "$module_file"
    fi
}

# ============================================================================
# LOAD CORE MODULES (in order of dependency)
# ============================================================================

# 1. Environment variables and exports
load_bash_module "environment"

# 2. Shell options and behavior
load_bash_module "options"

# 3. History configuration  
load_bash_module "history"

# 4. PATH modifications
load_bash_module "path"

# 5. Prompt configuration (before external tools)
load_bash_module "prompt"

# 6. Color support and themes
load_bash_module "colors"

# 7. Aliases (loads both system and user aliases)
load_bash_module "aliases"

# 8. Functions
load_bash_module "functions"

# 9. Completions
load_bash_module "completions"

# ============================================================================
# LOAD OPTIONAL MODULES
# ============================================================================

# External tools integration
load_if_exists "tools-starship" 
load_if_exists "tools-fzf"
load_if_exists "tools-zoxide"
load_if_exists "tools-thefuck"
load_if_exists "tools-direnv"

# Development environments
load_if_exists "dev-python"
load_if_exists "dev-node"
load_if_exists "dev-docker"
load_if_exists "dev-git"

# Platform-specific modules
load_if_exists "platform-raspberry-pi"
load_if_exists "platform-wsl"

# Work/project-specific configurations
load_if_exists "work"
load_if_exists "projects"

# ============================================================================
# LOCAL CUSTOMIZATIONS
# ============================================================================

# Load machine-specific configurations
load_if_exists "local"

# Legacy support - load old .bash_aliases if it exists and no new aliases module
if [ -f ~/.bash_aliases ] && [ ! -f "$BASH_CONFIG_DIR/aliases.bash" ]; then
    source ~/.bash_aliases
fi

# Load any additional local bashrc
if [ -f ~/.bashrc.local ]; then
    source ~/.bashrc.local
fi

# ============================================================================
# POST-LOAD TASKS
# ============================================================================

# Clean up temporary variables
unset BASH_CONFIG_DIR

# Display welcome message (optional)
if [ -f "$HOME/.config/bash/welcome.bash" ]; then
    source "$HOME/.config/bash/welcome.bash"
fi

# Enable programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
