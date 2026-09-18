-- Indentation guides, ported from LazyVim's ui.indent-blankline extra.
return {
  "lukas-reineke/indent-blankline.nvim",
  event = "BufReadPost",
  main = "ibl",
  opts = {
    indent = { char = "│", tab_char = "│" },
    scope = { show_start = false, show_end = false },
    exclude = {
      filetypes = {
        "Trouble",
        "help",
        "lazy",
        "mason",
        "neo-tree",
        "notify",
        "snacks_dashboard",
        "snacks_notif",
        "snacks_terminal",
        "snacks_win",
        "trouble",
      },
    },
  },
  keys = {
    {
      "<leader>ug",
      function()
        local enabled = require("ibl.config").get_config(0).enabled
        require("ibl").setup_buffer(0, { enabled = not enabled })
      end,
      desc = "Toggle Indent Guides",
    },
  },
}
