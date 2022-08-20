local builtin = require('telescope.builtin')

vim.keymap.set("n", "<C-p>", function() builtin.git_files({show_untracked = true}) end, { noremap = true })
vim.keymap.set("n", "<leader>fc", builtin.builtin, { noremap = true })
vim.keymap.set("n", "<leader>ff", builtin.find_files, { noremap = true })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { noremap = true })
vim.keymap.set("n", "<leader>fb", require("telescope").extensions.file_browser.file_browser, { noremap = true })
