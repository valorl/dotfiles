require'lspconfig'.gopls.setup{}
require'lspconfig'.terraformls.setup{}
require'lspconfig'.bashls.setup{}
require'lspconfig'.tsserver.setup{}

local yamlls_schemas = (function ()
  local schemas = {}
  local mappings = {
    ["https://raw.githubusercontent.com/argoproj/argo-workflows/master/api/jsonschema/schema.json"] = {
      "kube/ci"
    }
  }

  local cwd = vim.fn.getcwd()

  for url, regexes in pairs(mappings) do
    for _, r in ipairs(regexes) do
      if vim.regex(r):match_str(cwd) then
        if schemas[url] == nil then
          schemas[url] = "/*.yaml"
        end
      end
    end
  end

  return schemas
end)()


vim.lsp.set_log_level("trace")

require'lspconfig'.yamlls.setup{
  autostart = true,
  settings = {
    yaml = {
      trace = {
        server = "verbose"
      },
      -- schemas = yamlls_schemas,
      -- schemas = { kubernetes = "/*.yaml" },
      -- schemaStore = { enable = true},
      schemaDownload = { enable = true },
      validate = true,
    }
  }
}

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
