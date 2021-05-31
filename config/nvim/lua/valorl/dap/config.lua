local dap = require('dap')

-- dap.adapters.go = {
--   type = 'executable';
--   command = 'node';
--   args = {os.getenv('HOME') .. '/repos/local/github.com/golang/vscode-go/dist/debugAdapter.js'};
-- }
dap.adapters.go = function(callback, config)
  local handle
  local pid_or_err
  local port = 38697
  handle, pid_or_err = vim.loop.spawn(
    "dlv",
    {
      args = {"dap", "--log", "-l", "127.0.0.1:" .. port},
      detached = true
    },
    function(code)
      handle:close()
      print("Delve exited with exit code: " .. code)
    end
    )
  -- Wait 100ms for delve to start
  vim.defer_fn(
    function()
      --dap.repl.open()
      callback({type = "server", host = "127.0.0.1", port = port})
    end,
    100)


  --callback({type = "server", host = "127.0.0.1", port = port})
end

dap.configurations.go = {
  {
    type = 'go';
    name = 'Debug';
    request = 'launch';
    showLog = true;
    program = "${file}";
    env = { "APP_ENV=development" }
    -- dlvToolPath = vim.fn.exepath('dlv')
  },
}

require('dap.ext.vscode').load_launchjs()
