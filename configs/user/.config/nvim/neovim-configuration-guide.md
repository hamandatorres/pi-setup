# Neovim Configuration Features Guide

A comprehensive overview of your enhanced Neovim setup with all plugins, features, and keybindings.

## 🚀 Core Configuration

### Essential Vim Settings
- **Line Numbers**: Both absolute and relative line numbers enabled
- **Indentation**: 4-space tabs with smart indenting
- **Search**: Case-insensitive search with smart case matching
- **Undo**: Persistent undo history stored in `~/.vim/undodir`
- **Visual**: Cursor line highlighting, color columns at 80 and 120 characters
- **Clipboard**: System clipboard integration (`clipboard=unnamedplus`)
- **Scrolling**: 8 lines of context when scrolling
- **Splits**: Open splits below and to the right by default

### Visual Enhancements
- **Whitespace Visualization**: See tabs, trailing spaces, and line endings
- **Custom Fill Characters**: Clean borders and fold indicators
- **Color Support**: Full 24-bit color support
- **Status**: Always show status line and tab line

## 🎨 Theme & Appearance

### Catppuccin Color Scheme
- **Flavor**: Mocha (dark theme)
- **Features**: 
  - Italic comments and conditionals
  - Integrated with all plugins
  - Customizable background transparency
  - Support for both light and dark variants

## 📁 File Management

### NvimTree File Explorer
- **Toggle**: `<leader>e` - Toggle file tree
- **Focus**: `<leader>o` - Focus on file tree
- **Features**:
  - Git status indicators (✓ staged, ✗ unstaged, ★ untracked)
  - Diagnostics integration (H/I/W/E for hint/info/warning/error)
  - Automatic file watcher for live updates
  - Window picker for opening files
  - Relative line numbers in tree view

### Buffer Management (BufferLine)
- **Navigation**: 
  - `Shift+H` - Previous buffer
  - `Shift+L` - Next buffer
  - `<leader>bp` - Pin buffer
  - `<leader>bP` - Delete non-pinned buffers
- **Features**:
  - Visual buffer tabs
  - Close buttons and modified indicators
  - LSP diagnostics in buffer line
  - File Explorer offset

## 🔍 Search & Navigation

### Telescope Fuzzy Finder
- **File Operations**:
  - `<leader>ff` - Find files
  - `<leader>fr` - Recent files
  - `<leader>fb` - Find buffers
- **Content Search**:
  - `<leader>fg` - Live grep (search in files)
  - `<leader>fs` - Grep string under cursor
- **System Navigation**:
  - `<leader>fh` - Help tags
  - `<leader>fc` - Commands
  - `<leader>fk` - Keymaps
  - `<leader>fd` - Diagnostics
  - `<leader>ft` - Treesitter symbols

### Enhanced Features
- **Layout**: Horizontal layout with top prompt
- **Preview**: File previews with syntax highlighting
- **Fuzzy Matching**: Native FZF integration for fast searching

## 💼 Project Management

### Project.nvim Integration
- **Project Switching**: `<leader>fp` - Find and switch projects
- **Auto Detection**: Automatically detects projects by:
  - Git repositories
  - Solution files (`.sln`, `.csproj`)
  - Package files (`package.json`)
  - Build files (`Makefile`)
- **Features**:
  - Automatic directory changing
  - Project-specific settings
  - Integration with Telescope

### Session Management (Persistence)
- **Load Session**: `<leader>qs` - Load current directory session
- **Load Last**: `<leader>ql` - Load last session
- **Stop Saving**: `<leader>qd` - Don't save current session
- **Auto-save**: Automatically saves session on exit

## 💻 Terminal Integration

