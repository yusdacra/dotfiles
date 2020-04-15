call plug#begin('~/.local/nvim/plugged')
Plug 'rust-lang/rust.vim'
Plug 'ron-rs/ron.vim'
Plug 'dart-lang/dart-vim-plugin'
Plug 'thosakwe/vim-flutter'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'deviantfero/wpgtk.vim'
Plug 'Shougo/echodoc.vim'
call plug#end()

set hidden

" theming
set number
set relativenumber
colorscheme wpgtkAlt
hi LineNr ctermfg=NONE ctermbg=NONE
hi CursorLineNr ctermfg=NONE ctermbg=NONE

" hotkey settings
" Enable mouse controls
set mouse=a
" Who uses '.'?
let g:mapleader = "."
" Clear search matches with double escape
nnoremap <silent> <Esc><Esc> :noh<CR>
" Move to the next buffer
nnoremap <silent> <leader>l :bnext<CR>
" Move to the previous buffer
nnoremap <silent> <leader>h :bprevious<CR>
nnoremap <leader>b :b 

" airline settings
let g:airline#extensions#tabline#enabled = 1
let g:airline_theme = 'wpgtk'

" echodoc settings
let g:echodoc#enable_at_startup = 1
let g:echodoc#type = 'virtual'

" deoplete settings
let g:deoplete#enable_at_startup = 1
call deoplete#custom#source('LanguageClient',
\ 'min_pattern_length',
\ 2)

" LanguageClient settings
let g:LanguageClient_serverCommands = {
\ 'rust': ['rust-analyzer'],
\ 'dart': ['$HOME/Belgeler/flutter/bin/cache/dart-sdk/bin/dart', '$HOME/Belgeler/flutter/bin/cache/dart-sdk/bin/snapshots/analysis_server.dart.snapshot', '--lsp'],
\ }
nnoremap <silent> <leader>cm :call LanguageClient_contextMenu()<CR>
nnoremap <silent> <leader>def   :call LanguageClient#textDocument_definition()<CR>
nnoremap <silent> <leader>hov     :call LanguageClient_textDocument_hover()<CR>
nnoremap <silent> <leader>imp   :call LanguageClient_textDocument_implementation()<CR>
nnoremap <silent> <leader>td    :call LanguageClient_textDocument_typeDefinition()<CR>
nnoremap <silent> <leader>ref   :call LanguageClient_textDocument_references()<CR>
nnoremap <silent> <leader>sym   :call LanguageClient_textDocument_documentSymbol()*<CR>

" rust.vim settings
let g:rustfmt_autosave = 1

" vim-flutter settings
let g:flutter_show_log_on_run = 0

" command settings
" use ripgrep with fzf
command! -bang -nargs=* Find call fzf#vim#grep('rg --column --line-number --no-heading --fixed-strings --ignore-case --no-ignore --follow --glob "!.git/*,!target/*" --color "always" '.shellescape(<q-args>), 1, <bang>0)
