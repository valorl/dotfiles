return {
  "tpope/vim-fugitive",
  config = function()
    local valorl_fugitive = vim.api.nvim_create_augroup("valorl_fugitive", {})

    local autocmd = vim.api.nvim_create_autocmd
    autocmd("BufWinEnter", {
      group = valorl_fugitive,
      pattern = "*",
      callback = function()
        if vim.bo.ft ~= "fugitive" then
          return
        end

        local bufnr = vim.api.nvim_get_current_buf()
        local opts = { buffer = bufnr, remap = false }
        vim.keymap.set("n", "<leader>p", function()
          vim.cmd.Git('push')
        end, opts)

        local opts = { buffer = bufnr, remap = false }
        vim.keymap.set("n", "<leader>P", function()
          local choice = vim.fn.input("Force push? Really?" .. " (y/n): ")
          if choice:lower() == 'y' then
            vim.cmd.Git('push -f')
          end
        end, opts)

        local opts = { buffer = bufnr, remap = false }
        vim.keymap.set("n", "<leader>l", function()
          -- Run the git log command and capture the output
          local output = vim.fn.systemlist([[git log --pretty='%C(bold yellow)%h%Creset %<(11)%Cgreen%ad %<(15,trunc)%Cblue%al%Creset %s %C(auto)%d%Creset' --date=short --color=always | nl -v0 -w2 -nrn -s' ']])

          -- Create vertical split on the right
          vim.cmd("rightbelow vsplit")

          -- Create new scratch buffer
          local log_buf = vim.api.nvim_create_buf(false, true)
          vim.api.nvim_win_set_buf(0, log_buf)

          vim.bo[log_buf].buftype = "nofile"
          vim.bo[log_buf].bufhidden = "wipe"
          vim.bo[log_buf].swapfile = false
          vim.bo[log_buf].filetype = "ansi" -- Requires plugin to render ANSI escape codes

           -- Set contents
          vim.api.nvim_buf_set_lines(log_buf, 0, -1, false, output)
        end, opts)
      end,
    })

    -- autocmd("FileType", {
    --   group = valorl_fugitive,
    --   pattern = "fugitive",
    --   callback = function ()
    --     local win = vim.api.nvim_get_current_win()
    --     local buf = vim.api.nvim_get_current_buf()
    --     if vim.b[buf].gitlog_opened then
    --       return
    --     end
    --     vim.b[buf].gitlog_opened = true
    --
    --     vim.schedule(function()
    --         -- Run the git log command and capture the output
    --       local output = vim.fn.systemlist([[git log --pretty='%C(bold yellow)%h%Creset %<(11)%Cgreen%ad %<(15,trunc)%Cblue%al%Creset %s %C(auto)%d%Creset' --date=short --color=always | nl -v0 -w2 -nrn -s' ']])
    --
    --       -- Create vertical split on the right
    --       vim.cmd("rightbelow vsplit")
    --
    --       -- Create new scratch buffer
    --       local log_buf = vim.api.nvim_create_buf(false, true)
    --       vim.api.nvim_win_set_buf(0, log_buf)
    --
    --       vim.bo[log_buf].buftype = "nofile"
    --       vim.bo[log_buf].bufhidden = "wipe"
    --       vim.bo[log_buf].swapfile = false
    --       vim.bo[log_buf].filetype = "ansi" -- Requires plugin to render ANSI escape codes
    --
    --       -- Set contents
    --       vim.api.nvim_buf_set_lines(log_buf, 0, -1, false, output)
    --
    --       vim.api.nvim_set_current_win(win)
    --   end)
    --   end
    -- })

        -- vim.keymap.set("n", "gu", "<cmd>diffget //2<CR>")
        -- vim.keymap.set("n", "gh", "<cmd>diffget //3<CR>")
  end
}
