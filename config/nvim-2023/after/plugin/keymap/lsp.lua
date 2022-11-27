local nnoremap = require("valorl.keymap").nnoremap
local inoremap = require("valorl.keymap").inoremap
local silent = { silent = true }

nnoremap("K", vim.lsp.buf.hover, silent)

nnoremap("<leader>lg", vim.lsp.buf.definition, silent)
nnoremap("<leader>li", vim.lsp.buf.implementation, silent)
nnoremap("<leader>lrr", vim.lsp.buf.references, silent)
nnoremap("<leader>lrn", vim.lsp.buf.rename, silent)
nnoremap("<leader>lca", vim.lsp.buf.code_action, silent)

nnoremap("<leader>ld", vim.diagnostic.open_float, silent)
nnoremap("[d", vim.diagnostic.goto_prev, silent)
nnoremap("]d", vim.diagnostic.goto_next, silent)

inoremap("<c-\\>", vim.lsp.buf.signature_help, silent)
