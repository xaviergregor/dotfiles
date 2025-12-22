set nocompatible
syntax on
set background=dark
set termguicolors
set mouse=a
set ignorecase
set tabstop=2
set shiftwidth=2
set expandtab
set ai
set number
set hlsearch
set ruler
set t_Co=256

let g:airline_theme = 'transparent'

call plug#begin('~/.vim/plugged')
Plug 'EdenEast/nightfox.nvim'
Plug 'scrooloose/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
call plug#end()
colorscheme xavier
