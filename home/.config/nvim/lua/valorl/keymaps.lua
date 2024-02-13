vim.g.mapleader = " "

vim.keymap.set('n', '<C-j>', ':cnext<CR>')
vim.keymap.set('n', '<C-k>', ':cprev<CR>')

-- vim.keymap.set('n', '<leader><CR>', function()
--     vim.cmd.luafile('~/.config/nvim/init.lua')
-- end)

-- Go if err != nil
vim.keymap.set('n', '<leader>ee', 'oif err != nil {<CR>log.Fatalf("%+v\\n", err)<CR>}<esc>kkI<esc>')

-- Move selection up/down
vim.keymap.set('x', 'J', ':m \'>+1<CR>gv=gv')
vim.keymap.set('x', 'K', ':m \'<-2<CR>gv=gv')
