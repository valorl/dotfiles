vim.pack.add({
  "https://github.com/ThePrimeagen/99",
}, { confirm = false, load = true })

local _99 = prequire("99")
if _99 then
  local cwd = vim.uv.cwd()
  local basename = vim.fs.basename(cwd)
  local ok, err = pcall(_99.setup, {
    provider = _99.Providers.OpenCodeProvider,
    model = "anthropic/claude-sonnet-4-5",

    logger = {
      level = _99.DEBUG,
      path = "/tmp/" .. basename .. ".99.debug",
      print_on_error = true,
    },
    tmp_dir = "./.tmp",

    completion = {
      custom_rules = {
        "scratch/custom_rules/",
      },

      files = {},
    },

    md_files = {
      "AGENT.md",
    },
  })
  if not ok then
    vim.notify("99 setup failed: " .. tostring(err), vim.log.levels.WARN)
  end

  vim.keymap.set("v", "<leader>9v", function()
    _99.visual()
  end)

  vim.keymap.set("n", "<leader>9x", function()
    _99.stop_all_requests()
  end)

  vim.keymap.set("n", "<leader>9s", function()
    _99.search()
  end)
end
