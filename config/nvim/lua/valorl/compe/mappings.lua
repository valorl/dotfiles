vim.api.nvim_set_keymap("i", "<c-n>", "compe#complete()", { silent = true, noremap = true, expr = true })
vim.api.nvim_set_keymap("i", "<cr>", 'compe#confirm("<cr>")', { silent = true, noremap = true, expr = true })
vim.api.nvim_set_keymap("i", "<c-e>", 'compe#close("<c-e>")', { silent = true, noremap = true, expr = true })
