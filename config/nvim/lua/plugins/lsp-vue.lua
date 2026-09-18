-- Vue SFC support: vue_ls (Volar) + vtsls in hybrid/takeover mode, ported from
-- LazyVim's lang.vue extra. Requires lsp-typescript.lua's vtsls base config; lazy.nvim
-- merges `opts` across files targeting the same plugin, so load order doesn't matter.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "vue", "css" } },
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers.vue_ls = {}
      opts.servers.vtsls = opts.servers.vtsls or {}
      opts.servers.vtsls.filetypes = opts.servers.vtsls.filetypes or {}
      if not vim.tbl_contains(opts.servers.vtsls.filetypes, "vue") then
        table.insert(opts.servers.vtsls.filetypes, "vue")
      end
      opts.servers.vtsls.settings = opts.servers.vtsls.settings or {}
      opts.servers.vtsls.settings.vtsls = opts.servers.vtsls.settings.vtsls or {}
      opts.servers.vtsls.settings.vtsls.tsserver = opts.servers.vtsls.settings.vtsls.tsserver or {}
      opts.servers.vtsls.settings.vtsls.tsserver.globalPlugins = {
        {
          name = "@vue/typescript-plugin",
          location = vim.fn.stdpath("data") .. "/mason/packages/vue-language-server/node_modules/@vue/language-server",
          languages = { "vue" },
          configNamespace = "typescript",
          enableForWorkspaceTypeScriptVersions = true,
        },
      }
    end,
  },
}
