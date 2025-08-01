# 🎨 Beautiful Tmux Configuration

A modern, feature-rich tmux configuration with Catppuccin Mocha theme, intuitive keybindings, and powerful plugins.

## ✨ Features

- **🎯 Custom Prefix**: `Ctrl+s` instead of default `Ctrl+b`
- **🎨 Catppuccin Mocha Theme**: Beautiful dark theme with vibrant colors
- **🖱️ Mouse Support**: Full mouse integration for modern workflow
- **📊 Rich Status Bar**: Shows session, user, path, git branch, time, battery, and system stats
- **🧭 Vim-style Navigation**: Intuitive hjkl pane navigation
- **🔌 Plugin Ecosystem**: Powered by TPM with essential plugins
- **⚡ Performance Optimized**: Fast startup and responsive interface

## 🚀 Quick Start

### Prerequisites

```bash
# Install tmux
brew install tmux  # macOS
# or
sudo apt install tmux  # Ubuntu/Debian
```

### Installation

1. **Clone or copy the configuration**:
   ```bash
   cp .tmux.conf ~/.tmux.conf
   ```

2. **Install TPM (Tmux Plugin Manager)**:
   ```bash
   git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
   ```

3. **Start tmux and install plugins**:
   ```bash
   tmux
   # Press Ctrl+s + I (capital i) to install plugins
   ```

4. **Reload configuration**:
   ```bash
   # Press Ctrl+s + r to reload
   ```

## 🎮 Key Bindings

### Core Navigation
| Key | Action |
|-----|--------|
| `Ctrl+s` | Prefix key |
| `Ctrl+s + r` | Reload configuration |
| `Ctrl+s + h/j/k/l` | Navigate panes (vim-style) |
| `Ctrl+s + H/J/K/L` | Resize panes |

### Window Management
| Key | Action |
|-----|--------|
| `Ctrl+s + c` | New window (in current path) |
| `Ctrl+s + n` | Next window |
| `Ctrl+s + p` | Previous window |

### Pane Splitting
| Key | Action |
|-----|--------|
| `Ctrl+s + "` | Horizontal split |
| `Ctrl+s + %` | Vertical split |
| `Ctrl+s + \|` | Vertical split (intuitive) |
| `Ctrl+s + -` | Horizontal split (intuitive) |

### Copy Mode
| Key | Action |
|-----|--------|
| `Ctrl+s + [` | Enter copy mode |
| `v` | Begin selection (in copy mode) |
| `y` | Copy selection to clipboard |

## 🔌 Included Plugins

- **tmux-sensible**: Sensible defaults for tmux
- **tmux-yank**: Enhanced copy/paste functionality
- **tmux-battery**: Battery status in status bar
- **tmux-open**: Open files and URLs from tmux
- **tmux-prefix-highlight**: Visual prefix key indicator
- **tmux-cpu**: CPU and RAM usage display

## 🎨 Theme Colors (Catppuccin Mocha)

The configuration uses the beautiful Catppuccin Mocha color palette:

- **Background**: `#1e1e2e` (Crust)
- **Foreground**: `#cdd6f4` (Text)
- **Accent Colors**: Blue, Pink, Green, Yellow, Orange, Magenta
- **Active Pane Border**: Blue (`#89b4fa`)
- **Inactive Elements**: Gray (`#585b70`)

## 📊 Status Bar Information

### Left Side
- 🔷 Session name
- 👤 Current user
- 📁 Current directory path
- 🌿 Git branch (if in git repo)

### Right Side
- ⏰ Current time (HH:MM:SS)
- 🔋 Battery status and percentage
- 💻 CPU usage percentage
- 🧠 RAM usage percentage
- 🎯 Prefix key highlight

## ⚙️ Configuration Highlights

### Performance Settings
```bash
set -g escape-time 0          # No delay for escape key
set -g repeat-time 300        # Repeat time for repeatable commands
set -g focus-events on        # Enable focus events
```

### Terminal Enhancements
```bash
set -g default-terminal "screen-256color"
set -g terminal-overrides ',xterm-256color:Tc'  # True color support
```

### User Experience
```bash
set -g mouse on               # Mouse support
set -g base-index 1           # Start windows at 1, not 0
set -g renumber-windows on    # Renumber windows automatically
```

## 🛠️ Customization

### Changing the Prefix Key
```bash
set -g prefix C-a  # Change to Ctrl+a
bind C-a send-prefix
```

### Adding Custom Keybindings
```bash
bind-key x kill-pane          # Kill pane with 'x'
bind-key & kill-window        # Kill window with '&'
```

### Modifying Colors
Edit the color variables in the theme section:
```bash
thm_bg="#your_background_color"
thm_fg="#your_foreground_color"
# ... etc
```

## 🔧 Troubleshooting

### Plugins Not Working
1. Ensure TPM is installed: `ls ~/.tmux/plugins/tpm`
2. Install plugins: `Ctrl+s + I`
3. Reload tmux: `tmux source ~/.tmux.conf`

### Colors Not Displaying Correctly
1. Check terminal true color support: `echo $TERM`
2. Ensure terminal supports 256 colors
3. Try: `export TERM=xterm-256color`

### Mouse Not Working
1. Ensure tmux version >= 2.1
2. Check if terminal supports mouse events
3. Try toggling: `set -g mouse off` then `set -g mouse on`

## 📝 Tips & Tricks

1. **Session Management**: Use `tmux new -s name` to create named sessions
2. **Detach/Attach**: `Ctrl+s + d` to detach, `tmux attach -t name` to reattach
3. **Copy to System Clipboard**: The `y` key in copy mode copies to system clipboard
4. **Zoom Panes**: `Ctrl+s + z` to zoom/unzoom current pane
5. **Command Prompt**: `Ctrl+s + :` to enter command mode

## 🎯 Advanced Usage

### Creating Custom Layouts
```bash
# Three pane layout
tmux split-window -h
tmux split-window -v
tmux select-pane -t 0
```

### Scripted Session Setup
```bash
#!/bin/bash
tmux new-session -d -s dev
tmux split-window -h
tmux split-window -v
tmux send-keys -t 0 'nvim' Enter
tmux send-keys -t 1 'npm run dev' Enter
tmux attach -t dev
```

---

**Enjoy your beautiful and functional tmux setup! 🚀**

*Press `Ctrl+s + r` to reload configuration after any changes.*