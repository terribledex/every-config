# 🐚 Zsh Configuration & Minimal Git Theme

A clean, efficient zsh setup with Oh My Zsh, custom minimal theme, and productivity-focused aliases and plugins.

## ✨ Features

- **🎨 Custom Minimal Theme**: Clean git-focused prompt with time display
- **⚡ Performance Optimized**: Fast startup with essential plugins only
- **🧠 Smart History**: Enhanced command history with deduplication
- **🔍 Modern Tools Integration**: fzf, eza, thefuck, and more
- **🎯 Git-Centric Workflow**: Git status in prompt + useful aliases
- **🛠️ Developer-Friendly**: Neovim, Kiro, and development tools support

## 🚀 Quick Start

### Prerequisites

```bash
# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install required tools (macOS with Homebrew)
brew install eza fzf thefuck neovim
brew install zsh-autosuggestions zsh-syntax-highlighting
```

### Installation

1. **Copy configuration files**:
   ```bash
   cp .zshrc ~/.zshrc
   cp .zsh-theme ~/.oh-my-zsh/themes/minimal-git.zsh-theme
   ```

2. **Install fzf integration**:
   ```bash
   $(brew --prefix)/opt/fzf/install
   ```

3. **Reload shell**:
   ```bash
   source ~/.zshrc
   # or restart terminal
   ```

## 🎨 Theme Preview

The minimal-git theme provides a clean, informative prompt:

```
╭∩╮(Ο_Ο)╭∩╮ git:(main)*+?                                    [14:30:25]
```

### Prompt Elements

**Left Side:**
- `╭∩╮(Ο_Ο)╭∩╮` - Unique character prompt
- `git:(branch)` - Current git branch in blue/red
- Git status indicators:
  - `*` (red) - Modified files
  - `+` (green) - Staged files  
  - `?` (yellow) - Untracked files

**Right Side:**
- `[HH:MM:SS]` - Current time in gray

## 🔌 Included Plugins

### Core Oh My Zsh Plugins
- **git**: Git aliases and functions
- **zsh-autosuggestions**: Fish-like autosuggestions
- **zsh-syntax-highlighting**: Command syntax highlighting

### External Integrations
- **fzf**: Fuzzy finder for files and history
- **thefuck**: Command correction tool
- **eza**: Modern replacement for ls
- **Kiro**: IDE shell integration

## ⚡ Aliases & Commands

### File Operations
| Alias | Command | Description |
|-------|---------|-------------|
| `als` | `eza -alh` | Enhanced ls with details |
| `tree` | `eza --tree` | Directory tree view |
| `ll` | `ls -plah1` | Detailed file listing |
| `cls` | `clear && printf "\e[3J"` | Clear screen completely |

### Git Workflow
| Alias | Command | Description |
|-------|---------|-------------|
| `gs` | `git status` | Git status |
| `ga` | `git add .` | Stage all changes |
| `gc` | `git commit -m` | Commit with message |
| `gp` | `git push` | Push to remote |

### System Maintenance
| Alias | Command | Description |
|-------|---------|-------------|
| `update` | `brew update && brew upgrade && omz update` | Update everything |
| `reload` | `source ~/.zshrc` | Reload zsh config |
| `tping` | `ping -c 100 8.8.8.8` | Test internet connection |

## 🧠 History Configuration

Enhanced command history with smart features:

```bash
HISTFILE=~/.zsh_history
HISTSIZE=10000           # Commands in memory
SAVEHIST=10000          # Commands saved to file
setopt hist_ignore_dups # Ignore duplicate commands
setopt share_history    # Share history between sessions
```

## 🎯 Environment Variables

### Essential Paths
```bash
export PATH="/opt/homebrew/bin:$PATH"                    # Homebrew
export PATH="/Users/username/.codeium/windsurf/bin:$PATH" # Windsurf
```

### Editor & Display
```bash
export EDITOR="nvim"                                     # Default editor
export CLICOLOR=1                                        # Enable colors
export LSCOLORS=GxFxCxDxBxegedabagaced                  # Color scheme
```

## 🛠️ Customization

### Changing the Theme Character
Edit `.zsh-theme` file:
```bash
# Change this line in the theme file
PROMPT='%F{magenta}→%f$(git_prompt_info) '  # Arrow instead of face
```

### Adding Custom Aliases
Add to `.zshrc`:
```bash
# Custom aliases
alias myalias='your-command'
alias work='cd ~/workspace && code .'
```

### Modifying Git Status Colors
In `.zsh-theme`, edit the git_prompt_info function:
```bash
git_status="%F{blue}*%f"     # Change red to blue for modified files
git_status="${git_status}%F{cyan}?%f"  # Change yellow to cyan for untracked
```

## 🔧 Advanced Configuration

### Plugin Management
Add new plugins to `.zshrc`:
```bash
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  docker                    # Add docker plugin
  kubectl                   # Add kubernetes plugin
)
```

### Custom Functions
Add to `.zshrc`:
```bash
# Create and enter directory
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Git commit with current timestamp
gcnow() {
  git commit -m "$(date): $1"
}
```

## 🐛 Troubleshooting

### Plugins Not Loading
1. Check plugin installation:
   ```bash
   ls ~/.oh-my-zsh/plugins/
   ```
2. Verify plugin names in `.zshrc`
3. Reload configuration: `source ~/.zshrc`

### Theme Not Displaying
1. Ensure theme file is in correct location:
   ```bash
   ls ~/.oh-my-zsh/themes/minimal-git.zsh-theme
   ```
2. Check theme name in `.zshrc`: `ZSH_THEME="minimal-git"`
3. Restart terminal

### Autosuggestions Not Working
1. Install via Homebrew:
   ```bash
   brew install zsh-autosuggestions
   ```
2. Check source path in `.zshrc`
3. Restart terminal

### Colors Not Showing
1. Check terminal color support: `echo $TERM`
2. Enable colors: `export CLICOLOR=1`
3. Try different terminal emulator

## 📝 Tips & Tricks

### Productivity Shortcuts
1. **History Search**: `Ctrl+R` for reverse search
2. **Auto-completion**: `Tab` for command completion
3. **Directory Navigation**: `cd -` to go back to previous directory
4. **Command Correction**: Type wrong command, `thefuck` will suggest fix

### Git Workflow
1. **Quick Status**: `gs` shows current git status
2. **Fast Commit**: `ga && gc "message" && gp` for quick commit and push
3. **Branch Info**: Always visible in prompt

### File Management
1. **Modern Listing**: `als` for beautiful file listing
2. **Tree View**: `tree` for directory structure
3. **Quick Clear**: `cls` for complete screen clear

## 🎨 Theme Customization Examples

### Different Prompt Styles
```bash
# Minimalist arrow
PROMPT='%F{cyan}→%f$(git_prompt_info) '

# Classic style
PROMPT='%n@%m:%~$(git_prompt_info)$ '

# Powerline-like
PROMPT='%F{blue}▶%f %F{green}%~%f$(git_prompt_info) '
```

### Time Format Options
```bash
# 12-hour format
time_prompt() {
  echo "%F{8}[%D{%I:%M:%S %p}]%f"
}

# Date and time
time_prompt() {
  echo "%F{8}[%D{%m/%d %H:%M}]%f"
}
```

---

**Enjoy your clean and efficient zsh setup! 🚀**

*Run `reload` to apply any configuration changes.*