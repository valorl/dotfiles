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

" Markdown
let g:markdown_fenced_languages = []

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
vnoremap <leader>64e y:let @"=system('base64', @")<cr>gvp
vnoremap <leader>64d y:let @"=system('base64 --decode', @")<cr>gvp

inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

inoremap <expr> <c-n> compe#complete()
inoremap <expr> <cr>      compe#confirm('<cr>')
inoremap <expr> <c-e>     compe#close('<c-e>')
inoremap <expr> <c-f>     compe#scroll({ 'delta': +4 })
inoremap <expr> <c-d>     compe#scroll({ 'delta': -4 })

"Lua stuff
lua require('init')

" Remove trailing whitespace on save
autocmd BufWritePre * %s/\s\+$//e
