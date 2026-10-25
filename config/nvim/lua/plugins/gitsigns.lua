-- gitsigns.nvim: hunk keymaps ported from LazyVim's editor.lua core, sign glyphs and
-- nvim-scrollbar wiring ported unchanged from the previous config's
-- lua/plugins/git-scrollbar.lua.
return {
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      signcolumn = true,
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns
        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc, silent = true })
        end

        map("n", "]h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gs.nav_hunk("next")
          end
        end, "Next Hunk")
        map("n", "[h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gs.nav_hunk("prev")
          end
        end, "Prev Hunk")
        map("n", "]H", function() gs.nav_hunk("last") end, "Last Hunk")
        map("n", "[H", function() gs.nav_hunk("first") end, "First Hunk")
        map({ "n", "x" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
        map({ "n", "x" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
        map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
        map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
        map("n", "<leader>ghB", function() gs.blame() end, "Blame Buffer")
        map("n", "<leader>ghd", gs.diffthis, "Diff This")
        map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
      end,
    },
  },
  {
    "petertriho/nvim-scrollbar",
    -- v2 isn't on `main` yet (it lands there 2026-11-16); pin `refactor/v2`
    -- to get it now. Drop this `branch` line once v2 replaces main upstream.
    branch = "refactor/v2",
    -- v2 config (opts shape changed, see migration guide at
    -- https://github.com/petertriho/nvim-scrollbar/blob/refactor/v2/docs/migration.md):
    -- `handlers = { gitsigns = true }` is now `providers = { gitsigns = true }`
    -- and no longer needs a separate require("scrollbar.handlers.gitsigns").setup()
    -- call; mark `color` is now a `highlight = { fg = ... }` table. GitDelete's
    -- old empty text ("") isn't valid in v2 (marks need positive display width),
    -- so it uses v2's own default glyph instead.
    event = "BufReadPre",
    dependencies = { "lewis6991/gitsigns.nvim" },
    opts = {
      providers = { gitsigns = true },
      marks = {
        GitAdd = { text = "│", highlight = { fg = "#587c0c" } },
        GitChange = { text = "│", highlight = { fg = "#d7ba7d" } },
        GitDelete = { text = "▁", highlight = { fg = "#f14c4c" } },
      },
    },
  },
}
