vim.g.mapleader = " "

vim.keymap.set('n', '<C-j>', ':cnext<CR>')
vim.keymap.set('n', '<C-k>', ':cprev<CR>')

vim.keymap.set('n', '<leader>ee', 'oif err != nil {<CR>log.Fatalf("%+v\\n", err)<CR>}<esc>kkI<esc>')

vim.keymap.set('x', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('x', 'K', ":m '<-2<CR>gv=gv")
