-- Nix LSP/format/lint, ported from LazyVim's lang.nix extra. On this NixOS machine
-- `nil` is provided via home.packages (Mason would otherwise build it from source
-- with cargo, which isn't on PATH here) — but this config also runs on non-Nix
-- distros, so the Mason skip is guarded on `nil` actually being on $PATH rather than
-- hard-coded, unlike the old config's `mason = false`.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "nix" } },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        nil_ls = {
          mason = vim.fn.executable("nil") == 0,
        },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        nix = { "nixfmt" },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        nix = { "statix" },
      },
    },
  },
}
