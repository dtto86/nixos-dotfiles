-- ~/.config/nvim/lua/plugins/git-scrollbar.lua
return {
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "" }, -- dash-like symbol
        topdelete    = { text = "" },
        changedelete = { text = "▎" },
      },
      signcolumn = true,
    },
  },
  {
    "petertriho/nvim-scrollbar",
    dependencies = { "lewis6991/gitsigns.nvim" },
    config = function()
      local colors = {
        add = "#587c0c",    -- green (added)
        change = "#d7ba7d", -- yellow (modified)
        delete = "#f14c4c", -- red (deleted)
      }

      require("scrollbar").setup({
        show = true, -- hide scrollbar handle
        handle = { text = "" },
        marks = {
          GitAdd    = { text = "│", color = colors.add },
          GitChange = { text = "│", color = colors.change },
          GitDelete = { text = "", color = colors.delete }, -- dash
        },
      })

      -- enable git change markers
      require("scrollbar.handlers.gitsigns").setup()
    end,
  },
}

