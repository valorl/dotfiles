local nnoremap = vim.keymap.nnoremap
local inoremap = vim.keymap.inoremap

nnoremap { "<leader>gg", vim.lsp.buf.definition }
nnoremap { "<leader>gi", vim.lsp.buf.implementation }
nnoremap { "<leader>gD", vim.lsp.buf.declaration }

-- nnoremap { "<leader>gsh", vim.lsp.buf.signature_help }
-- inoremap { "<c-\\>", vim.lsp.buf.signature_help }
nnoremap { "<leader>gsh", require('lspsaga.signaturehelp').signature_help }
inoremap { "<c-\\>", require('lspsaga.signaturehelp').signature_help }

nnoremap { "<leader>grr", vim.lsp.buf.references }
nnoremap { "<leader>grn", vim.lsp.buf.rename }
nnoremap { "<leader>gh", vim.lsp.buf.hover }
nnoremap { "<leader>gca", vim.lsp.buf.code_action }
nnoremap { "<leader>gdp", vim.lsp.diagnostic.goto_prev }
nnoremap { "<leader>gdn", vim.lsp.diagnostic.goto_next }
-- TODO: set_loclist ?
