vim.api.nvim_create_user_command("SQLua", function(args)
  pcall(vim.api.nvim_del_user_command, "SQLua")
  vim.cmd.packadd("sqlua.nvim")
  local sqlua = prequire("sqlua")
  if sqlua then
    sqlua.setup()
  end
  if vim.api.nvim_get_commands({})["SQLua"] then
    vim.cmd("SQLua" .. (args.args and (#args.args > 0 and (" " .. args.args) or "") or ""))
  end
end, { nargs = "*", desc = "Open SQLua (lazy)" })
