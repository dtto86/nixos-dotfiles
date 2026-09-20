-- No framework defaults exist anymore (this replaces LazyVim's
-- lua/lazyvim/config/autocmds.lua), so the generally-useful ones are ported here
-- alongside this user's own custom autocmds.

local function augroup(name)
  return vim.api.nvim_create_augroup("user_" .. name, { clear = true })
end

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    (vim.hl or vim.highlight).on_yank()
  end,
})

-- Resize splits if window got resized
vim.api.nvim_create_autocmd("VimResized", {
  group = augroup("resize_splits"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- Go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].last_loc then
      return
    end
    vim.b[buf].last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "PlenaryTestPopup",
    "checkhealth",
    "dap-float",
    "dbout",
    "gitsigns-blame",
    "grug-far",
    "help",
    "lspinfo",
    "neotest-output",
    "neotest-output-panel",
    "neotest-summary",
    "qf",
    "tsplayground",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set("n", "q", function()
        vim.cmd("close")
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buffer = event.buf,
        silent = true,
        desc = "Quit buffer",
      })
    end)
  end,
})

-- Make it easier to close man-files when opened inline
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("man_unlisted"),
  pattern = { "man" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
  end,
})

-- Wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Fix conceallevel for json files
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("json_conceal"),
  pattern = { "json", "jsonc", "json5" },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

-- Wipe out the empty, unnamed scratch buffer nvim starts with once a real file gets
-- opened (e.g. from neo-tree) — otherwise it keeps sitting in the buffer list and
-- shows up as a stray "[No Name]" tab in bufferline forever, since switching a
-- window to a different buffer doesn't delete the one it was showing before.
-- Runs on WinClosed too (not just BufEnter): the scratch buffer is often still
-- visible in a window (e.g. neo-tree's sidebar split) at the moment the real file
-- is entered, so it only becomes safe to wipe once that window goes away, which
-- doesn't itself re-fire BufEnter for the already-active file.
local function wipe_empty_starter_buffer(keep_buf)
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if
      buf ~= keep_buf
      and vim.api.nvim_buf_is_loaded(buf)
      and vim.bo[buf].buftype == ""
      and vim.api.nvim_buf_get_name(buf) == ""
      and not vim.bo[buf].modified
      and vim.api.nvim_buf_line_count(buf) == 1
      and (vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or "") == ""
    then
      local shown_in_a_window = false
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(win) == buf then
          shown_in_a_window = true
          break
        end
      end
      if not shown_in_a_window then
        pcall(vim.api.nvim_buf_delete, buf, {})
      end
    end
  end
end

vim.api.nvim_create_autocmd("BufEnter", {
  group = augroup("wipe_empty_starter_buffer"),
  callback = function(event)
    if vim.bo[event.buf].buftype ~= "" or vim.api.nvim_buf_get_name(event.buf) == "" then
      return -- only clean up once we've landed on a real, named buffer
    end
    wipe_empty_starter_buffer(event.buf)
  end,
})

vim.api.nvim_create_autocmd("WinClosed", {
  group = augroup("wipe_empty_starter_buffer_on_close"),
  callback = function()
    vim.schedule(function()
      wipe_empty_starter_buffer(vim.api.nvim_get_current_buf())
    end)
  end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- Auto-restore the per-directory session saved by persistence.nvim when nvim is
-- opened with no args (`nvim`) or just a directory (`nvim .`). A single non-directory
-- arg (e.g. `nvim file.txt`, or `git commit`'s editor invocation) is left alone.
--
-- Neo-tree's own directory-open (netrw replacement) is deliberately triggered from
-- here too, *after* the session restore rather than via its own independent BufEnter
-- hook: sourcing a saved session rebuilds the whole window layout, and if neo-tree
-- had already opened its sidebar first, that layout rebuild would leave a stray
-- window behind — which is what made "open a file from neo-tree" land in a new
-- window instead of reusing the one restored session window.
vim.api.nvim_create_autocmd("VimEnter", {
  group = augroup("session_restore"),
  callback = function()
    local argc = vim.fn.argc()
    local no_args = argc == 0
    local arg0 = argc >= 1 and vim.fn.argv(0) or nil
    local is_dir = arg0 ~= nil and vim.fn.isdirectory(arg0) == 1

    if no_args or (argc == 1 and is_dir) then
      require("persistence").load()
      -- Buffers brought back by `:source session` are loaded but end up with an
      -- empty 'filetype', and every language server attaches by filetype — so
      -- after `nvim .` none of vtsls/eslint/tailwind/etc. ever started for the
      -- restored files (only filetype-agnostic Copilot did), which is why
      -- completion couldn't offer symbols from other files. Detect them again
      -- once the session has finished loading; this fires FileType, which also
      -- (re)starts treesitter highlighting and LSP attach.
      vim.schedule(function()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          local name = vim.api.nvim_buf_get_name(buf)
          if
            vim.api.nvim_buf_is_loaded(buf)
            and vim.bo[buf].buftype == ""
            and vim.bo[buf].filetype == ""
            and name ~= ""
            and vim.fn.filereadable(name) == 1
          then
            vim.api.nvim_buf_call(buf, function()
              vim.cmd("filetype detect")
            end)
          end
        end
      end)
    end
    if is_dir then
      require("neo-tree.command").execute({ dir = vim.uv.cwd() })
    end
  end,
  nested = true,
})
