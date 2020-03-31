call plug#begin('~/.local/nvim/plugged')
Plug 'jiangmiao/auto-pairs'
Plug 'preservim/nerdtree'
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
Plug 'jaredgorski/spacecamp'
Plug 'Shougo/echodoc.vim'
call plug#end()

set hidden

" theming
set number
set relativenumber
colorscheme spacecamp
hi LineNr ctermfg=NONE ctermbg=NONE
hi CursorLineNr ctermfg=NONE ctermbg=NONE

" hotkey settings
" Enable mouse controls
set mouse=a
" Who uses '.'?
let g:mapleader = "."
" Clear search matches with double escape
nnoremap <silent> <Esc><Esc> :noh<CR>
" To open a new empty buffer
" This replaces :tabnew which I used to bind to this mapping
nmap <silent> <leader>t :enew<cr>
" Move to the next buffer
nmap <silent> <leader>l :bnext<CR>
" Move to the previous buffer
nmap <silent> <leader>h :bprevious<CR>
" Close the current buffer and move to the previous one
" This replicates the idea of closing a tab
nmap <silent> <leader>hq :bp <BAR> bd #<CR>
" Save and quit
nmap <silent> q :wq<CR>

" airline settings
let g:airline#extensions#tabline#enabled = 1
let g:airline_theme = 'term'

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
\ }

" NERDTree settings
let g:NERDTreeWinPos = "right"
let g:NERDTreeMinimalUI = 1
let g:NERDTreeDirArrows = 0
let g:NERDTreeQuitOnOpen = 1
nmap <silent> f :NERDTreeToggle<CR>

" command settings
" use ripgrep with fzf
command! -bang -nargs=* Find call fzf#vim#grep('rg --column --line-number --no-heading --fixed-strings --ignore-case --no-ignore --hidden --follow --glob "!.git/*" --color "always" '.shellescape(<q-args>), 1, <bang>0)
