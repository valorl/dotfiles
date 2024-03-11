local function create_autocmd_format(group, bufnr, client)
  vim.api.nvim_create_autocmd('BufWritePre', {
    group = group,
    buffer = bufnr,
    callback = function()
      -- goimports
      -- https://github.com/golang/tools/blob/master/gopls/doc/vim.md#imports-and-formatting
      if client.name == 'gopls' then
        local params = vim.lsp.util.make_range_params()
        params.context = { only = { "source.organizeImports" } }
        -- buf_request_sync defaults to a 1000ms timeout. Depending on your
        -- machine and codebase, you may want longer. Add an additional
        -- argument after params if you find that you have to write the file
        -- twice for changes to be saved.
        -- E.g., vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
        local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
        for cid, res in pairs(result or {}) do
          for _, r in pairs(res.result or {}) do
            if r.edit then
              local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
              vim.lsp.util.apply_workspace_edit(r.edit, enc)
            end
          end
        end
      end
      vim.lsp.buf.format { async = false }
    end,
  })
end

return {
  "neovim/nvim-lspconfig",
  dependencies = {
    { "folke/neodev.nvim", opts = {} },
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",

    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",

    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",

    "j-hui/fidget.nvim",
  },

  config = function()
    vim.api.nvim_create_autocmd("LspAttach", {
      group = require("valorl.autocmd").group,
      callback = function(args)
        local bufnr = args.buf

        local opts = {
          buffer = bufnr,
          noremap = true
        }
        vim.keymap.set("n", "<leader>gg", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "<leader>gi", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "<leader>gD", vim.lsp.buf.declaration, opts)

        vim.keymap.set("i", "<c-k>", vim.lsp.buf.signature_help, opts)

        vim.keymap.set("n", "<leader>grr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "<leader>grn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>gh", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>gca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>dp", vim.diagnostic.goto_prev, opts)
        vim.keymap.set("n", "<leader>dn", vim.diagnostic.goto_next, opts)
        vim.keymap.set("n", "<leader>dh", vim.diagnostic.open_float, opts)


        local client_id = args.data.client_id
        local client = vim.lsp.get_client_by_id(client_id)

        local group = vim.api.nvim_create_augroup("valorl-lsp-attach-format", {})
        create_autocmd_format(group, bufnr, client)
      end

    })


    local cmp = require('cmp')
    local cmp_lsp = require("cmp_nvim_lsp")
    local capabilities = vim.tbl_deep_extend(
      "force",
      {},
      vim.lsp.protocol.make_client_capabilities(),
      cmp_lsp.default_capabilities())

    require("fidget").setup({})
    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = {
        "terraformls", "tflint",
        "gopls", "golangci_lint_ls",
        "pyright",
        "yamlls",
        "lua_ls",
        "rust_analyzer",
        "tsserver",
      },
      handlers = {
        function(server_name) -- default handler (optional)
          require("lspconfig")[server_name].setup {
            capabilities = capabilities
          }
        end,

        ["gopls"] = function()
          require("lspconfig").gopls.setup {
            capabilities = capabilities,
            settings = {
              gopls = {
                gofumpt = true,
                experimentalPostfixCompletions = true,
                staticcheck = true,
              }
            },
            init_options = {
              usePlaceholders = true
            }
          }
        end,

        ["golangci_lint_ls"] = function()
          require("lspconfig").golangci_lint_ls.setup {
            -- exclude "typecheck" double noise
            handlers = {
              ["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
                local filtered = {}
                for _, d in ipairs(result["diagnostics"]) do
                  if d["source"] ~= "typecheck" then
                    table.insert(filtered, d)
                  end
                end

                result["diagnostics"] = filtered
                vim.lsp.handlers["textDocument/publishDiagnostics"](err, result, ctx, config)
              end
            }
          }
        end,

        ["lua_ls"] = function()
          require("lspconfig").lua_ls.setup {
            capabilities = capabilities,
            settings = {
              Lua = {
                diagnostics = {
                  globals = { "vim", "it", "describe", "before_each", "after_each" },
                  disable = { "missing-fields" }
                }
              }
            }
          }
        end,
      }
    })

    local cmp_select = { behavior = cmp.SelectBehavior.Select }

    cmp.setup({
      snippet = {
        expand = function(args)
          require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
        ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        ["<C-Space>"] = cmp.mapping.complete(),
      }),
      sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' }, -- For luasnip users.
      }, {
        { name = 'buffer' },
      })
    })

    vim.diagnostic.config({
      -- update_in_insert = true,
      float = {
        focusable = false,
        style = "minimal",
        border = "rounded",
        source = "always",
        header = "",
        prefix = "",
      },
    })

    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
      vim.lsp.handlers.hover,
      { border = "single" }
    )
  end
}
