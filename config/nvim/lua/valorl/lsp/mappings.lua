vim.keymap.set("n", "<leader>gg", vim.lsp.buf.definition, { noremap = true })
vim.keymap.set("n", "<leader>gi", vim.lsp.buf.implementation, { noremap = true })
vim.keymap.set("n", "<leader>gD", vim.lsp.buf.declaration, { noremap = true })

-- nnoremap { "<leader>gsh", vim.lsp.buf.signature_help }
-- inoremap { "<c-\\>", vim.lsp.buf.signature_help }
-- vim.keymap.set("n", "<leader>gh", require('lspsaga.hover').render_hover_doc, { noremap = true })
vim.keymap.set("i", "<c-\\>", vim.lsp.buf.signature_help, { noremap = true })

vim.keymap.set("n", "<leader>grr", vim.lsp.buf.references, { noremap = true })
vim.keymap.set("n", "<leader>grn", vim.lsp.buf.rename, { noremap = true })
vim.keymap.set("n", "<leader>gh", vim.lsp.buf.hover, { noremap = true })
vim.keymap.set("n", "<leader>gca", vim.lsp.buf.code_action, { noremap = true })
vim.keymap.set("n", "<leader>gdp", vim.lsp.diagnostic.goto_prev, { noremap = true })
vim.keymap.set("n", "<leader>gdn", vim.lsp.diagnostic.goto_next, { noremap = true })
-- TODO: set_loclist ?
