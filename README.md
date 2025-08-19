Как пользоваться
•  Установить все конфиги (копированием):
  ./setup.sh --all
•  Установить выборочно:
  ./setup.sh --zsh --tmux
•  Вместо копирования использовать симлинки:
  ./setup.sh --all --link
•  Помощь:
  ./setup.sh --help

Что делает
•  Бэкапит существующие файлы в ~/.dotfiles_backup_YYYYmmdd_HHMMSS
•  Устанавливает:
•  zsh/.zshrc -> ~/.zshrc
•  tmux/.tmux.conf -> ~/.tmux.conf
•  nvim/.nvim.conf -> ~/.config/nvim/init.lua
•  При режиме  --link создает симлинки, иначе копирует
•  Если ~/.oh-my-zsh отсутствует, выдаст предупреждение (пакеты не ставит)
