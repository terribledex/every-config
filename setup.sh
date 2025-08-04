#!/bin/bash

# ╭─────────────────────────────────────────────────────────────╮
# │           🚀 ETOZHEDEX DOTFILES INSTALLER                   │
# │              Автоматическая установка конфигов              │
# ╰─────────────────────────────────────────────────────────────╯

set -e

# 🎨 Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 📁 Пути
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# 🎯 Функции для красивого вывода
print_header() {
    echo -e "\n${MAGENTA}╭─────────────────────────────────────────────────────────────╮${NC}"
    echo -e "${MAGENTA}│${NC} $1"
    echo -e "${MAGENTA}╰─────────────────────────────────────────────────────────────╯${NC}\n"
}

print_step() {
    echo -e "${BLUE}▶${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# 🔍 Проверка системных требований
check_requirements() {
    print_step "Проверяем системные требования..."
    
    local missing_tools=()
    
    # Проверяем основные инструменты
    if ! command -v git &> /dev/null; then
        missing_tools+=("git")
    fi
    
    if ! command -v curl &> /dev/null; then
        missing_tools+=("curl")
    fi
    
    # Минимальный конфиг nvim не требует make
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        print_warning "Отсутствуют необходимые инструменты: ${missing_tools[*]}"
        echo -e "${YELLOW}Установить их автоматически? (y/N)${NC} "
        read -r install_missing
        
        if [[ "$install_missing" =~ ^[Yy]$ ]]; then
            print_step "Устанавливаем недостающие инструменты..."
            case $OS in
                "macos")
                    for tool in "${missing_tools[@]}"; do
                        brew install "$tool"
                    done
                    ;;
                "ubuntu")
                    sudo apt update
                    sudo apt install -y "${missing_tools[@]}"
                    ;;
                "arch")
                    sudo pacman -S --noconfirm "${missing_tools[@]}"
                    ;;
            esac
        else
            print_error "Установка невозможна без необходимых инструментов"
            exit 1
        fi
    fi
    
    print_success "Системные требования выполнены"
}

# 🔍 Определение ОС
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        PACKAGE_MANAGER="brew"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt &> /dev/null; then
            OS="ubuntu"
            PACKAGE_MANAGER="apt"
        elif command -v yum &> /dev/null; then
            OS="centos"
            PACKAGE_MANAGER="yum"
        elif command -v pacman &> /dev/null; then
            OS="arch"
            PACKAGE_MANAGER="pacman"
        else
            print_error "Неподдерживаемый дистрибутив Linux"
            exit 1
        fi
    else
        print_error "Неподдерживаемая операционная система: $OSTYPE"
        exit 1
    fi
    
    print_success "Обнаружена ОС: $OS"
}

# 📦 Установка пакетного менеджера
install_package_manager() {
    if [[ "$OS" == "macos" ]]; then
        if ! command -v brew &> /dev/null; then
            print_step "Устанавливаем Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            
            # Добавляем Homebrew в PATH для Apple Silicon
            if [[ $(uname -m) == "arm64" ]]; then
                echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
                eval "$(/opt/homebrew/bin/brew shellenv)"
            fi
            
            print_success "Homebrew установлен"
        else
            print_success "Homebrew уже установлен"
        fi
    fi
}

