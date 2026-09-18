-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  callback = function()
    require("lint").try_lint()
  end,
})

-- Auto-restore the per-directory session saved by persistence.nvim (bundled with
-- LazyVim) when nvim is opened with no args (`nvim`) or just a directory (`nvim .`).
-- A single non-directory arg (e.g. `nvim file.txt`, or `git commit`'s editor
-- invocation) is left alone and opens exactly what was requested.
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local argc = vim.fn.argc()
    local no_args = argc == 0
    local single_dir_arg = argc == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1
    if no_args or single_dir_arg then
      require("persistence").load()
    end
  end,
  nested = true,
})
