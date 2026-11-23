local M = {}

local enabled_servers = {
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
  "kcl",
  "svelte"
}

function M.setup()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local ok_blink, blink = pcall(require, "blink.cmp")
  if ok_blink then
    capabilities = blink.get_lsp_capabilities(capabilities)
  end

  vim.lsp.config("*", {
    capabilities = capabilities,
  })

  vim.lsp.config("tflint", {
    cmd = { "tflint", "--langserver", "--disable-rule=terraform_required_providers" },
  })

  vim.diagnostic.config({
    float = {
      focusable = false,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
    },
  })

  local original_hover = vim.lsp.handlers.hover
  vim.lsp.handlers["textDocument/hover"] = function(err, result, ctx, config)
    config = config or {}
    config.border = config.border or "single"
    return original_hover(err, result, ctx, config)
  end

  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("valorl-lsp", {}),
    callback = function(args)
      local bufnr = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)

      local opts = { buffer = bufnr, noremap = true }
      vim.keymap.set("n", "<leader>gg", vim.lsp.buf.definition, opts)
      vim.keymap.set("n", "<leader>gi", vim.lsp.buf.implementation, opts)
      vim.keymap.set("n", "<leader>gD", vim.lsp.buf.declaration, opts)
      vim.keymap.set("i", "<c-k>", vim.lsp.buf.signature_help, opts)
      vim.keymap.set("n", "<leader>grr", function() vim.lsp.buf.references({ includeDeclaration = false }) end, opts)
      vim.keymap.set("n", "<leader>grn", vim.lsp.buf.rename, opts)
      vim.keymap.set("n", "<leader>gh", vim.lsp.buf.hover, opts)
      vim.keymap.set("n", "<leader>gca", function() require("actions-preview").code_actions() end, opts)
      vim.keymap.set("n", "<leader>dp", function() vim.diagnostic.jump({ count = -1, float = true }) end, opts)
      vim.keymap.set("n", "<leader>dn", function() vim.diagnostic.jump({ count = 1, float = true }) end, opts)
      vim.keymap.set("n", "<leader>dh", vim.diagnostic.open_float, opts)

      if client and client.name == "gopls" then
        vim.api.nvim_create_autocmd("BufWritePre", {
          group = vim.api.nvim_create_augroup("valorl-lsp-gopls-imports", {}),
          buffer = bufnr,
          callback = function()
            local rp = vim.lsp.util.make_range_params(0, client.offset_encoding)
            local params = {
              textDocument = rp.textDocument,
              range = rp.range,
              context = { only = { "source.organizeImports" } },
            }
            local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
            for cid, res in pairs(result or {}) do
              for _, r in pairs(res.result or {}) do
                if r.edit then
                  local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
                  vim.lsp.util.apply_workspace_edit(r.edit, enc)
                end
              end
            end
          end,
        })
      end
    end,
  })

  vim.lsp.enable(enabled_servers)
end

return M
