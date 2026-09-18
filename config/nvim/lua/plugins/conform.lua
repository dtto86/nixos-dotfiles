-- conform.nvim: core setup ported from LazyVim's plugins/formatting.lua, plus this
-- user's own formatter choices ported from the previous config's lua/plugins/conform.lua
-- (eslint-only for JS/TS since eslint-lspconfig.lua's on_attach already formats them,
-- prettier elsewhere).
return {
  "stevearc/conform.nvim",
  dependencies = { "mason.nvim" },
  lazy = true,
  cmd = "ConformInfo",
  keys = {
    {
      "<leader>cF",
      function()
        require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
      end,
      mode = { "n", "x" },
      desc = "Format Injected Langs",
    },
  },
  opts = {
    default_format_opts = {
      timeout_ms = 3000,
      async = false,
      quiet = false,
      lsp_format = "fallback",
    },
    formatters_by_ft = {
      lua = { "stylua" },
      fish = { "fish_indent" },
      sh = { "shfmt" },
      -- deno_fmt only "counts" inside a Deno project (see its `condition` below,
      -- shared with lsp-deno.lua's denols/vtsls split), so `stop_after_first` falls
      -- through to eslint for ordinary Node projects.
      javascript = { "deno_fmt", "eslint", stop_after_first = true },
      javascriptreact = { "deno_fmt", "eslint", stop_after_first = true },
      typescript = { "deno_fmt", "eslint", stop_after_first = true },
      typescriptreact = { "deno_fmt", "eslint", stop_after_first = true },
      vue = { "prettier", "eslint" },
      json = { "prettier" },
      css = { "prettier" },
      html = { "prettier" },
      yaml = { "prettier" },
    },
    formatters = {
      injected = { options = { ignore_errors = true } },
      prettier = {
        prepend_args = { "--insert-final-newline" },
      },
      deno_fmt = {
        condition = function(_, ctx)
          return require("config.deno").find_root(ctx.filename) ~= nil
        end,
      },
    },
  },
  config = function(_, opts)
    require("conform").setup(opts)
  end,
}
