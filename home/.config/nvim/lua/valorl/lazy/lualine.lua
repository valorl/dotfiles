return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local dmode_enabled = false
    vim.api.nvim_create_autocmd("User", {
      pattern = "DebugModeChanged",
      callback = function(args)
        dmode_enabled = args.data.enabled
      end
    })

    local function dbg()
      return {
        function() return "DEBUG" end,
        color = { fg = "white", bg = "red" },
        fmt = function() return dmode_enabled end,
      }
    end
    require("lualine").setup({
      options = {
        globalstatus = true,
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
      },
      sections = {
        lualine_a = {
          {
            "mode",
            fmt = function(str) return dmode_enabled and "DEBUG" or str end,
            color = function(tb) return dmode_enabled and { fg = "black", bg = "red", gui = "bold" } or tb end,
          },
        },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = { 'filename' },
        lualine_x = { 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' }
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { 'filename' },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {}
      },
    })
  end
}
