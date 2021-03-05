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

set colorcolumn=80
highlight ColorColumn ctermbg=0 guibg=lightgrey

call plug#begin('~/local/share/nvim/plugged')

" Themes
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'tomasiser/vim-code-dark'
Plug 'gruvbox-community/gruvbox'
" Code Completion
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Fuzzy find files
Plug 'junegunn/fzf', { 'do': { -> fzf#install() }}
Plug 'junegunn/fzf.vim'
" This objectively makes vim better
" Plug 'terryma/vim-multiple-cursors'
" Working with tags
" Plug 'alvan/vim-closetag'
" Plug 'tpope/vim-surround'
Plug 'sheerun/vim-polyglot'
" Commenting
Plug 'tpope/vim-commentary'
" Syntax highlighting
Plug 'rrethy/vim-hexokinase', { 'do': 'make hexokinase' }
Plug 'hashivim/vim-terraform'
Plug 'OmniSharp/omnisharp-vim'
" Plug 'nickspoons/vim-sharpenup'
Plug 'fatih/vim-go', {'do': ':GoUpdateBinaries'}
Plug 'tweekmonster/gofmt.vim'
Plug 'jremmen/vim-ripgrep'
Plug 'tpope/vim-fugitive'
Plug 'shumphrey/fugitive-gitlab.vim'
Plug 'mbbill/undotree'
" Plug 'ThePrimeagen/vim-be-good', {'do': './install.sh'}
Plug 'qpkorr/vim-renamer'
Plug 'tpope/vim-markdown'
Plug 'aserebryakov/vim-todo-lists'



call plug#end()

let g:OmniSharp_server_stdio = 1
let g:OmniSharp_selector_ui = 'fzf'
let g:OmniSharp_loglevel = 'debug'

let g:fugitive_gitlab_domains = ['https://gitlab.neasenergy.com']
let g:gitlab_api_keys = $GITLAB_API_KEY


let g:airline_theme = 'codedark'
let g:gruvbox_contrast_dark = "hard"
colorscheme gruvbox

" Markdown
let g:markdown_fenced_languages = ['javascript', 'js=javascript', 'json=javascript', 'hcl', 'yaml', 'csharp', 'go']

" FZF window
let g:fzf_layout = { 'window': { 'width': 0.8, 'height': 0.8 } }
let $FZF_DEFAULT_OPTS='--reverse'


" --- vim go (polyglot) settings.
let g:go_highlight_build_constraints = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_operators = 1
let g:go_highlight_structs = 1
let g:go_highlight_types = 1
let g:go_highlight_function_parameters = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_generate_tags = 1
let g:go_highlight_format_strings = 1
let g:go_highlight_variable_declarations = 1
let g:go_auto_sameids = 1

" Basic settings

" Autocompletion
set wildmode=longest,list,full

" Fix splitting
" set splitbelow splitright

" Vim Quickscope
" Trigger a highlight in the appropriate direction when pressing these keys:
" let g:qs_highlight_on_keys = ['f', 'F', 't', 'T']
" highlight QuickScopePrimary guifg='#afff5f' gui=underline ctermfg=155 cterm=underline
" highlight QuickScopeSecondary guifg='#5fffff' gui=underline ctermfg=81 cterm=underline

" " ctrlp
" let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']
"
"

" Vim Hexokinase
let g:Hexokinase_optInPatterns = [
\     'full_hex',
\     'triple_hex',
\     'rgb',
\     'rgba',
\     'hsl',
\     'hsla',
\     'colour_names'
\ ]
let g:Hexokinase_highlighters = ['backgroundfull']

" Reenable hexokinase on enter
autocmd VimEnter * HexokinaseTurnOn

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
nnoremap <C-p> :GFiles<CR>
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

" CoC stuff
function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" disable vim-go :GoDef short cut (gd)
" this is handled by LanguageClient [LC]
let g:go_def_mapping_enabled = 0
inoremap <silent><expr> <C-j>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()

inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
inoremap <silent><expr> <C-space> coc#refresh()

nnoremap <silent> <leader>gh :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Remap keys for gotos
nnoremap <silent> <leader>gh :call <SID>show_documentation()<CR>
nmap <leader>gd <Plug>(coc-definition)
" nmap <leader>gd :<C-u>call CocActionAsync('jumpDefinition')<CR>
nmap <leader>gy <Plug>(coc-type-definition)
nmap <leader>gi <Plug>(coc-implementation)
nmap <leader>gr <Plug>(coc-references)
nmap <leader>rr <Plug>(coc-rename)
nmap <leader>g[ <Plug>(coc-diagnostic-prev)
nmap <leader>g] <Plug>(coc-diagnostic-next)
nmap <silent> <leader>gp <Plug>(coc-diagnostic-prev)
nmap <silent> <leader>gn <Plug>(coc-diagnostic-next)
nnoremap <leader>cr :CocRestart

" OmniSharp and C#
augroup omnisharp_commands
  autocmd!

  " autocmd FileType cs setlocal commentstring="// %s"

  " Show type information automatically when the cursor stops moving.
  " Note that the type is echoed to the Vim command line, and will overwrite
  " any other messages in this space including e.g. ALE linting messages.
  autocmd CursorHold *.cs OmniSharpTypeLookup

  " CoC overrides
  autocmd FileType cs nmap <buffer><Leader>gd <Plug>(omnisharp_go_to_definition)
  autocmd FileType cs nmap <buffer><leader>gi <Plug>(omnisharp_find_implementations)
  autocmd FileType cs nmap <buffer><leader>gr <Plug>(omnisharp_find_usages)

  " The following commands are contextual, based on the cursor position.
  autocmd FileType cs nmap <buffer> <leader>opd <Plug>(omnisharp_preview_definition)
  autocmd FileType cs nmap <buffer> <leader>opi <Plug>(omnisharp_preview_implementations)
  autocmd FileType cs nmap <buffer> <leader>ofx <Plug>(omnisharp_fix_usings)
  " autocmd FileType cs nmap <silent> <buffer> <Leader>osfs <Plug>(omnisharp_find_symbol)
  autocmd FileType cs nmap <silent> <buffer> <C-\> <Plug>(omnisharp_signature_help)
  autocmd FileType cs imap <silent> <buffer> <C-\> <Plug>(omnisharp_signature_help)

  " Navigate up and down by method/property/field
  " autocmd FileType cs nmap <silent> <buffer> [[ <Plug>(omnisharp_navigate_up)
  " autocmd FileType cs nmap <silent> <buffer> ]] <Plug>(omnisharp_navigate_down)
  " Find all code errors/warnings for the current solution and populate the quickfix window
  autocmd FileType cs nmap <buffer> <leader>ogcc <Plug>(omnisharp_global_code_check)
  " Contextual code actions (uses fzf, vim-clap, CtrlP or unite.vim selector when available)
  autocmd FileType cs nmap <buffer> <leader>oo <Plug>(omnisharp_code_actions)
  " autocmd FileType cs xmap <silent> <buffer> <Leader>osca <Plug>(omnisharp_code_actions)
  " Repeat the last code action performed (does not use a selector)
  " autocmd FileType cs nmap <silent> <buffer> <Leader>os. <Plug>(omnisharp_code_action_repeat)
  " autocmd FileType cs xmap <silent> <buffer> <Leader>os. <Plug>(omnisharp_code_action_repeat)

  autocmd FileType cs nmap <buffer> <leader>o= <Plug>(omnisharp_code_format)

  autocmd FileType cs nmap <buffer> <leader>onm <Plug>(omnisharp_rename)

  autocmd FileType cs nmap <buffer> <leader>ore <Plug>(omnisharp_restart_server)
  autocmd FileType cs nmap <buffer> <leader>ost <Plug>(omnisharp_start_server)
  autocmd FileType cs nmap <buffer> <leader>osp <Plug>(omnisharp_stop_server)
augroup END

" Fugitive
nmap <leader>gs :G<CR>


" Shortcutting split navigation
" map <C-h> <C-w>h
" map <C-j> <C-w>j
" map <C-k> <C-w>k
" map <C-l> <C-w>l

" Remove trailing whitespace on save
autocmd BufWritePre * %s/\s\+$//e

" Ripgrep + FZF
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always --smart-case -- '.shellescape(<q-args>), 1,
  \   fzf#vim#with_preview(), <bang>0)

" semver (e.g. in Terraform)
function! Bump(level) abort
    let line=getline('.')
    let regex='\v(0|[1-9]\d*)\.(0|[1-9]\d*)(\.(0|[1-9]\d*))?' "v2.0
    let versions=matchlist(line,regex)
    if len(versions) == 0
        return
    endif
    let major=str2nr(versions[1])
    let minor=str2nr(versions[2])
    let patch= strlen(versions[4]) > 0 ? str2nr(versions[4]) : 0

    if a:level == 'major'
        let major += 1
        let minor = 0
        let patch = 0
    elseif a:level == 'minor'
        let minor += 1
        let patch = 0
    elseif a:level == 'patch'
        let patch += 1
    endif

    let patchOrNot = patch > 0 ? '.' . string(patch) : ''
    let newVersion = 'v' + major . '.' . minor . patchOrNot
    call setline(line('.'), substitute(line, regex, newVersion, ''))
endfunction
command! Bumpa call Bump('major')
command! Bumpi call Bump('minor')
command! Bumpp call Bump('patch')






