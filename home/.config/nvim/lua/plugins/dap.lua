local function getCurrentFileDirName()
  local fullPath = vim.fn.expand("%:p:h")
  local dirName = fullPath:match("([^/\\]+)$")
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
  local debugPath = vim.fn.expand("%:p:h") .. "/bin/Debug"
  if not file_exists(debugPath) then
    return vim.fn.getcwd()
  end
  local command = 'find "' .. debugPath .. '" -maxdepth 1 -type d -name "*net*" -print -quit'
  local handle = io.popen(command)
  local result = handle:read("*a")
  handle:close()
  result = result:gsub("[\r\n]+$", "")
  if result == "" then
    return debugPath
  else
    local potentialDllPath = result .. "/" .. getCurrentFileDirName() .. ".dll"
    if file_exists(potentialDllPath) then
      return potentialDllPath
    else
      return result == "" and debugPath or result .. "/"
    end
  end
end

local dap = prequire("dap")
if dap then
  dap.set_log_level("DEBUG")

  dap.adapters.coreclr = {
    type = "executable",
    command = "/usr/local/netcoredbg",
    args = { "--interpreter=vscode" },
  }

  dap.configurations.cs = {
    {
      type = "coreclr",
      name = "NetCoreDbg: Launch",
      request = "launch",
      cwd = "${fileDirname}",
      program = function()
        return get_dll_path()
      end,
      env = function()
        local files = vim.fn.glob(".*.env", false, true)
        local inputs = {}
        for i, file in ipairs(files) do
          table.insert(inputs, i .. " | " .. file)
        end
        local idx = vim.fn.inputlist(inputs)
        if idx < 1 then
          return nil
        end

        return require("nvim-dap-envfile").load_env_file(files[idx])
      end,
    },
    {
      type = "coreclr",
      name = "Attach to testhost",
      request = "attach",
      processId = function()
        return require("dap.utils").pick_process({
          filter = function(proc)
            return (proc.name or ""):match("dotnet")
          end,
          label = function(proc)
            return string.format("%d | %s", proc.pid, proc.name or "?")
          end,
        })
      end,
    },
  }
end

local dm = prequire("debugmaster")
if dm then
  vim.keymap.set({ "n", "v" }, "<leader>;", dm.mode.toggle, { nowait = true })
  vim.keymap.set("t", "<C-\\>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
  dm.plugins.osv_integration.enabled = true
end

local dap_go = prequire("dap-go")
if dap_go then
  dap_go.setup({
    dap_configurations = {
      {
        type = "go",
        name = "Debug args",
        request = "launch",
        program = "${fileDirname}",
        args = require("dap-go").get_arguments,
      },
    },
  })
end

local dap_envfile = prequire("nvim-dap-envfile")
if dap_envfile then
  dap_envfile.setup({ add_dap_listener = true })
end
