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
            brew install tmux neovim eza fzf git curl wget
            brew install zsh-autosuggestions zsh-syntax-highlighting
            
            # Устанавливаем thefuck если его нет
            if ! command -v thefuck &> /dev/null; then
                brew install thefuck
            fi
            ;;
        "ubuntu")
            sudo apt update
            sudo apt install -y tmux neovim git curl wget zsh fzf xclip
            
            # Устанавливаем eza
            if ! command -v eza &> /dev/null; then
                wget -c https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz -O - | tar xz
                sudo chmod +x eza
                sudo mv eza /usr/local/bin/
            fi
            
            # Устанавливаем thefuck
            if ! command -v thefuck &> /dev/null; then
                pip3 install thefuck
            fi
            ;;
        "arch")
            sudo pacman -Syu --noconfirm
            sudo pacman -S --noconfirm tmux neovim git curl wget zsh fzf eza
            
            # AUR пакеты
            if command -v yay &> /dev/null; then
                yay -S --noconfirm thefuck
            fi
            ;;
    esac
    
    print_success "Зависимости установлены"
}

# 💾 Создание бэкапа существующих конфигов
backup_existing_configs() {
    print_step "Создаем бэкап существующих конфигураций..."
    
    mkdir -p "$BACKUP_DIR"
    
    # Список файлов для бэкапа
    configs=(
        "$HOME/.zshrc"
        "$HOME/.tmux.conf"
        "$HOME/.config/nvim"
        "$HOME/.oh-my-zsh/themes/minimal-git.zsh-theme"
    )
    
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
    
    # Копируем тему
    if [[ -f "$DOTFILES_DIR/zsh/.zsh-theme" ]]; then
        mkdir -p "$HOME/.oh-my-zsh/themes"
        cp "$DOTFILES_DIR/zsh/.zsh-theme" "$HOME/.oh-my-zsh/themes/minimal-git.zsh-theme"
        print_success "Скопирована тема minimal-git"
    else
        print_error "Файл zsh/.zsh-theme не найден"
        return 1
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
    
    # Копируем init.lua
    if [[ -f "$DOTFILES_DIR/nvim/.nvim.conf" ]]; then
        cp "$DOTFILES_DIR/nvim/.nvim.conf" "$HOME/.config/nvim/init.lua"
        print_success "Скопирован init.lua"
    else
        print_error "Файл nvim/.nvim.conf не найден"
        return 1
    fi
    
    # Устанавливаем lazy.nvim (будет установлен автоматически при первом запуске)
    print_success "Neovim конфигурация готова (плагины установятся при первом запуске)"
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

# 🎯 Финальная настройка
final_setup() {
    print_step "Выполняем финальную настройку..."
    
    # Обновляем права доступа
    chmod +x "$HOME/.dotfiles/setup.sh" 2>/dev/null || true
    
    # Создаем алиас для быстрого обновления
    if ! grep -q "alias dotfiles-update" "$HOME/.zshrc" 2>/dev/null; then
        echo "" >> "$HOME/.zshrc"
        echo "# Dotfiles management" >> "$HOME/.zshrc"
        echo "alias dotfiles-update='cd ~/.dotfiles && git pull && ./setup.sh'" >> "$HOME/.zshrc"
        print_success "Добавлен алиас dotfiles-update"
    fi
    
    print_success "Финальная настройка завершена"
}

# 📋 Показать итоговую информацию
show_final_info() {
    print_header "🎉 УСТАНОВКА ЗАВЕРШЕНА!"
    
    echo -e "${GREEN}Установленные компоненты:${NC}"
    echo -e "  ${CYAN}•${NC} Zsh с Oh My Zsh и кастомной темой minimal-git"
    echo -e "  ${CYAN}•${NC} Tmux с Catppuccin Mocha темой и TPM плагинами"
    echo -e "  ${CYAN}•${NC} Neovim IDE конфигурация с LSP и плагинами"
    echo -e "  ${CYAN}•${NC} Современные инструменты: eza, fzf, thefuck"
    
    echo -e "\n${YELLOW}Следующие шаги:${NC}"
    echo -e "  ${CYAN}1.${NC} Перезапустите терминал или выполните: ${BLUE}source ~/.zshrc${NC}"
    echo -e "  ${CYAN}2.${NC} Запустите tmux и нажмите ${BLUE}Ctrl+s + I${NC} для установки плагинов"
    echo -e "  ${CYAN}3.${NC} Откройте nvim - плагины установятся автоматически"
    echo -e "  ${CYAN}4.${NC} Используйте ${BLUE}dotfiles-update${NC} для обновления конфигураций"
    
    if [[ -d "$BACKUP_DIR" ]]; then
        echo -e "\n${YELLOW}Бэкап старых конфигураций:${NC} $BACKUP_DIR"
    fi
    
    echo -e "\n${MAGENTA}Наслаждайтесь красивой и функциональной средой разработки! 🚀${NC}"
}

# 🚀 Основная функция
main() {
    print_header "🎯 УСТАНОВКА DOTFILES ETOZHEDEX"
    
    echo -e "${CYAN}Этот скрипт установит:${NC}"
    echo -e "  • Zsh с кастомной темой и плагинами"
    echo -e "  • Tmux с красивой конфигурацией"
    echo -e "  • Neovim IDE с современными плагинами"
    echo -e "  • Дополнительные инструменты разработки"
    
    echo -e "\n${YELLOW}Продолжить установку? (y/N)${NC}"
    read -r response
    
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        print_warning "Установка отменена"
        exit 0
    fi
    
    # Выполняем установку
    detect_os
    install_package_manager
    install_dependencies
    backup_existing_configs
    install_oh_my_zsh
    install_zsh_config
    install_tmux_config
    install_neovim_config
    install_additional_tools
    final_setup
    show_final_info
}

# 🎬 Запуск скрипта
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi