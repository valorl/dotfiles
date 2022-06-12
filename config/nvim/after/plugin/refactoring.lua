local nmap = require("valorl.keymap").nmap
local vmap = require("valorl.keymap").vmap

local refactoring = require("refactoring")
local telescope = require("telescope")


vmap { "<leader>rr", "<Esc><cmd>lua require('telescope').extensions.refactoring.refactors()<CR>", {noremap = true} }

vmap { "<leader>rv", ":lua require('refactoring').debug.print_var({})<CR>", {noremap = true} }
nmap { "<leader>rp", ":lua require('refactoring').debug.print_var({})<CR>", {noremap = true} }
nmap { "<leader>rc", ":lua require('refactoring').debug.cleanup({})<CR>", {noremap = true} }

refactoring.setup({
    -- prompt for return type
    prompt_func_return_type = {
        go = true,
    },
    -- prompt for function parameters
    prompt_func_param_type = {
        go = true,
    },
})



