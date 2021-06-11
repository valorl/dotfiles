let mapleader=" "

set guicursor=
set noshowmatch
set relativenumber
set nohlsearch
set hidden
set noerrorbells
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
set nu
set nowrap
set smartcase
set noswapfile
set nobackup
set undodir=~/.vim/undodir
set undofile
set incsearch
set termguicolors
set scrolloff=8

set cmdheight=2

set wildoptions+=pum

set colorcolumn=80
highlight ColorColumn ctermbg=0 guibg=lightgrey

call plug#begin('~/local/share/nvim/plugged')

" Themes
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'tomasiser/vim-code-dark'
Plug 'gruvbox-community/gruvbox'

" Not yet ?
" https://github.com/tjdevries/astronauta.nvim/issues/1
Plug 'tjdevries/astronauta.nvim'

" LSP
Plug 'neovim/nvim-lspconfig'
Plug 'tjdevries/lsp_extensions.nvim'
Plug 'hrsh7th/nvim-compe'
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/vim-vsnip-integ'

" Lua
Plug 'tjdevries/nlua.nvim'
Plug 'euclidianAce/BetterLua.vim'

" DAP
Plug 'mfussenegger/nvim-dap'

" Telescope
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
Plug 'kyazdani42/nvim-web-devicons'

Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-treesitter/playground'
" This objectively makes vim better
" Plug 'terryma/vim-multiple-cursors'
" Working with tags
" Plug 'alvan/vim-closetag'
" Plug 'tpope/vim-surround'
" Plug 'sheerun/vim-polyglot'
" Commenting
Plug 'tpope/vim-commentary'
" Syntax highlighting
Plug 'rrethy/vim-hexokinase', { 'do': 'make hexokinase' }
" Plug 'hashivim/vim-terraform'
" Plug 'OmniSharp/omnisharp-vim'
" Plug 'nickspoons/vim-sharpenup'
" Plug 'fatih/vim-go', {'do': ':GoUpdateBinaries'}
Plug 'tweekmonster/gofmt.vim'
Plug 'jremmen/vim-ripgrep'
Plug 'tpope/vim-fugitive'
Plug 'shumphrey/fugitive-gitlab.vim'
Plug 'mbbill/undotree'
" Plug 'ThePrimeagen/vim-be-good', {'do': './install.sh'}
Plug 'qpkorr/vim-renamer'
Plug 'tpope/vim-markdown'
" Plug 'aserebryakov/vim-todo-lists'

Plug 'tjdevries/colorbuddy.vim'
Plug 'tjdevries/gruvbuddy.nvim'



call plug#end()


let g:OmniSharp_server_stdio = 1
let g:OmniSharp_selector_ui = 'fzf'
let g:OmniSharp_loglevel = 'debug'

let g:fugitive_gitlab_domains = ['https://gitlab.neasenergy.com']
let g:gitlab_api_keys = $GITLAB_API_KEY


let g:airline_theme = 'codedark'
let g:gruvbox_contrast_dark = "hard"
let g:gruvbox_invert_selection = "0"
colorscheme gruvbox
" lua require('colorbuddy').colorscheme('gruvbuddy')

" Markdown
let g:markdown_fenced_languages = []

" FZF window
let g:fzf_layout = { 'window': { 'width': 0.8, 'height': 0.8 } }
let $FZF_DEFAULT_OPTS='--reverse'


" gofmt.vim
let g:gofmt_exe = 'goimports'

"
" Autocompletion
set wildmode=longest,full

" Netrw
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 2
let g:netrw_winsize = 25

let g:vrfr_rg = 'true'



set updatetime=50

" Some servers have issues with backup files, see #649
set nobackup
set nowritebackup

" don't give |ins-completion-menu| messages.
set shortmess+=c

" always show signcolumns
set signcolumn=yes

" Copy to clipboard
vnoremap  <leader>y  "+y
nnoremap  <leader>Y  +yg_
nnoremap  <leader>y  "+y
nnoremap  <leader>yy  "+yy

" " Paste from clipboard
nnoremap <leader>p "+p
nnoremap <leader>P "+P
vnoremap <leader>p "+p
vnoremap <leader>P "+P"

nnoremap <leader>h :wincmd h<CR>
nnoremap <leader>j :wincmd j<CR>
nnoremap <leader>k :wincmd k<CR>
nnoremap <leader>l :wincmd l<CR>
nnoremap <leader>u :UndotreeShow<CR>
nnoremap <leader>pv :wincmd v<bar> :Ex <bar> :vertical resize 30<CR>
nnoremap <leader>ps :Rg<SPACE>

