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
        -- TODO: test
        pattern = [[.*<(KEYWORDS).*:]]
      }
    }
  },

  {
    "ruifm/gitlinker.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim"
    },
    config = function()
      require("gitlinker").setup({
        callbacks = {
          ["gitlab.neasenergy.com"] = require "gitlinker.hosts".get_gitlab_type_url
        }
      })
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
  -- fun
  -- "github/copilot.vim",
  -- "eandrju/cellular-automaton.nvim",
  -- "github/copilot.vim",
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

  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("refactoring").setup()
    end,
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
}
