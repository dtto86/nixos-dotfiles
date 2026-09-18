-- Neovim API completion/type-checking for editing this Lua config itself, ported
-- from LazyVim's coding.lua core.
return {
  "folke/lazydev.nvim",
  ft = "lua",
  cmd = "LazyDev",
  opts = {
    library = {
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      { path = "nvim-lspconfig", words = { "lspconfig.settings" } },
    },
  },
}
