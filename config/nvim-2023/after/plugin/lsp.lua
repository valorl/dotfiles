vim.lsp.set_log_level("trace")

local lspconfig = require('lspconfig')
local configs = require("lspconfig.configs")
local util = require('lspconfig.util')

lspconfig.terraformls.setup{}
lspconfig.bashls.setup{}
lspconfig.tsserver.setup{}
lspconfig.rust_analyzer.setup{}
lspconfig.jsonls.setup{}
lspconfig.rnix.setup{}
lspconfig.dagger.setup{}

require('lspconfig').gopls.setup({
  settings = {
    gopls = {
      gofumpt = true
    }
  }
})

lspconfig.golangci_lint_ls.setup{
  init_options = {
    command = { "golangci-lint", "run", "--out-format", "json",}
  },
  handlers = {
    ["textDocument/publishDiagnostics"] =  function(err, result, ctx, config)
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

lspconfig.yamlls.setup{
  filetypes = {"yaml"},
  autostart = true,
  settings = {
    yaml = {
      trace = {
        server = "verbose"
      },
      schemaDownload = { enable = true },
      validate = true,
    }
  }
}

local pid = vim.fn.getpid()
local omnisharp_bin = "/home/vao/.local/omnisharp/run"
lspconfig.omnisharp.setup{
    cmd = { omnisharp_bin, "--languageserver" , "--hostPID", tostring(pid) };
    handlers = {
      ["textDocument/definition"] = require("omnisharp_extended").handler
    }
}

lspconfig.pyright.setup({
})

require('nlua.lsp.nvim').setup(require('lspconfig'), {})
require "lsp_signature".setup()

if not configs.helm_ls then
  configs.helm_ls = {
    default_config = {
      cmd = {"helm_ls", "serve"},
      filetypes = {'helm'},
      root_dir = function(fname)
        return util.root_pattern('Chart.yaml')(fname)
      end,
    },
  }
end

lspconfig.helm_ls.setup {
  filetypes = {"helm"},
  cmd = {"helm_ls", "serve"},
  root_dir = function(fname)
    return util.root_pattern('Chart.yaml')(fname)
  end,
}

-- borders pls
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
    vim.lsp.handlers.hover,
    { border = "single" }
)

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.go", "*.cs", "*.tf" },
  callback = function()
	  vim.lsp.buf.formatting_sync(nil, 3000)
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = { "*.go" },
	callback = function()
		local params = vim.lsp.util.make_range_params(nil, vim.lsp.util._get_offset_encoding())
		params.context = {only = {"source.organizeImports"}}

		local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
		for _, res in pairs(result or {}) do
			for _, r in pairs(res.result or {}) do
				if r.edit then
					vim.lsp.util.apply_workspace_edit(r.edit, vim.lsp.util._get_offset_encoding())
				else
					vim.lsp.buf.execute_command(r.command)
				end
			end
		end
	end,
})
