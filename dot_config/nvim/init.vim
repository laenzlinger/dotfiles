set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath=&runtimepath

" this is a workaround for vim on alacritty
set termguicolors
source ~/.vimrc
