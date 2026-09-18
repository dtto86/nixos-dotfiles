return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    opts.formatters = {
      -- add or remove formatters
      -- stylua is included by default
      -- you can also specify options for each formatter
      -- stylua = { extra_args = { "--indent-type", "Spaces", "--indent-width", "2" } },
      -- prettier = {},
      -- eslint = {},
      -- gofumpt = {},
      -- goimports = {},
      -- rustfmt = {},
      -- shfmt = {},
      -- autopep8 = {},
      -- black = {},
      prettier = {
        prepend_args = { "--insert-final-newline" }
      }
    }
    opts.formatters_by_ft = {
      -- use the same formatter for every filetype
      -- "*": { "stylua" },
      -- use different formatters for specific filetypes
      -- lua = { "stylua" },
      -- javascript = { "prettier", "eslint" },
      -- javascriptreact = { "prettier", "eslint" },
      -- typescript = { "prettier", "eslint" },
      -- typescriptreact = { "prettier", "eslint" },
      -- vue = { "prettier", "eslint" },
      -- json = { "prettier" },
      -- css = { "prettier" },
      -- html = { "prettier" },
      -- markdown = { "prettier" },
      -- yaml = { "prettier" },
      javascript = { "eslint" },
      javascriptreact = { "eslint" },
      typescript = { "eslint" },
      typescriptreact = { "eslint" },
      vue = { "prettier", "eslint" },
      json = { "prettier" },
      css = { "prettier" },
      html = { "prettier" },
      markdown = { "prettier" },
      yaml = { "prettier" },
    }
    return opts
  end,
  -- opts = {
  --   formatters = {
  --     prettier = {
  --       prepend_args = { "--insert-final-newline" }
  --     },
  --     -- eslint = {
  --     --   prepend_args = { "--insert-final-newline" }
  --     -- }
  --   },
  --   formatters_by_ft = {
  --     javascript = { "eslint" },
  --     javascriptreact = { "eslint" },
  --     typescript = { "eslint" },
  --     typescriptreact = { "eslint" },
  --     vue = { "prettier", "eslint" },
  --     json = { "prettier" },
  --     css = { "prettier" },
  --     html = { "prettier" },
  --     markdown = { "prettier" },
  --     yaml = { "prettier" },
  --   },
  -- }
}
