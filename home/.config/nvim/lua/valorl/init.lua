require("valorl.opts")
require("valorl.keymaps")
require("valorl.autocmd")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = "valorl.lazy",
  change_detection = { notify = false }
})

vim.cmd [[highlight clear SignColumn]]

-- Register the :Ghid command for Visual Mode only
vim.api.nvim_create_user_command('Ghid', function()
  -- Get the visual selection
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

  -- Run the `ghid` command using Plenary's Job
  require("plenary.job"):new({
    command = 'ghid',
    args = { selected_text },
    on_exit = function(j, return_val)
      vim.schedule(function()
        if return_val == 0 then
          local result = table.concat(j:result(), "\n")
          -- Set the result to the system clipboard
          vim.fn.setreg('"', result)
          -- Notify the user
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
end
, {
  range = true,
  nargs = 0,
  desc = 'Process selected text with ghid and copy output to clipboard',
})
