-- Loaded before lazy.nvim starts. No framework defaults exist anymore (this replaces
-- LazyVim's lua/lazyvim/config/options.lua), so this file carries both what used to be
-- "LazyVim's defaults" and this user's own deltas on top of them, merged directly.

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- disable netrw: neo-tree (lua/plugins/neo-tree.lua) replaces it, including opening
-- automatically when nvim is started with a directory argument
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.g.autoformat = false -- format-on-save off by default; eslint's own on_attach still auto-formats where configured

local opt = vim.opt

opt.autowrite = true
opt.clipboard = vim.env.SSH_CONNECTION and "" or "unnamedplus"
opt.completeopt = "menu,menuone,noselect"
opt.conceallevel = 2
opt.confirm = true
opt.cursorline = true
opt.expandtab = true
opt.fillchars = {
  foldopen = "▾",
  foldclose = "▸",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}
opt.foldlevel = 99
opt.foldmethod = "indent"
opt.foldtext = ""
opt.formatexpr = "v:lua.require'conform'.formatexpr()"
opt.formatoptions = "jcroqlnt"
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"
opt.ignorecase = true
opt.inccommand = "nosplit"
opt.jumpoptions = "view"
opt.laststatus = 3
opt.linebreak = true
opt.list = true
opt.mouse = "a"
opt.number = true
opt.pumblend = 10
opt.pumheight = 10
opt.relativenumber = true
opt.ruler = false
opt.scrolloff = 4
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
opt.shiftround = true
opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.showmode = false
opt.sidescrolloff = 8
opt.signcolumn = "yes"
opt.smartcase = true
opt.smarttab = true
opt.smoothscroll = true
opt.splitbelow = true
opt.splitkeep = "screen"
opt.splitright = true
opt.termguicolors = true
opt.timeoutlen = 300
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200
opt.virtualedit = "block"
opt.wildmode = "longest:full,full"
opt.winminwidth = 5

-- personal deltas on top of the above
opt.wrap = true
opt.fixendofline = true -- add trailing newline on save if missing; preserve it if present
opt.spell = true
opt.spelllang = { "en_us" }
opt.autoindent = true
opt.smartindent = true
opt.shiftwidth = 2
opt.tabstop = 2

vim.g.lazyvim_eslint_auto_format = true -- read by lua/plugins/lsp.lua's eslint on_attach

vim.g.markdown_recommended_style = 0

vim.api.nvim_set_hl(0, "CopilotSuggestion", { link = "Comment", default = true })
