vim.opt.guicursor = ""
vim.opt.showmatch = false
vim.opt.hidden = true
vim.opt.errorbells = false

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth= 4
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.wrap = false


vim.opt.swapfile = false
vim.opt.backup = false

vim.opt.undofile = true
vim.opt.undodir= vim.fn.expand("~/.vim/undodir")

vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.smartcase = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8

vim.opt.cmdheight = 2

vim.opt.wildmode= { "longest" , "full" }
vim.opt.wildoptions:append("pum")

vim.opt.colorcolumn = "80"

vim.opt.signcolumn = "yes"
