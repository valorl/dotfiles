local function getCurrentFileDirName()
  local fullPath = vim.fn.expand('%:p:h')      -- Get the full path of the directory containing the current file
  local dirName = fullPath:match("([^/\\]+)$") -- Extract the directory name
  return dirName
end

local function file_exists(name)
  local f = io.open(name, "r")
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

local function get_dll_path()
  local debugPath = vim.fn.expand('%:p:h') .. '/bin/Debug'
  if not file_exists(debugPath) then
    return vim.fn.getcwd()
  end
  local command = 'find "' .. debugPath .. '" -maxdepth 1 -type d -name "*net*" -print -quit'
  local handle = io.popen(command)
  local result = handle:read("*a")
  handle:close()
  result = result:gsub("[\r\n]+$", "") -- Remove trailing newline and carriage return
  if result == "" then
    return debugPath
  else
    local potentialDllPath = result .. '/' .. getCurrentFileDirName() .. '.dll'
    if file_exists(potentialDllPath) then
      return potentialDllPath
    else
      return result == "" and debugPath or result .. '/'
    end
    --        return result .. '/' -- Adds a trailing slash if a net folder is found
  end
end


return {
  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require("dap")
      dap.set_log_level("DEBUG")

      dap.adapters.coreclr = {
        type = 'executable',
        command = '/usr/local/netcoredbg',
        args = { '--interpreter=vscode' }
      }

      dap.configurations.cs = {
        {
          type = 'coreclr',
          name = 'NetCoreDbg: Launch',
          request = 'launch',
          cwd = '${fileDirname}',
          program = function()
            return get_dll_path()
          end,
        },
      }
    end
  },
  { "rcarriga/nvim-dap-ui", enabled = false },
  {
    "miroshQa/debugmaster.nvim",
    -- osv is needed if you want to debug neovim lua code. Also can be used
    -- as a way to quickly test-drive the plugin without configuring debug adapters
    dependencies = {
      "mfussenegger/nvim-dap",
      "jbyuki/one-small-step-for-vimkind",
    },
    config = function()
      local dm = require("debugmaster")
      -- make sure you don't have any other keymaps that starts with "<leader>d" to avoid delay
      -- Alternative keybindings to "<leader>d" could be: "<leader>m", "<leader>;"
      vim.keymap.set({ "n", "v" }, "<leader>;", dm.mode.toggle, { nowait = true })
      -- If you want to disable debug mode in addition to leader+d using the Escape key:
      -- vim.keymap.set("n", "<Esc>", dm.mode.disable)
      -- This might be unwanted if you already use Esc for ":noh"
      vim.keymap.set("t", "<C-\\>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

      dm.plugins.osv_integration.enabled = true -- needed if you want to debug neovim lua code
    end
  },
  {
    "leoluz/nvim-dap-go",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      require("dap-go").setup({
        dap_configurations = {
          {
            -- Must be "go" or it will be ignored by the plugin
            type = "go",
            name = "Debug args",
            request = "launch",
            program = "${fileDirname}",
            args = require("dap-go").get_arguments,
          },
        },
      })
    end
  }
}
