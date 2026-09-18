-- return {
--   {
--     "nvimdev/dashboard-nvim",
--     event = "VimEnter",
--     dependencies = { {'nvim-tree/nvim-web-devicons'}},
--     opts = {
--       theme = 'doom',
--       config = {
--         header = {}, --your header
--         center = {
--           {
--             icon = ' ',
--             icon_hl = 'Title',
--             desc = 'Find File           ',
--             desc_hl = 'String',
--             key = 'b',
--             keymap = 'SPC f f',
--             key_hl = 'Number',
--             key_format = ' %s', -- remove default surrounding `[]`
--             action = 'lua print(2)'
--           },
--           {
--             icon = ' ',
--             desc = 'Find Dotfiles',
--             key = 'f',
--             keymap = 'SPC f d',
--             key_format = ' %s', -- remove default surrounding `[]`
--             action = 'lua print(3)'
--           },
--         },
--         footer = {}  --your footer
--       }
--     }
--   },
-- }
--
return {
  "snacks.nvim",
  opts = {
    dashboard = {
      -- dashboard configuration
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
  d:::::::::ddd::::d       tt:::::::::::tt    tt:::::::::::tt oo:::::::::::oo    88:::::::::88      66:::::::::66   
   ddddddddd   ddddd         ttttttttttt        ttttttttttt     ooooooooooo        888888888          666666666     
                                                                                                                    
        ]],
        keys = function()
          return {}
        end,
      },
      sections = {
        { section = "header" },
      }
    },
  },
}
