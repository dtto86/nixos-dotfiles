-- Statusline, ported from LazyVim's ui.lua core (LazyVim.lualine.root_dir/
-- pretty_path helpers dropped in favor of plain filename/diagnostics components).
return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  init = function()
    vim.g.lualine_laststatus = vim.o.laststatus
    if vim.fn.argc(-1) > 0 then
      vim.o.statusline = " "
    else
      vim.o.laststatus = 0
    end
  end,
  opts = function()
    vim.o.laststatus = vim.g.lualine_laststatus
    return {
      options = {
        theme = "auto",
        globalstatus = vim.o.laststatus == 3,
        disabled_filetypes = { statusline = { "snacks_dashboard" } },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch" },
        lualine_c = {
          { "diagnostics" },
          { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
          { "filename", path = 1 },
        },
        lualine_x = {
          {
            -- Verified against the official Nerd Fonts glyph registry (the
            -- previous glyph here, U+F06A9, was actually "md-robot", not Copilot
            -- at all — which is why it looked like a Reddit-style mascot):
            --   cod-copilot             U+EC1E  (ok)
            --   cod-copilot_in_progress U+EC4C  (pending)
            --   cod-copilot_error       U+EC4D  (error)
            function()
              local status = require("config.copilot_status").get()
              if status == "error" then
                return "\u{ec4d}"
              elseif status == "pending" then
                return "\u{ec4c}"
              end
              return "\u{ec1e}"
            end,
            cond = function()
              return require("config.copilot_status").get() ~= nil
            end,
          },
          {
            -- U+EC82 = "cod-claude" in the official Nerd Fonts glyph registry
            -- (nerdfonts.com cheat-sheet's "nf-code-claude"); written as a \u{}
            -- escape rather than a pasted glyph so it can't get silently mangled
            -- the way the fillchars icons did earlier in this config.
            function()
              return "\u{ec82}"
            end,
            -- checking package.loaded first (rather than just calling require) avoids
            -- forcing claudecode.nvim to load on every statusline redraw just to ask
            -- its status — only report once it's actually been used this session
            cond = function()
              return package.loaded["claudecode"] and require("claudecode").is_claude_connected()
            end,
          },
          {
            function() return require("noice").api.status.command.get() end,
            cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
          },
          {
            function() return require("noice").api.status.mode.get() end,
            cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
          },
          {
            function() return "  " .. require("dap").status() end,
            cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
          },
          {
            require("lazy.status").updates,
            cond = require("lazy.status").has_updates,
          },
          { "diff" },
        },
        lualine_y = {
          { "progress", separator = " ", padding = { left = 1, right = 0 } },
          { "location", padding = { left = 0, right = 1 } },
        },
        lualine_z = {
          function() return " " .. os.date("%R") end,
        },
      },
      extensions = { "neo-tree", "lazy", "fzf" },
    }
  end,
}
