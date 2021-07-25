require'lspconfig'.gopls.setup{}
require'lspconfig'.terraformls.setup{}
require'lspconfig'.yamlls.setup{}
require'lspconfig'.bashls.setup{}

local pid = vim.fn.getpid()
local omnisharp_bin = "/home/vao/.local/omnisharp/run"
require'lspconfig'.omnisharp.setup{
    cmd = { omnisharp_bin, "--languageserver" , "--hostPID", tostring(pid) };
}

require('nlua.lsp.nvim').setup(require('lspconfig'), {})

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
    require("lspsaga.hover").handler,
    -- vim.lsp.handlers.hover,
    { border = "single" }
)

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
    -- require("lspsaga.hover").handler,
    vim.lsp.handlers.signature_help,
    { border = "single" }
)
