require("valorl")

local function change_cwd(path)
  local is_valid = vim.fn.isdirectory(path) == 1
  if is_valid then
    vim.cmd("cd " .. path)
    print("Changed current working directory to: " .. path)
  else
    print("Invalid directory: " .. path)
  end
end
