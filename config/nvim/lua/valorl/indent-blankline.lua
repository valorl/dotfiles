require("indent_blankline").setup {
    filetype = {"yaml"},
    space_char_blankline = " ",
    use_treesitter = true,
    show_current_context = true,
    context_patterns = {
        "class", "function", "method", "block", "block_node", "list_literal", "selector",
        "^if", "^table", "if_statement", "while", "for"
    },
    context_highlight_list = { "Normal" }
}

-- vim.cmd [[highlight IndentBlanklineChar guifg=#1d2021 gui=nocombine]]
