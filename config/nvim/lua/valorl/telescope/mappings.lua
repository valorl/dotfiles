local telescope = require('telescope.builtin')

vim.keymap.set("n", "<C-p>", telescope.git_files, { noremap = true })
vim.keymap.set("n", "<leader>fc", require('telescope.command').load_command, { noremap = true })
vim.keymap.set("n", "<leader>ff", telescope.find_files, { noremap = true })
vim.keymap.set("n", "<leader>fg", telescope.live_grep, { noremap = true })
vim.keymap.set("n", "<leader>fb", require("telescope").extensions.file_browser.file_browser, { noremap = true })
