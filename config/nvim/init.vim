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

lua require('valorl.plugins')

let g:airline_theme = 'codedark'


let g:gruvbox_contrast_dark = "hard"
let g:gruvbox_invert_selection = "0"
colorscheme gruvbox



" let g:gruvbox_flat_style = "hard"
" colorscheme gruvbox-flat

" Markdown
let g:markdown_fenced_languages = []

" gofmt.vim
let g:gofmt_exe = 'goimports'

"
" Autocompletion
let g:completion_matching_strategy_list = ['exact', 'substring', 'fuzzy']
set wildmode=longest,full

" Netrw
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 2
let g:netrw_winsize = 25
let g:vrfr_rg = 'true'

set updatetime=1000

" don't give |ins-completion-menu| messages.
set shortmess+=c

" always show signcolumns
set signcolumn=yes

nnoremap <leader>pv :wincmd v<bar> :Ex <bar> :vertical resize 30<CR>

nnoremap <C-j> :cnext<CR>
nnoremap <C-k> :cprev<CR>


nnoremap <leader><CR> :so ~/.config/nvim/init.vim<CR>

nnoremap <leader>ee oif err != nil {<CR>log.Fatalf("%+v\n", err)<CR>}<CR><esc>kkI<esc>

vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" b64 decode selection
vnoremap <leader>be y:let @"=system('base64 -w 0', @")<cr>gvp
vnoremap <leader>bd y:let @"=system('base64 --decode', @")<cr>gvp

" inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
" inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

"Lua stuff
lua require('init')

" Remove trailing whitespace on save
autocmd BufWritePre * %s/\s\+$//e

nmap <leader>sp :call <SID>SynStack()<CR>
function! <SID>SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc

highlight link NormalFloat Normal
" GitMessenger. TODO: move this somewhere else
highlight link gitmessengerPopupNormal NormalFloat
let g:git_messenger_floating_win_opts = { 'border': 'single' }

highlight TreesitterContext guibg=#424242

" TODO: move this somewhere else
" set foldmethod=expr
" set foldexpr=nvim_treesitter#foldexpr()
"
" vim-smoothie
let g:smoothie_speed_linear_factor=50
