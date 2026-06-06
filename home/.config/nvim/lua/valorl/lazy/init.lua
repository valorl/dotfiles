return {
  "nvim-lua/plenary.nvim",
  "gpanders/editorconfig.nvim",
  "rhysd/git-messenger.vim",

  {
    "folke/todo-comments.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      highlight = {
        -- TODO: todo
        -- TODO(vao): todo(vao)
        -- HACK: todo
        -- HACK(vao): todo(vao)
        -- WARN: todo
        -- WARN(vao): todo(vao)
        -- PERF: todo
        -- PERF(vao): todo(vao)
        -- NOTE: todo
        -- NOTE(vao): todo(vao)
        -- TEST: todo
        -- TEST(vao): todo(vao)
        -- BUG: todo
        -- BUG(vao): todo(vao)
        keyword = "bg",
        -- vimgrep regex, supporting the pattern TODO(name):
        pattern = [[.*<((KEYWORDS)%(\(.{-1,}\))?):]],
      }
    }
  },

  {
    "ruifm/gitlinker.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim"
    },
    config = function()
      require("gitlinker").setup()
    end
  },


  {
    "numToStr/Comment.nvim",
    config = function()
      require('Comment').setup()
    end,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    }

  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
  },
  {
    'stevearc/oil.nvim',
    opts = {},
    -- Optional dependencies
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },

  { "grafana/vim-alloy", },

  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end
  },

  { "kcl-lang/kcl.nvim" },
  { "rest-nvim/rest.nvim" },
  { 'fabridamicelli/cronex.nvim', opts = {} },
  { "tpope/vim-eunuch" },
  { 'akinsho/git-conflict.nvim',  version = "*", config = true },
  { url = 'https://codeberg.org/trevorhauter/gitportal.nvim' }
}
