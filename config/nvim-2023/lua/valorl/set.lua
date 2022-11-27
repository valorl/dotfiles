-- set guicursor=
vim.opt.guicursor = ""
-- set noshowmatch
vim.opt.showmatch = false
-- set hidden
vim.opt.hidden = true
-- set noerrorbells
vim.opt.errorbells = false

-- set tabstop=4 softtabstop=4
-- set shiftwidth=4
-- set expandtab
-- set smartindent
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth= 4
vim.opt.expandtab = true
vim.opt.smartindent = true

-- set nu
-- set relativenumber
vim.opt.nu = true
vim.opt.relativenumber = true

-- set nowrap
vim.opt.wrap = false


-- set noswapfile
-- set nobackup
vim.opt.swapfile = false
vim.opt.backup = false

-- set undodir=~/.vim/undodir
-- set undofile
vim.opt.undofile = true
vim.opt.undodir= "~/.vim/undodir"

-- set nohlsearch
-- set incsearch
-- set smartcase
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.smartcase = true

-- set termguicolors
vim.opt.termguicolors = true

-- set scrolloff=8
vim.opt.scrolloff = 8

-- set cmdheight=2
vim.opt.cmdheight = 2

-- set wildmode=longest,full
-- set wildoptions+=pum
vim.opt.wildmode= { "longest" , "full" }
vim.opt.wildoptions:append("pum")

-- set colorcolumn=80
vim.opt.colorcolumn = 80

vim.opt.signcolumn = "yes"
