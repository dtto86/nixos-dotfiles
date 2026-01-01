-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt
local global = vim.g
local api = vim.api

opt.wrap = true

global.autoformat = false

global.lazyvim_eslint_auto_format = true
-- global.lazyvim_prettier_needs_config = true

opt.eol = false -- Don't fix end of line on save

api.nvim_set_hl(0, "CopilotSuggestion", { link = "Comment", default = true })

opt.spell = true
opt.spelllang = { "en_us" }

global.ai_cmp = false

opt.autoindent = true
opt.smartindent = true
opt.smarttab = true
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
