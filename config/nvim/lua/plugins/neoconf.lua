-- Per-project LSP settings overrides via a .neoconf.json file, ported from LazyVim's
-- lsp.neoconf extra.
return {
  "neovim/nvim-lspconfig",
  dependencies = {
    {
      "folke/neoconf.nvim",
      cmd = "Neoconf",
      opts = {},
    },
  },
}
