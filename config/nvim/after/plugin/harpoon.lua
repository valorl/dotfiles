local nmap = require("valorl.keymap").nmap

local ok, harpoon = pcall(require, "harpoon")
if not ok then
  return
end

harpoon.setup {}

nmap { "<C-h><C-h>", require("harpoon.mark").add_file }
nmap { "<C-h><C-l>", require("harpoon.ui").toggle_quick_menu }

-- harpoons 1 2 3 4
-- keys     7 8 9 0
for file,num in ipairs({7, 8, 9, 0}) do
  nmap {
    string.format("<space>%s", num),
    function()
      require("harpoon.ui").nav_file(file)
    end,
  }
end
