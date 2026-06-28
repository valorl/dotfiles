vim.api.nvim_create_user_command('Ghid', function()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local lines = vim.api.nvim_buf_get_text(
    0,
    start_pos[2] - 1,
    start_pos[3] - 1,
    end_pos[2] - 1,
    end_pos[3],
    {}
  )
  local selected_text = table.concat(lines, "\n")
  print(selected_text)

  require("plenary.job"):new({
    command = 'ghid',
    args = { selected_text },
    on_exit = function(j, return_val)
      vim.schedule(function()
        if return_val == 0 then
          local result = table.concat(j:result(), "\n")
          vim.fn.setreg('"', result)
          vim.schedule(function()
            vim.notify("ghid output copied to clipboard", vim.log.levels.INFO)
          end)
        else
          local error_msg = table.concat(j:stderr_result(), "\n")
          vim.schedule(function()
            vim.notify("ghid command failed: " .. error_msg, vim.log.levels.ERROR)
          end)
        end
      end)
    end,
  }):start()
end, {
  range = true,
  nargs = 0,
  desc = 'Process selected text with ghid and copy output to clipboard',
})
