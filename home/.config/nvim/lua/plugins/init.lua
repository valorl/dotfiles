local gh = function(x) return "https://github.com/" .. x end
local cb = function(x) return "https://codeberg.org/" .. x end

function _G.prequire(name)
  local ok, mod = pcall(require, name)
  if not ok then
    return nil
  end
  return mod
end

vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local name = ev.data.spec.name
    local kind = ev.data.kind
    if kind ~= "install" and kind ~= "update" then
      return
    end

    if name == "markdown-preview.nvim" then
      if not ev.data.active then
        vim.cmd.packadd("markdown-preview.nvim")
      end
      vim.fn["mkdp#util#install"]()
    elseif name == "nvim-treesitter" then
      if not ev.data.active then
        vim.cmd.packadd("nvim-treesitter")
      end
      vim.cmd("TSUpdate")
    end
  end,
})

vim.pack.add({
  gh("nvim-lua/plenary.nvim"),
  gh("nvim-tree/nvim-web-devicons"),
  gh("gpanders/editorconfig.nvim"),

  gh("neovim/nvim-lspconfig"),
  gh("williamboman/mason.nvim"),
  gh("williamboman/mason-lspconfig.nvim"),
  gh("saghen/blink.cmp"),
  gh("saghen/blink.lib"),
  gh("j-hui/fidget.nvim"),
  gh("aznhe21/actions-preview.nvim"),
  gh("seblj/roslyn.nvim"),

  gh("nvim-treesitter/nvim-treesitter"),

  gh("ellisonleao/gruvbox.nvim"),
  { src = gh("rose-pine/neovim"), name = "rose-pine" },

  gh("numToStr/Comment.nvim"),
  gh("echasnovski/mini.nvim"),
  gh("stevearc/conform.nvim"),

  gh("tpope/vim-fugitive"),
  gh("lewis6991/gitsigns.nvim"),
  gh("akinsho/git-conflict.nvim"),
  gh("ruifm/gitlinker.nvim"),
  gh("rhysd/git-messenger.vim"),
  cb("trevorhauter/gitportal.nvim"),

  gh("folke/snacks.nvim"),
  gh("nvim-lualine/lualine.nvim"),
  gh("stevearc/oil.nvim"),

  gh("grafana/vim-alloy"),
  gh("towolf/vim-helm"),
  gh("kcl-lang/kcl.nvim"),
  gh("rest-nvim/rest.nvim"),
  gh("folke/todo-comments.nvim"),
  gh("fabridamicelli/cronex.nvim"),

  gh("iamcco/markdown-preview.nvim"),
  gh("tpope/vim-eunuch"),

  gh("mfussenegger/nvim-dap"),
  gh("miroshQa/debugmaster.nvim"),
  gh("jbyuki/one-small-step-for-vimkind"),
  gh("leoluz/nvim-dap-go"),
  gh("ravsii/nvim-dap-envfile"),

  { src = gh("xemptuous/sqlua.nvim"), version = "v0.1.1" },
  gh("kristijanhusak/vim-dadbod-ui"),
  gh("tpope/vim-dadbod"),
  gh("kristijanhusak/vim-dadbod-completion"),

  gh("linux-cultist/venv-selector.nvim"),

  gh("ThePrimeagen/99"),
  gh("olimorris/codecompanion.nvim"),
}, { confirm = false })

local lazy_plugins = {
  ["sqlua.nvim"] = true,
  ["venv-selector.nvim"] = true,
}

for _, plug in ipairs(vim.pack.get()) do
  if not lazy_plugins[plug.spec.name] then
    pcall(vim.cmd.packadd, plug.spec.name)
  end
end

require("plugins.colors")
require("plugins.blink")
require("plugins.mason")
require("plugins.treesitter")
require("plugins.snacks")
require("plugins.conform")
require("plugins.dap")
require("plugins.fugitive")
require("plugins.lualine")
require("plugins.mini")
require("plugins.roslyn")
require("plugins.sqlua")
require("plugins.venv-selector")
require("plugins.ninetynine")
require("plugins.codecompanion")
require("plugins.dadbod")
require("plugins.misc")
