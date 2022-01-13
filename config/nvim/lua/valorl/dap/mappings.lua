local dap = require('dap')

vim.keymap.set("n", "<leader>dc", dap.continue, { noremap = true })
vim.keymap.set("n", "<leader>do", dap.step_over, { noremap = true })
vim.keymap.set("n", "<leader>di", dap.step_into, { noremap = true })
vim.keymap.set("n", "<leader>dO", dap.step_out, { noremap = true })
vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { noremap = true })
vim.keymap.set("n", "<leader>dB", function() dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, { noremap = true })
vim.keymap.set("n", "<leader>dr", dap.repl.open, { noremap = true })
