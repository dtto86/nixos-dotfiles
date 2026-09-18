-- snacks.nvim, scoped down from LazyVim's full usage to just the modules this config
-- actually wants: the dashboard (custom header ported unchanged from the previous
-- config's lua/plugins/dashboard.lua), the notifier (top-right popup notifications,
-- matching LazyVim's default look — noice.nvim only owns cmdline/message UI, not
-- vim.notify()), and a couple of small utilities used by global keymaps.lua
-- (bufdelete/terminal/zen/lazygit/gitbrowse), and neo-tree's rename hook.
-- indent/statuscolumn/scope/scroll/words are explicitly left off since
-- indent-blankline already owns that area.
return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  keys = {
    { "<leader>n", function() Snacks.notifier.show_history() end, desc = "Notification History" },
    { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
  },
  opts = {
    bigfile = { enabled = true },
    quickfile = { enabled = true },
    bufdelete = { enabled = true },
    terminal = { enabled = true },
    zen = { enabled = true },
    lazygit = { enabled = true },
    gitbrowse = { enabled = true },
    rename = { enabled = true },
    -- top-right popup notifications, LazyVim's default position
    notifier = { enabled = true, timeout = 3000 },

    indent = { enabled = false },
    input = { enabled = false },
    scope = { enabled = false },
    scroll = { enabled = false },
    statuscolumn = { enabled = false },
    words = { enabled = false },

    dashboard = {
      preset = {
        header = [[

            dddddddd
            d::::::d        tttt               tttt                                888888888             66666666
            d::::::d     ttt:::t            ttt:::t                              88:::::::::88          6::::::6
            d::::::d     t:::::t            t:::::t                            88:::::::::::::88       6::::::6
            d:::::d      t:::::t            t:::::t                           8::::::88888::::::8     6::::::6
    ddddddddd:::::dttttttt:::::tttttttttttttt:::::ttttttt       ooooooooooo   8:::::8     8:::::8    6::::::6
  dd::::::::::::::dt:::::::::::::::::tt:::::::::::::::::t     oo:::::::::::oo 8:::::8     8:::::8   6::::::6
 d::::::::::::::::dt:::::::::::::::::tt:::::::::::::::::t    o:::::::::::::::o 8:::::88888:::::8   6::::::6
d:::::::ddddd:::::dtttttt:::::::tttttttttttt:::::::tttttt    o:::::ooooo:::::o  8:::::::::::::8   6::::::::66666
d::::::d    d:::::d      t:::::t            t:::::t          o::::o     o::::o 8:::::88888:::::8 6::::::::::::::66
d:::::d     d:::::d      t:::::t            t:::::t          o::::o     o::::o8:::::8     8:::::86::::::66666:::::6
d:::::d     d:::::d      t:::::t            t:::::t          o::::o     o::::o8:::::8     8:::::86:::::6     6:::::6
d:::::d     d:::::d      t:::::t    tttttt  t:::::t    tttttto::::o     o::::o8:::::8     8:::::86:::::6     6:::::6
d::::::ddddd::::::dd     t::::::tttt:::::t  t::::::tttt:::::to:::::ooooo:::::o8::::::88888::::::86::::::66666::::::6
 d:::::::::::::::::d     tt::::::::::::::t  tt::::::::::::::to:::::::::::::::o 88:::::::::::::88  66:::::::::::::66
  d:::::::::ddd::::d       tt:::::::::::tt    tt:::::::::::tt oo:::::::::::oo    88:::::::::::::88      66:::::::::66
   ddddddddd   ddddd         ttttttttttt        ttttttttttt     ooooooooooo        888888888          666666666

        ]],
      },
      sections = {
        { section = "header" },
      },
    },
  },
}
