return {
  "neovim/nvim-lspconfig",
  opts = {
    -- nil is installed via Nix (home.packages), not Mason: Mason's installer
    -- builds it from source with cargo, which isn't on PATH in this setup.
    servers = {
      nil_ls = {
        mason = false,
      },
    },
  },
}