nnoremap <C-j> :cnext<CR>
nnoremap <C-k> :cprev<CR>


nnoremap <leader>pf :Files<CR>
nnoremap <leader><CR> :so ~/.config/nvim/init.vim<CR>
nnoremap <leader>+ :vertical resize +5<CR>
nnoremap <leader>- :vertical resize -5<CR>
nnoremap <leader>ee oif err != nil {<CR>log.Fatalf("%+v\n", err)<CR>}<CR><esc>kkI<esc>
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv
" b64 decode selection
vnoremap <leader>64e y:let @"=system('base64', @")<cr>gvp
vnoremap <leader>64d y:let @"=system('base64 --decode', @")<cr>gvp

inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

inoremap <expr> <c-n> compe#complete()
inoremap <expr> <cr>      compe#confirm('<cr>')
inoremap <expr> <c-e>     compe#close('<c-e>')
inoremap <expr> <c-f>     compe#scroll({ 'delta': +4 })
inoremap <expr> <c-d>     compe#scroll({ 'delta': -4 })

" OmniSharp and C#
" augroup omnisharp_commands
"   autocmd!

"   " autocmd FileType cs setlocal commentstring="// %s"

"   " Show type information automatically when the cursor stops moving.
"   " Note that the type is echoed to the Vim command line, and will overwrite
"   " any other messages in this space including e.g. ALE linting messages.
"   autocmd CursorHold *.cs OmniSharpTypeLookup

"   " CoC overrides
"   autocmd FileType cs nmap <buffer><Leader>gd <Plug>(omnisharp_go_to_definition)
"   autocmd FileType cs nmap <buffer><leader>gi <Plug>(omnisharp_find_implementations)
"   autocmd FileType cs nmap <buffer><leader>gr <Plug>(omnisharp_find_usages)

"   " The following commands are contextual, based on the cursor position.
"   autocmd FileType cs nmap <buffer> <leader>opd <Plug>(omnisharp_preview_definition)
"   autocmd FileType cs nmap <buffer> <leader>opi <Plug>(omnisharp_preview_implementations)
"   autocmd FileType cs nmap <buffer> <leader>ofx <Plug>(omnisharp_fix_usings)
"   " autocmd FileType cs nmap <silent> <buffer> <Leader>osfs <Plug>(omnisharp_find_symbol)
"   autocmd FileType cs nmap <silent> <buffer> <C-\> <Plug>(omnisharp_signature_help)
"   autocmd FileType cs imap <silent> <buffer> <C-\> <Plug>(omnisharp_signature_help)

"   " Navigate up and down by method/property/field
"   " autocmd FileType cs nmap <silent> <buffer> [[ <Plug>(omnisharp_navigate_up)
"   " autocmd FileType cs nmap <silent> <buffer> ]] <Plug>(omnisharp_navigate_down)
"   " Find all code errors/warnings for the current solution and populate the quickfix window
"   autocmd FileType cs nmap <buffer> <leader>ogcc <Plug>(omnisharp_global_code_check)
"   " Contextual code actions (uses fzf, vim-clap, CtrlP or unite.vim selector when available)
"   autocmd FileType cs nmap <buffer> <leader>oo <Plug>(omnisharp_code_actions)
"   " autocmd FileType cs xmap <silent> <buffer> <Leader>osca <Plug>(omnisharp_code_actions)
"   " Repeat the last code action performed (does not use a selector)
"   " autocmd FileType cs nmap <silent> <buffer> <Leader>os. <Plug>(omnisharp_code_action_repeat)
"   " autocmd FileType cs xmap <silent> <buffer> <Leader>os. <Plug>(omnisharp_code_action_repeat)

"   autocmd FileType cs nmap <buffer> <leader>o= <Plug>(omnisharp_code_format)

"   autocmd FileType cs nmap <buffer> <leader>onm <Plug>(omnisharp_rename)

"   autocmd FileType cs nmap <buffer> <leader>ore <Plug>(omnisharp_restart_server)
"   autocmd FileType cs nmap <buffer> <leader>ost <Plug>(omnisharp_start_server)
"   autocmd FileType cs nmap <buffer> <leader>osp <Plug>(omnisharp_stop_server)
" augroup END

" Fugitive
nmap <leader>gs :G<CR>

"Lua stuff
lua require('init')

" Shortcutting split navigation
" map <C-h> <C-w>h
" map <C-j> <C-w>j
" map <C-k> <C-w>k
" map <C-l> <C-w>l

" Remove trailing whitespace on save
autocmd BufWritePre * %s/\s\+$//e