### ToggleTerm
- **Quick Toggle**: `Ctrl+\` - Toggle floating terminal
- **Layouts**:
  - `<leader>th` - Horizontal terminal (bottom)
  - `<leader>tv` - Vertical terminal (side)
- **Terminal Navigation**:
  - `Esc` or `jk` - Exit terminal mode
  - `Ctrl+h/j/k/l` - Navigate between windows from terminal

## 🛠️ Language Support

### Language Server Protocol (LSP)
- **Servers**: Automatically installs and configures:
  - OmniSharp for C#
  - Lua Language Server for Lua
- **Navigation**:
  - `gd` - Go to definition
  - `gD` - Go to declaration
  - `gi` - Go to implementation
  - `gr` - Go to references
  - `K` - Show hover information
- **Actions**:
  - `<leader>rn` - Rename symbol
  - `<leader>ca` - Code actions
  - `<leader>f` - Format document
  - `Ctrl+k` - Signature help

### Mason Package Manager
- **Auto-install**: Automatically installs LSP servers
- **Management**: Easy installation and updates of language tools

### Treesitter Syntax Highlighting
- **Languages**: C#, Lua, Vim, JSON, YAML, Markdown, Bash
- **Features**:
  - Advanced syntax highlighting
  - Intelligent indentation
  - Code folding
  - Text objects

## ✍️ Editing & Completion

### Intelligent Completion (nvim-cmp)
- **Sources**: LSP, snippets, buffer text, file paths
- **Navigation**:
  - `Tab` - Next completion item or expand snippet
  - `Shift+Tab` - Previous completion item
  - `Ctrl+Space` - Trigger completion
  - `Enter` - Accept completion
- **Scrolling**: `Ctrl+b/f` - Scroll documentation

### Snippet Engine (LuaSnip)
- **Expansion**: Automatic snippet expansion
- **Navigation**: Jump between snippet placeholders
- **Integration**: Works seamlessly with completion

### Text Objects & Motions
- **Surround**: Add, delete, and change surrounding characters
  - `ys{motion}{char}` - Add surround
  - `ds{char}` - Delete surround  
  - `cs{old}{new}` - Change surround
- **Auto-pairs**: Automatic bracket and quote pairing

## 🐛 Debugging Support

### DAP (Debug Adapter Protocol)
- **Controls**:
  - `F5` - Continue/Start debugging
  - `F10` - Step over
  - `F11` - Step into  
  - `F12` - Step out
  - `<leader>b` - Toggle breakpoint
- **UI**: Automatic DAP UI opening/closing during debug sessions

## 🎯 Git Integration

### GitSigns
- **Indicators**: Shows git changes in sign column
  - `+` - Added lines
  - `~` - Changed lines  
  - `_` - Deleted lines
- **Features**: Real-time git status updates

## 📝 Visual Aids

### Indent Guides (indent-blankline)
- **Visual**: Shows indentation levels with vertical lines
- **Smart**: Excludes special file types
- **Customizable**: Uses `│` character for clean appearance

### Comment Plugin
- **Toggle**: Easy comment/uncomment functionality
- **Smart**: Language-aware commenting
- **Visual**: Works with visual selections

### Which-Key Helper
- **Discovery**: Shows available keybindings as you type
- **Timeout**: 300ms delay before showing options
- **Categories**: Organized by prefix keys

## ⌨️ Keybinding Categories

### Leader Key Mappings (`<Space>` as leader)

#### File Operations (f)
- `ff` - Find files
- `fg` - Live grep
- `fb` - Find buffers
- `fh` - Help tags
- `fr` - Recent files
- `fc` - Commands
- `fk` - Keymaps
- `fs` - Grep string
- `fd` - Diagnostics
- `ft` - Treesitter
- `fp` - Find projects

#### Buffer Management (b)
- `bd` - Delete buffer
- `bn` - Next buffer
- `bp` - Previous buffer
- `bp` - Pin buffer (BufferLine)
- `bP` - Delete non-pinned buffers

#### Window Management (w)
- `wv` - Split vertically
- `wh` - Split horizontally
- `we` - Equalize splits
- `wx` - Close split

#### Tab Management (t)
- `to` - Open new tab
- `tx` - Close tab
- `tn` - Next tab
- `tp` - Previous tab
- `tf` - Open current file in new tab
- `th` - Horizontal terminal
- `tv` - Vertical terminal

#### Session Management (q)
- `qs` - Load session
- `ql` - Load last session
- `qd` - Don't save session

#### Code Actions (c)
- `ca` - Code actions
- `rn` - Rename symbol

#### Utilities
- `e` - Toggle file tree
- `o` - Focus file tree
- `h` - Clear search highlights
- `s` - Replace word under cursor
- `f` - Format document
- `y` - Copy to system clipboard
- `d` - Delete to void register

### Navigation Shortcuts
- `Ctrl+d/u` - Half page down/up (centered)
- `n/N` - Next/previous search result (centered)
- `Ctrl+k/j` - Next/previous quickfix item
- `Shift+H/L` - Previous/next buffer

### Window Resizing
- `Ctrl+Arrow Keys` - Resize current window
- `Ctrl+h/j/k/l` - Navigate between windows

## 🔧 Workflow Enhancements

### Automatic Features
- **Trailing Whitespace**: Automatically removed on save
- **Yank Highlighting**: Visual feedback when copying text
- **Last Position**: Returns to last edit position when reopening files
- **Smart Indenting**: Maintains proper indentation

### Text Manipulation
- **Line Movement**: Move selected lines up/down with `J/K` in visual mode
- **Join Lines**: `J` joins lines while preserving cursor position
- **Better Indenting**: `</>`> in visual mode maintains selection

## 📚 File Type Support

### Comprehensive Language Support
- **C#**: Full LSP support with OmniSharp
- **Lua**: Complete development environment
- **Web**: JSON, YAML support
- **Documentation**: Markdown support
- **Shell**: Bash script support
- **Config**: Vim configuration files

## 🎛️ Customization Options

### Easy Modifications
- **Theme**: Change Catppuccin flavor in color scheme config
- **Keybindings**: All mappings clearly documented and modifiable
- **LSP**: Add more language servers through Mason
- **Plugins**: Modular plugin system with Lazy.nvim

### Performance
- **Lazy Loading**: Plugins load only when needed
- **Fast Startup**: Optimized configuration for quick startup times
- **Efficient**: Memory-conscious plugin selection

## 🚀 Getting Started

### First Steps
1. Save configuration as `~/.config/nvim/init.lua`
2. Start Neovim - plugins will auto-install
3. Run `:checkhealth` to verify setup
4. Use `<Space>` + wait to see available commands

### Learning Tips
- Use Which-Key (`<Space>` then wait) to discover features
- Start with basic file navigation (`<leader>ff`)
- Try the terminal integration (`Ctrl+\`)
- Explore LSP features with C# or Lua files

This configuration provides a complete, modern development environment that grows with your needs while maintaining excellent performance and usability.
