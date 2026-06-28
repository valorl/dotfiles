local codecompanion = prequire("codecompanion")
if codecompanion then
  codecompanion.setup({
    opts = {
      log_level = "DEBUG",
    },
    strategies = {
      chat = { adapter = "anthropic" },
      inline = { adapter = "anthropic" },
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
          },
        })
      end,
    },
  })
end
