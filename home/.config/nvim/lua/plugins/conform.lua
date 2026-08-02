local conform = prequire("conform")
if conform then
  conform.setup({
    log_level = vim.log.levels.TRACE,
    format_on_save = {
      timeout_ms = 500,
    },
  })
end
