local csharpier_cache = {}
local csharpier_projects = vim.fn.expand("~/.csharpier_projects")

local function should_csharpier(bufnr)
  local git_root = vim.fs.root(bufnr, { ".git" })
  if not git_root then return false end
  local repo_name = vim.fs.basename(git_root):lower()

  if csharpier_cache[repo_name] ~= nil then
    return csharpier_cache[repo_name]
  end

  local f = io.open(csharpier_projects, "r")
  if not f then
    csharpier_cache[repo_name] = false
    return false
  end

  for line in f:lines() do
    local allowed_name = line:match("^%s*(.-)%s*$"):lower() -- Trim whitespace
    if repo_name == allowed_name then
      csharpier_cache[repo_name] = true
      f:close()
      return true
    end
  end

  csharpier_cache[repo_name] = false
  f:close()
  return false
end

return {
  "stevearc/conform.nvim",
  opts = {
    log_level = vim.log.levels.TRACE,
    format_on_save = {
      timeout_ms = 500,
    },
    formatters_by_ft = {
      cs = function(bufnr)
        if should_csharpier(bufnr) then
          return { "csharpier", lsp_format = "never" }
        end
        return { "csharpier", lsp_format = "prefer"}
      end,
    },
  }
}
