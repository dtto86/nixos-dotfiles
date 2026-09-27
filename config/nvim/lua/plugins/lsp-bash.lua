-- Bash/shell LSP + linting for dotfiles editing. LazyVim doesn't ship a dedicated
-- `lang.sh` extra, so this is hand-written rather than ported; formatting already
-- comes from conform.lua's core `sh = { "shfmt" }` mapping and mason.lua's
-- `shfmt` ensure_installed entry.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        bashls = {},
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "shellcheck" } },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        sh = { "shellcheck" },
      },
    },
  },
}
