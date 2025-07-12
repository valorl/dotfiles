return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
    -- parser_config.kcl = {
    --   install_info = {
    --     -- url = "https://github.com/kcl-lang/tree-sitter-kcl",
    --     url = "~/repos/github.com/kcl-lang/tree-sitter-kcl",
    --     files = { "src/parser.c", "src/scanner.c" },
    --     branch = "main",
    --   },
    --   filetype = "kcl",
    -- }

    require("nvim-treesitter.configs").setup({
      -- A list of parser names, or "all"
      ensure_installed = "all",
      ignore_install = { "kcl" },

      -- Install parsers synchronously (only applied to `ensure_installed`)
      sync_install = false,

      -- Automatically install missing parsers when entering buffer
      -- Recommendation: set to false if you don"t have `tree-sitter` CLI installed locally
      auto_install = true,

      indent = {
        enable = false
      },

      highlight = {
        -- `false` will disable the whole extension
        enable = true,

        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on "syntax" being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = { "markdown" },
      },
    })

    -- use bash parser for zsh
    vim.treesitter.language.register("bash", "zsh")
  end
}
-- return {
--   { "kcl-lang/kcl.nvim" },
--   {
--     "luckasRanarison/tree-sitter-hyprlang",
--     build = ":TSUpdate kcl",
--     dependencies = {
--       "nvim-treesitter/nvim-treesitter",
--       opts = function(_, opts)
--         require("nvim-treesitter.parsers").get_parser_configs().kcl = {
--           install_info = {
--             url = "https://github.com/kcl-lang/tree-sitter-kcl",
--             files = { "src/parser.c" },
--             branch = "main",
--           },
--           filetype = "kcl",
--         }
--       end,
--     },
--   },
-- }
--
