return {
  "kristijanhusak/vim-dadbod-ui",
  dependencies = {
    "tpope/vim-dadbod",
    "kristijanhusak/vim-dadbod-completion",
  },
  init = function()
    -- local token = vim.fn.system({ "gcloud", "auth", "print-access-token" })
    --
    -- local dbs = {
    --   entsoe = "19"
    -- }
    --
    -- vim.g.db_ui_use_nerd_fonts = 1
    -- for k, v in pairs(dbs) do
    --   vim.g.dbs = {
    --     [k] = "postgres://vao%40qgt.dk:" .. token .. "@10.44.24." .. v .. ":5432/postgres"
    --   }
    -- end
  end
}
