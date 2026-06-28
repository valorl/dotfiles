require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.commands")
require("plugins")
require("config.lsp").setup()

vim.cmd([[highlight clear SignColumn]])
