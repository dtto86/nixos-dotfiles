-- Tailwind CSS LSP, ported from LazyVim's lang.tailwind extra.
return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    opts.servers.tailwindcss = {
      settings = {
        tailwindCSS = {
          includeLanguages = {
            elixir = "html-eex",
            eelixir = "html-eex",
            heex = "html-eex",
          },
        },
      },
    }
    -- exclude markdown from the server's bundled default filetypes
    local default_filetypes = vim.deepcopy((vim.lsp.config.tailwindcss or {}).filetypes or {})
    opts.servers.tailwindcss.filetypes = vim.tbl_filter(function(ft)
      return ft ~= "markdown"
    end, default_filetypes)
  end,
}
