return {
  "linux-cultist/venv-selector.nvim",
  lazy = false,
  branch = "regexp",
  dependencies = {
    "neovim/nvim-lspconfig",
    "nvim-telescope/telescope.nvim"
    -- "mfussenegger/nvim-dap", "mfussenegger/nvim-dap-python", --optional
  },
  config = function()
    require("venv-selector").setup()
  end,
}
