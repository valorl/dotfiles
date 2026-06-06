local function trim_trailing_blank_lines(buf)
  while true do
    local n = vim.api.nvim_buf_line_count(buf)
    if n == 0 then return end
    local last = vim.api.nvim_buf_get_lines(buf, n - 1, n, false)[1] or ""
    if last ~= "" then return end
    vim.api.nvim_buf_set_lines(buf, n - 1, n, false, {})
  end
end

local function update(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(buf) then return end

  -- prevent stacking multiple defers
  if vim.b[buf].fugitive_recent_pending then return end
  vim.b[buf].fugitive_recent_pending = true

  vim.defer_fn(function()
    if not vim.api.nvim_buf_is_valid(buf) then return end
    vim.b[buf].fugitive_recent_pending = false

    if vim.bo[buf].filetype ~= "fugitive" then return end
    if vim.b[buf].fugitive_type and vim.b[buf].fugitive_type ~= "index" then return end
    if vim.fn.exists("*FugitiveGitDir") == 0 or vim.fn.FugitiveGitDir() == "" then return end

    local res = vim.fn.FugitiveExecute({
      "log", "-n", "10",
      "--oneline",
      "--no-decorate",
      "@{upstream}"
    })
    if not res or res.exit_status ~= 0 or not res.stdout or #res.stdout == 0 then
      return
    end

    local header = ("Recent commits (HEAD) (%d)"):format(math.min(10, #res.stdout))

    local mod, ro = vim.bo[buf].modifiable, vim.bo[buf].readonly
    vim.bo[buf].modifiable = true
    vim.bo[buf].readonly = false

    -- remove previous injected section
    local cur = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    for i, l in ipairs(cur) do
      if l:match("^Recent commits %(HEAD%) %(%d+%)$") then
        vim.api.nvim_buf_set_lines(buf, i - 1, -1, false, {})
        break
      end
    end

    -- normalize spacing
    trim_trailing_blank_lines(buf)

    vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "", header })
    vim.api.nvim_buf_set_lines(buf, -1, -1, false, res.stdout)

    vim.bo[buf].modifiable = mod
    vim.bo[buf].readonly = ro
  end, 30)
end

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
          local output = vim.fn.systemlist(
            [[git log --pretty='%C(bold yellow)%h%Creset %<(11)%Cgreen%ad %<(15,trunc)%Cblue%al%Creset %s %C(auto)%d%Creset' --date=short --color=always | nl -v0 -w2 -nrn -s' ']])

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

    -- Recent commits in :G
    local group = vim.api.nvim_create_augroup("FugitiveRecentCommits", { clear = true })
    vim.api.nvim_create_autocmd("User", {
      group = group,
      pattern = "FugitiveIndex",
      callback = function(ev)
        update(ev.buf)
      end,
    })
    vim.api.nvim_create_autocmd({ "WinEnter", "FocusGained" }, {
      group = group,
      callback = function(ev)
        update(ev.buf)
      end,
    })
  end
}
