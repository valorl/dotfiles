require'lspconfig'.gopls.setup{}
require'lspconfig'.terraformls.setup{}
require'lspconfig'.yamlls.setup{}
require'lspconfig'.bashls.setup{}


require'lspconfig'.omnisharp.setup{
    cmd = { "/opt/omnisharp/run", "--languageserver" , "--hostPID", tostring(vim.fn.getpid()) };
}
