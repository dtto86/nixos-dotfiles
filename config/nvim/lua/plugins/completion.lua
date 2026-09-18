-- blink.cmp, ported from LazyVim's coding.blink extra (minus nvim-cmp compat/AI-cmp
-- source plumbing this config doesn't use — copilot suggestions come from the native
-- LSP inline-completion API instead, wired into the <Tab> fallback chain below).
return {
  {
    "saghen/blink.cmp",
    version = "*",
    dependencies = { "rafamadriz/friendly-snippets" },
    event = { "InsertEnter", "CmdlineEnter" },
    -- without this, other files' `opts.sources.default = {...}` (e.g. sql.lua adding
    -- "dadbod") would deep-merge index-by-index against this file's default list and
    -- silently clobber entries instead of appending
    opts_extend = { "sources.default", "sources.compat" },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      snippets = { preset = "default" },
      appearance = {
        use_nvim_cmp_as_default = false,
        nerd_font_variant = "mono",
      },
      completion = {
        accept = { auto_brackets = { enabled = true } },
        menu = { draw = { treesitter = { "lsp" } } },
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
        ghost_text = { enabled = false },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      cmdline = {
        enabled = true,
        keymap = { preset = "cmdline", ["<Right>"] = false, ["<Left>"] = false },
        completion = {
          list = { selection = { preselect = false } },
          menu = { auto_show = function()
            return vim.fn.getcmdtype() == ":"
          end },
          ghost_text = { enabled = true },
        },
      },
      keymap = {
        preset = "enter",
        ["<C-y>"] = { "select_and_accept" },
        -- accept a pending copilot inline suggestion first, then fall through to
        -- blink's own snippet-forward / normal Tab behavior
        ["<Tab>"] = {
          function()
            return vim.lsp.inline_completion.get()
          end,
          "snippet_forward",
          "fallback",
        },
      },
    },
    config = function(_, opts)
      -- merge, don't replace: sql.lua already added its own `sources.providers.dadbod`
      -- entry by the time this runs (function-valued opts run last), so overwriting
      -- `opts.sources.providers` wholesale here would silently drop it
      opts.sources.per_filetype = vim.tbl_deep_extend("force", opts.sources.per_filetype or {}, {
        lua = { inherit_defaults = true, "lazydev" },
      })
      opts.sources.providers = vim.tbl_deep_extend("force", opts.sources.providers or {}, {
        lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
      })
      require("blink.cmp").setup(opts)
    end,
  },
}
