vim.keymap.set("i", "<c-n>", "compe#complete()", { silent = true, noremap = true, expr = true })
vim.keymap.set("i", "<cr>", 'compe#confirm("<cr>")', { silent = true, noremap = true, expr = true })
vim.keymap.set("i", "<c-e>", 'compe#close("<c-e>")', { silent = true, noremap = true, expr = true })
