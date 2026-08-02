vim.pack.add({
  "https://github.com/echasnovski/mini.nvim",
}, { confirm = false, load = true })

local mini = prequire("mini.ai")
if mini then
  mini.setup({ n_lines = 500 })
end

local mini_surround = prequire("mini.surround")
if mini_surround then
  mini_surround.setup()
end

local mini_statusline = prequire("mini.statusline")
if mini_statusline then
  mini_statusline.setup()
end
