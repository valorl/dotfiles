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
  gh("j-hui/fidget.nvim"),
  gh("aznhe21/actions-preview.nvim"),

  gh("numToStr/Comment.nvim"),

  gh("lewis6991/gitsigns.nvim"),
  gh("akinsho/git-conflict.nvim"),
  gh("ruifm/gitlinker.nvim"),
  gh("rhysd/git-messenger.vim"),
  cb("trevorhauter/gitportal.nvim"),

  gh("stevearc/oil.nvim"),

  gh("grafana/vim-alloy"),
  gh("towolf/vim-helm"),
  gh("kcl-lang/kcl.nvim"),
  gh("folke/todo-comments.nvim"),
  gh("fabridamicelli/cronex.nvim"),

  gh("iamcco/markdown-preview.nvim"),
  gh("tpope/vim-eunuch"),
}, { confirm = false, load = true })

require("plugins.colors")
require("plugins.blink")
require("plugins.mason")
require("plugins.treesitter")
require("plugins.snacks")
require("plugins.conform")
require("plugins.dap")
require("plugins.fugitive")
require("plugins.diffs")
require("plugins.lualine")
require("plugins.mini")
require("plugins.sqlua")
require("plugins.venv-selector")
require("plugins.ninetynine")
require("plugins.codecompanion")
require("plugins.dadbod")
require("plugins.misc")
