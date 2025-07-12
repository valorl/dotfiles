return {
  'xemptuous/sqlua.nvim',
  lazy = true,
  cmd = 'SQLua',
  tag = "v0.1.1",
  config = function()
    require('sqlua').setup()

    Connection = require("sqlua.connection")

    local token = vim.fn.system({ "gcloud", "auth", "print-access-token" })
    token = string.gsub(token, '%s+', '') -- trim whitespace

    local dbs = {
      ["entso-scraper"] = "19"
    }

    for k, v in pairs(dbs) do
      local url = "postgres://vao%40qgt.dk:" .. token .. "@10.44.24." .. v .. ":5432/postgres"
      vim.fn.setreg("+", url)
      -- Connection.add(url, k)
      -- Connection.setup(k, url)
    end
  end
}
