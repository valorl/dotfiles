return {
  "olimorris/codecompanion.nvim",
  opts = {},
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    opts = {
      log_level = "DEBUG"
    },
    strategies = {
      chat = { adapter = "anthropic" },
      inline = { adapter = "anthropic" },
      -- cmd = { adapter = "ollama_deepseek" },
      cmd = { adapter = "anthropic" },
    },

    adapters = {
      ollama_deepseek = function()
        return require("codecompanion.adapters").extend("ollama", {
          name = "ollama_deepseek",
          schema = {
            model = {
              default = "deepseek-coder:6.7b-instruct",
            },
          }
        })
      end
    }
  }
}