# 🛠️ Установка зависимостей
install_dependencies() {
    print_step "Устанавливаем необходимые пакеты..."
    
    case $OS in
        "macos")
            brew update
            brew install tmux neovim eza fzf git curl wget python3
            brew install zsh-autosuggestions zsh-syntax-highlighting
            
            # Устанавливаем thefuck если его нет
            if ! command -v thefuck &> /dev/null; then
                print_step "Устанавливаем thefuck..."
                pip3 install --user thefuck || brew install thefuck
            fi
            ;;
        "ubuntu")
            sudo apt update
            sudo apt install -y tmux neovim git curl wget zsh fzf xclip python3 python3-pip
            
            # Устанавливаем eza
            if ! command -v eza &> /dev/null; then
                print_step "Устанавливаем eza..."
                wget -c https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz -O - | tar xz
                sudo chmod +x eza
                sudo mv eza /usr/local/bin/
            fi
            
            # Устанавливаем zsh плагины
            if [[ ! -d "/usr/share/zsh-autosuggestions" ]]; then
                sudo apt install -y zsh-autosuggestions zsh-syntax-highlighting
            fi
            
            # Устанавливаем thefuck
            if ! command -v thefuck &> /dev/null; then
                print_step "Устанавливаем thefuck..."
                pip3 install --user thefuck
            fi
            ;;
        "arch")
            sudo pacman -Syu --noconfirm
            sudo pacman -S --noconfirm tmux neovim git curl wget zsh fzf python python-pip
            
            # Устанавливаем eza
            if ! command -v eza &> /dev/null; then
                print_step "Устанавливаем eza..."
                sudo pacman -S --noconfirm eza || {
                    if command -v yay &> /dev/null; then
                        yay -S --noconfirm eza
                    fi
                }
            fi
            
            # Устанавливаем zsh плагины
            sudo pacman -S --noconfirm zsh-autosuggestions zsh-syntax-highlighting || true
            
            # Устанавливаем thefuck
            if ! command -v thefuck &> /dev/null; then
                print_step "Устанавливаем thefuck..."
                pip install --user thefuck || {
                    if command -v yay &> /dev/null; then
                        yay -S --noconfirm thefuck
                    fi
                }
            fi
            ;;
    esac
    
    print_success "Зависимости установлены"
}

