local dap = prequire("dap")
if dap then
  dap.set_log_level("DEBUG")
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
