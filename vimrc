" You can symlink this file to ~/.vimrc in windows Git Bash:
" - Make a ~/.bash_profile file and put in "export MSYS=winsymlinks:nativestrict"
" - Run git bash in administrator mode
" - "ln -s /path/to/advent/vimrc ~/.vimrc"


" Use pathogen as a vim plugin manager {{{
" Comment this out if you don't have pathogen installed
execute pathogen#infect()
" }}}

" Tabs suck, use spaces {{{
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
" }}}

" Other basic options {{{
set hlsearch
set nowrap
" }}}

" Mappings {{{
let mapleader = ","

noremap <Leader>w :w<Enter>
noremap <Leader>q :q<Enter>

inoremap jk <Esc>

noremap <Leader>h <C-w><Left>
noremap <Leader>j <C-w><Down>
noremap <Leader>k <C-w><Up>
noremap <Leader>l <C-w><Right>
" }}}

" Quick open .vimrc file and reload it after saving {{{
nnoremap <Leader>ev :split $MYVIMRC<Enter>
nnoremap <Leader>sv :source $MYVIMRC<Enter>
" }}}

" Setup folding for vimscript files {{{
augroup filetype_vim
  autocmd!
  autocmd FileType vim setlocal foldmethod=marker
augroup END
" }}}
