vim.pack.add({
  "https://github.com/saghen/blink.lib",
  "https://github.com/saghen/blink.cmp",
}, { confirm = false, load = true })

local blink = prequire("blink.cmp")
if blink then
  blink.build():pwait()
  blink.setup({
    keymap = {
      preset = "default",
      ["<C-p>"] = { "select_prev", "fallback" },
      ["<C-n>"] = { "select_next", "fallback" },
      ["<CR>"] = { "accept", "fallback" },
      ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
    },
    sources = {
      default = { "lsp", "path", "buffer" },
    },
  })
end
