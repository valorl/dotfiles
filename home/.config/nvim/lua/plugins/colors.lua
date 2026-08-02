vim.pack.add({
  "https://github.com/ellisonleao/gruvbox.nvim",
  { src = "https://github.com/rose-pine/neovim", name = "rose-pine" },
}, { confirm = false, load = true })

local gruvbox = prequire("gruvbox")
if gruvbox then
  gruvbox.setup({
    undercurl = true,
    underline = false,
    bold = true,
    italic = {
      strings = true,
      emphasis = false,
      comments = true,
      operators = false,
      folds = false,
    },
    strikethrough = true,
    invert_selection = false,
    invert_signs = false,
    invert_tabline = false,
    invert_intend_guides = false,
    inverse = false,
    contrast = "hard",
    palette_overrides = {},
    overrides = {},
    dim_inactive = false,
    transparent_mode = false,
  })
  vim.cmd.colorscheme("gruvbox")
end

local rose_pine = prequire("rose-pine")
if rose_pine then
  rose_pine.setup({
    variant = "main",
    disable_background = true,
  })
end