# 💾 Создание бэкапа существующих конфигов
backup_existing_configs() {
    print_step "Создаем бэкап существующих конфигураций..."
    
    mkdir -p "$BACKUP_DIR"
    
    # Список файлов для бэкапа в зависимости от выбранных компонентов
    configs=()
    
    if [[ "$INSTALL_ZSH" == "true" ]]; then
        configs+=("$HOME/.zshrc")
        configs+=("$HOME/.oh-my-zsh/themes/dex.zsh-theme")
        configs+=("$HOME/.oh-my-zsh/themes/fuck.zsh-theme")
    fi
    
    if [[ "$INSTALL_TMUX" == "true" ]]; then
        configs+=("$HOME/.tmux.conf")
    fi
    
    if [[ "$INSTALL_NVIM" == "true" ]]; then
        configs+=("$HOME/.config/nvim")
    fi
    
    for config in "${configs[@]}"; do
        if [[ -e "$config" ]]; then
            cp -r "$config" "$BACKUP_DIR/" 2>/dev/null || true
            print_success "Создан бэкап: $(basename "$config")"
        fi
    done
    
    if [[ -n "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]]; then
        print_success "Бэкап создан в: $BACKUP_DIR"
    else
        rmdir "$BACKUP_DIR"
        print_success "Бэкап не требуется - конфигурации отсутствуют"
    fi
}

# 🐚 Установка Oh My Zsh
install_oh_my_zsh() {
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        print_step "Устанавливаем Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        print_success "Oh My Zsh установлен"
    else
        print_success "Oh My Zsh уже установлен"
    fi
}

# 🎨 Установка Zsh конфигурации
install_zsh_config() {
    print_step "Устанавливаем Zsh конфигурацию..."
    
    # Копируем .zshrc
    if [[ -f "$DOTFILES_DIR/zsh/.zshrc" ]]; then
        cp "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
        print_success "Скопирован .zshrc"
    else
        print_error "Файл zsh/.zshrc не найден"
        return 1
    fi
    
    # Создаем директорию для тем
    mkdir -p "$HOME/.oh-my-zsh/themes"
    
    # Копируем все доступные темы
    local themes_installed=0
    
    if [[ -f "$DOTFILES_DIR/zsh/dex.zsh-theme" ]]; then
        cp "$DOTFILES_DIR/zsh/dex.zsh-theme" "$HOME/.oh-my-zsh/themes/dex.zsh-theme"
        print_success "Скопирована тема dex"
        themes_installed=1
    fi
    
    if [[ -f "$DOTFILES_DIR/zsh/fuck.zsh-theme" ]]; then
        cp "$DOTFILES_DIR/zsh/fuck.zsh-theme" "$HOME/.oh-my-zsh/themes/fuck.zsh-theme"
        print_success "Скопирована тема fuck"
        themes_installed=1
    fi
    
    if [[ $themes_installed -eq 0 ]]; then
        print_warning "Темы не найдены, будет использована тема по умолчанию"
    fi
    
    # Устанавливаем zsh как shell по умолчанию
    if [[ "$SHELL" != "$(which zsh)" ]]; then
        print_step "Устанавливаем zsh как shell по умолчанию..."
        chsh -s "$(which zsh)"
        print_success "Zsh установлен как shell по умолчанию"
    fi
}

# 🖥️ Установка Tmux конфигурации
install_tmux_config() {
    print_step "Устанавливаем Tmux конфигурацию..."
    
    # Копируем .tmux.conf
    if [[ -f "$DOTFILES_DIR/tmux/.tmux.conf" ]]; then
        cp "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
        print_success "Скопирован .tmux.conf"
    else
        print_error "Файл tmux/.tmux.conf не найден"
        return 1
    fi
    
    # Устанавливаем TPM (Tmux Plugin Manager)
    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
        print_step "Устанавливаем TPM (Tmux Plugin Manager)..."
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
        print_success "TPM установлен"
    else
        print_success "TPM уже установлен"
    fi
}

# ⚡ Установка Neovim конфигурации
install_neovim_config() {
    print_step "Устанавливаем Neovim конфигурацию..."
    
    # Создаем директорию для конфигурации
    mkdir -p "$HOME/.config/nvim"
    
    # Копируем конфигурацию Neovim
    if [[ -f "$DOTFILES_DIR/nvim/.nvim.conf" ]]; then
        cp "$DOTFILES_DIR/nvim/.nvim.conf" "$HOME/.config/nvim/init.lua"
        print_success "Скопирован init.lua"
    else
        print_error "Файл nvim/.nvim.conf не найден"
        return 1
    fi
    
    # lazy.nvim и плагины установятся автоматически при первом запуске
    print_success "Neovim конфигурация готова (Catppuccin тема и Treesitter установятся при первом запуске)"
}

# 🔧 Установка дополнительных инструментов
install_additional_tools() {
    print_step "Устанавливаем дополнительные инструменты..."
    
    # fzf интеграция
    if command -v fzf &> /dev/null; then
        if [[ ! -f "$HOME/.fzf.zsh" ]]; then
            print_step "Настраиваем fzf интеграцию..."
            if [[ "$OS" == "macos" ]]; then
                $(brew --prefix)/opt/fzf/install --all --no-bash --no-fish
            else
                /usr/share/doc/fzf/examples/install --all --no-bash --no-fish 2>/dev/null || true
            fi
            print_success "fzf интеграция настроена"
        fi
    fi
    
    # Создаем символические ссылки для удобства
    if [[ ! -L "$HOME/.dotfiles" ]]; then
        ln -sf "$DOTFILES_DIR" "$HOME/.dotfiles"
        print_success "Создана символическая ссылка ~/.dotfiles"
    fi
}

# 🔗 Создание символических ссылок (опционально)
create_symlinks() {
    # Проверяем, установлены ли какие-либо компоненты
    if [[ "$INSTALL_ZSH" != "true" && "$INSTALL_TMUX" != "true" && "$INSTALL_NVIM" != "true" ]]; then
        return 0
    fi
    
    print_step "Создаем символические ссылки для синхронизации..."
    
    echo -e "\n${YELLOW}Хотите создать символические ссылки вместо копирования файлов?${NC}"
    echo -e "${CYAN}Это позволит автоматически синхронизировать изменения с репозиторием.${NC}"
    echo -e "${YELLOW}Создать символические ссылки? (y/N)${NC} "
    read -r symlink_response
    
    if [[ "$symlink_response" =~ ^[Yy]$ ]]; then
        # Создаем символические ссылки только для установленных компонентов
        if [[ "$INSTALL_ZSH" == "true" ]]; then
            rm -f "$HOME/.zshrc"
            ln -sf "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
            
            # Символические ссылки для тем
            mkdir -p "$HOME/.oh-my-zsh/themes"
            [[ -f "$DOTFILES_DIR/zsh/dex.zsh-theme" ]] && ln -sf "$DOTFILES_DIR/zsh/dex.zsh-theme" "$HOME/.oh-my-zsh/themes/dex.zsh-theme"
            [[ -f "$DOTFILES_DIR/zsh/fuck.zsh-theme" ]] && ln -sf "$DOTFILES_DIR/zsh/fuck.zsh-theme" "$HOME/.oh-my-zsh/themes/fuck.zsh-theme"
        fi
        
        if [[ "$INSTALL_TMUX" == "true" ]]; then
            rm -f "$HOME/.tmux.conf"
            ln -sf "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
        fi
        
        if [[ "$INSTALL_NVIM" == "true" ]]; then
            rm -rf "$HOME/.config/nvim"
            mkdir -p "$HOME/.config/nvim"
            ln -sf "$DOTFILES_DIR/nvim/.nvim.conf" "$HOME/.config/nvim/init.lua"
        fi
        
        print_success "Символические ссылки созданы - конфиги будут автоматически синхронизироваться"
    else
        print_success "Используются копии файлов"
    fi
}

# 🔍 Проверка установки
verify_installation() {
    print_step "Проверяем установку компонентов..."
    
    local errors=0
    
    # Проверяем только установленные компоненты
    if [[ "$INSTALL_ZSH" == "true" ]] && [[ ! -f "$HOME/.zshrc" ]]; then
        print_error ".zshrc не найден"
        errors=$((errors + 1))
    fi
    
    if [[ "$INSTALL_TMUX" == "true" ]] && [[ ! -f "$HOME/.tmux.conf" ]]; then
        print_error ".tmux.conf не найден"
        errors=$((errors + 1))
    fi
    
    if [[ "$INSTALL_NVIM" == "true" ]] && [[ ! -f "$HOME/.config/nvim/init.lua" ]]; then
        print_error "Neovim конфигурация не найдена"
        errors=$((errors + 1))
    fi
    
    # Проверяем команды только для установленных компонентов
    local commands=("git")
    [[ "$INSTALL_ZSH" == "true" ]] && commands+=("zsh")
    [[ "$INSTALL_TMUX" == "true" ]] && commands+=("tmux")
    [[ "$INSTALL_NVIM" == "true" ]] && commands+=("nvim")
    
    for cmd in "${commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            print_error "Команда $cmd не найдена"
            errors=$((errors + 1))
        fi
    done
    
    if [[ $errors -eq 0 ]]; then
        print_success "Все компоненты установлены корректно"
    else
        print_warning "Обнаружено $errors ошибок в установке"
    fi
    
    return $errors
}

# 🎯 Финальная настройка
final_setup() {
    print_step "Выполняем финальную настройку..."
    
    # Обновляем права доступа
    chmod +x "$HOME/.dotfiles/setup.sh" 2>/dev/null || true
    
    # Добавляем ~/.local/bin в PATH если его там нет
    if [[ "$INSTALL_ZSH" == "true" ]] && [[ -f "$HOME/.zshrc" ]]; then
        if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.zshrc" 2>/dev/null; then
            echo "" >> "$HOME/.zshrc"
            echo "# Add ~/.local/bin to PATH for user-installed packages" >> "$HOME/.zshrc"
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
            print_success "Добавлен ~/.local/bin в PATH"
        fi
    fi
    
    # Создаем алиас для быстрого обновления
    if [[ "$INSTALL_ZSH" == "true" ]] && ! grep -q "alias dotfiles-update" "$HOME/.zshrc" 2>/dev/null; then
        echo "" >> "$HOME/.zshrc"
        echo "# Dotfiles management" >> "$HOME/.zshrc"
        echo "alias dotfiles-update='cd ~/.dotfiles && git pull && ./setup.sh'" >> "$HOME/.zshrc"
        echo "alias dotfiles-edit='cd ~/.dotfiles && nvim .'" >> "$HOME/.zshrc"
        print_success "Добавлены алиасы для управления dotfiles"
    fi
    
    # Проверяем установку
    verify_installation
    
    print_success "Финальная настройка завершена"
}

# 📋 Показать итоговую информацию
show_final_info() {
    print_header "🎉 УСТАНОВКА ЗАВЕРШЕНА!"
    
    echo -e "${GREEN}Установленные компоненты:${NC}"
    
    if [[ "$INSTALL_ZSH" == "true" ]]; then
        echo -e "  ${CYAN}•${NC} Zsh с Oh My Zsh и кастомными темами (dex, fuck)"
    fi
    
    if [[ "$INSTALL_TMUX" == "true" ]]; then
        echo -e "  ${CYAN}•${NC} Tmux с Catppuccin Mocha темой"
    fi
    
    if [[ "$INSTALL_NVIM" == "true" ]]; then
        echo -e "  ${CYAN}•${NC} Neovim минимальный конфиг с Catppuccin темой и подсветкой синтаксиса"
    fi
    
    echo -e "  ${CYAN}•${NC} Современные инструменты: eza, fzf, thefuck"
    
    echo -e "\n${YELLOW}Следующие шаги:${NC}"
    local step=1
    
    if [[ "$INSTALL_ZSH" == "true" ]]; then
        echo -e "  ${CYAN}${step}.${NC} Перезапустите терминал или выполните: ${BLUE}exec zsh${NC}"
        echo -e "  ${CYAN}$((step+1)).${NC} Доступные темы zsh: ${BLUE}dex${NC} и ${BLUE}fuck${NC} (текущая: fuck)"
        echo -e "  ${CYAN}$((step+2)).${NC} Если thefuck не работает, выполните: ${BLUE}source ~/.zshrc${NC}"
        step=$((step+3))
    fi
    
    if [[ "$INSTALL_TMUX" == "true" ]]; then
        echo -e "  ${CYAN}${step}.${NC} Запустите tmux - конфигурация готова к использованию"
        step=$((step+1))
    fi
    
    if [[ "$INSTALL_NVIM" == "true" ]]; then
        echo -e "  ${CYAN}${step}.${NC} Откройте nvim - Catppuccin тема и Treesitter установятся автоматически"
        step=$((step+1))
    fi
    
    echo -e "  ${CYAN}${step}.${NC} Используйте ${BLUE}dotfiles-update${NC} для обновления конфигураций"
    
    if [[ -d "$BACKUP_DIR" ]]; then
        echo -e "\n${YELLOW}Бэкап старых конфигураций:${NC} $BACKUP_DIR"
    fi
    
    echo -e "\n${BLUE}📚 Документация:${NC}"
    if [[ "$INSTALL_ZSH" == "true" ]]; then
        echo -e "  ${CYAN}•${NC} Zsh: ${BLUE}cat ~/.dotfiles/zsh/README.md${NC}"
    fi
    if [[ "$INSTALL_TMUX" == "true" ]]; then
        echo -e "  ${CYAN}•${NC} Tmux: ${BLUE}cat ~/.dotfiles/tmux/README.md${NC}"
    fi
    if [[ "$INSTALL_NVIM" == "true" ]]; then
        echo -e "  ${CYAN}•${NC} Neovim: ${BLUE}cat ~/.dotfiles/nvim/README.md${NC}"
    fi
    
    echo -e "\n${MAGENTA}Наслаждайтесь красивой и функциональной средой разработки! 🚀${NC}"
}

# � Показатяь справку
show_help() {
    echo -e "${MAGENTA}╭─────────────────────────────────────────────────────────────╮${NC}"
    echo -e "${MAGENTA}│${NC}           🚀 ETOZHEDEX DOTFILES INSTALLER HELP             ${MAGENTA}│${NC}"
    echo -e "${MAGENTA}╰─────────────────────────────────────────────────────────────╯${NC}"
    
    echo -e "\n${YELLOW}Использование:${NC}"
    echo -e "  ${BLUE}./setup.sh${NC}          - Интерактивная установка"
    echo -e "  ${BLUE}./setup.sh --help${NC}   - Показать эту справку"
    echo -e "  ${BLUE}./setup.sh --full${NC}   - Полная установка без вопросов"
    echo -e "  ${BLUE}./setup.sh --zsh${NC}    - Установить только Zsh"
    echo -e "  ${BLUE}./setup.sh --tmux${NC}   - Установить только Tmux"
    echo -e "  ${BLUE}./setup.sh --nvim${NC}   - Установить только Neovim"
    
    echo -e "\n${YELLOW}Компоненты:${NC}"
    echo -e "  ${GREEN}Zsh${NC}     - Oh My Zsh + кастомные темы (dex, fuck)"
    echo -e "  ${GREEN}Tmux${NC}    - Catppuccin Mocha тема + удобные хоткеи"
    echo -e "  ${GREEN}Neovim${NC}  - Минимальный конфиг с Catppuccin темой и подсветкой синтаксиса"
    
    echo -e "\n${YELLOW}Примеры:${NC}"
    echo -e "  ${BLUE}./setup.sh --full${NC}              # Установить все"
    echo -e "  ${BLUE}./setup.sh --zsh --tmux${NC}        # Только Zsh и Tmux"
    echo -e "  ${BLUE}./setup.sh --nvim${NC}              # Только Neovim"
    
    echo -e "\n${CYAN}Для получения подробной информации о каждом компоненте${NC}"
    echo -e "${CYAN}смотрите README.md файлы в соответствующих папках.${NC}"
}

# 🚀 Основная функция
main() {
    # Обработка аргументов командной строки
    INSTALL_ZSH=false
    INSTALL_TMUX=false
    INSTALL_NVIM=false
    
    case "${1:-}" in
        --help|-h)
            show_help
            exit 0
            ;;
        --full)
            INSTALL_ZSH=true
            INSTALL_TMUX=true
            INSTALL_NVIM=true
            ;;
        --zsh)
            INSTALL_ZSH=true
            shift
            while [[ $# -gt 0 ]]; do
                case $1 in
                    --tmux) INSTALL_TMUX=true ;;
                    --nvim) INSTALL_NVIM=true ;;
                esac
                shift
            done
            ;;
        --tmux)
            INSTALL_TMUX=true
            shift
            while [[ $# -gt 0 ]]; do
                case $1 in
                    --zsh) INSTALL_ZSH=true ;;
                    --nvim) INSTALL_NVIM=true ;;
                esac
                shift
            done
            ;;
        --nvim)
            INSTALL_NVIM=true
            shift
            while [[ $# -gt 0 ]]; do
                case $1 in
                    --zsh) INSTALL_ZSH=true ;;
                    --tmux) INSTALL_TMUX=true ;;
                esac
                shift
            done
            ;;
        "")
            # Интерактивный режим - будет обработан ниже
            ;;
        *)
            print_error "Неизвестный аргумент: $1"
            echo -e "Используйте ${BLUE}--help${NC} для справки"
            exit 1
            ;;
    esac
    
    print_header "🎯 УСТАНОВКА DOTFILES ETOZHEDEX"
    
    echo -e "${CYAN}Этот скрипт установит:${NC}"
    echo -e "  • ${GREEN}Zsh${NC} с Oh My Zsh и кастомными темами (dex, fuck)"
    echo -e "  • ${GREEN}Tmux${NC} с Catppuccin Mocha темой и удобными хоткеями"
    echo -e "  • ${GREEN}Neovim${NC} минимальный конфиг с Catppuccin темой и подсветкой синтаксиса"
    echo -e "  • ${GREEN}Современные инструменты${NC}: eza, fzf, thefuck"
    
    echo -e "\n${BLUE}📁 Доступные конфигурации:${NC}"
    echo -e "  ${YELLOW}zsh/${NC}"
    echo -e "    ├── .zshrc (основная конфигурация)"
    echo -e "    ├── dex.zsh-theme (Catppuccin тема с git статусом)"
    echo -e "    └── fuck.zsh-theme (минималистичная тема)"
    echo -e "  ${YELLOW}tmux/${NC}"
    echo -e "    └── .tmux.conf (Catppuccin тема, mouse support)"
    echo -e "  ${YELLOW}nvim/${NC}"
    echo -e "    └── .nvim.conf (минимальный конфиг с темой и подсветкой)"
    
    # Интерактивный режим только если не переданы аргументы
    if [[ "$INSTALL_ZSH" == "false" && "$INSTALL_TMUX" == "false" && "$INSTALL_NVIM" == "false" ]]; then
        echo -e "\n${YELLOW}Выберите режим установки:${NC}"
        echo -e "  ${CYAN}1.${NC} Полная установка (все компоненты)"
        echo -e "  ${CYAN}2.${NC} Выборочная установка"
        echo -e "  ${CYAN}3.${NC} Отмена"
        echo -e "\n${YELLOW}Ваш выбор (1-3):${NC} "
        read -r install_mode
        
        case $install_mode in
            1)
                INSTALL_ZSH=true
                INSTALL_TMUX=true
                INSTALL_NVIM=true
                ;;
            2)
                echo -e "\n${YELLOW}Установить Zsh конфигурацию? (y/N)${NC} "
                read -r zsh_response
                INSTALL_ZSH=$([[ "$zsh_response" =~ ^[Yy]$ ]] && echo true || echo false)
                
                echo -e "${YELLOW}Установить Tmux конфигурацию? (y/N)${NC} "
                read -r tmux_response
                INSTALL_TMUX=$([[ "$tmux_response" =~ ^[Yy]$ ]] && echo true || echo false)
                
                echo -e "${YELLOW}Установить Neovim конфигурацию? (y/N)${NC} "
                read -r nvim_response
                INSTALL_NVIM=$([[ "$nvim_response" =~ ^[Yy]$ ]] && echo true || echo false)
                ;;
            3|*)
                print_warning "Установка отменена"
                exit 0
                ;;
        esac
    fi
    
    # Проверяем, что выбран хотя бы один компонент
    if [[ "$INSTALL_ZSH" == "false" && "$INSTALL_TMUX" == "false" && "$INSTALL_NVIM" == "false" ]]; then
        print_warning "Не выбран ни один компонент для установки"
        exit 0
    fi
    
    # Выполняем установку
    detect_os
    check_requirements
    install_package_manager
    install_dependencies
    backup_existing_configs
    
    # Устанавливаем выбранные компоненты
    if [[ "$INSTALL_ZSH" == "true" ]]; then
        install_oh_my_zsh
        install_zsh_config
    fi
    
    if [[ "$INSTALL_TMUX" == "true" ]]; then
        install_tmux_config
    fi
    
    if [[ "$INSTALL_NVIM" == "true" ]]; then
        install_neovim_config
    fi
    
    install_additional_tools
    create_symlinks
    final_setup
    show_final_info
}

# 🎬 Запуск скрипта
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi