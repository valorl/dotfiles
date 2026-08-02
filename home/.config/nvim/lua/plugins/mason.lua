vim.pack.add({
  "https://github.com/williamboman/mason.nvim",
  "https://github.com/williamboman/mason-lspconfig.nvim",
}, { confirm = false, load = true })

local mason = prequire("mason")
if mason then
  mason.setup({
    registries = {
      "github:mason-org/mason-registry",
      "github:Crashdummyy/mason-registry",
    },
  })
end

local mason_lspconfig = prequire("mason-lspconfig")
if mason_lspconfig then
  mason_lspconfig.setup({
    ensure_installed = {
      "lua_ls",
      "gopls",
      "pyright",
      "yamlls",
      "rust_analyzer",
      "ts_ls",
      "terraformls",
      "tflint",
      "helm_ls",
      "jqls",
    },
    automatic_enable = false,
  })
end
