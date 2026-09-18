-- nvim-treesitter core + textobjects + context + autotag, ported from LazyVim's
-- plugins/treesitter.lua and ui/treesitter-context extra. `auto_install = true`
-- (unlike the old Nix-only config) since this config also runs on non-Nix distros
-- where parsers aren't pre-provisioned out-of-band.

-- Expand `<div></div>` onto 3 lines (cursor indented one shiftwidth in on the blank
-- middle line) when <CR> is pressed between `>` and `<`, the same way mini.pairs
-- already does for bracket pairs like `{}`/`()` — mini.pairs itself doesn't treat
-- `>`/`<` as a pair (that would break auto-pairing for comparisons/generics), so this
-- is a small tag-only <CR> override for markup filetypes instead, falling back to
-- mini.pairs' own `cr()` when the cursor isn't between `><`.
--
-- The indent is computed and written explicitly (current line's indent + one
-- shiftwidth) rather than relying on `<C-o>O`'s autoindent/indentexpr: the
-- tsx/jsx treesitter indent queries don't reliably add a level for JSX tag
-- children, so `<C-o>O` alone left the blank line at column 0 instead of indented.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("tag_cr_expand", { clear = true }),
  pattern = { "html", "xml", "javascriptreact", "typescriptreact", "vue", "svelte", "astro" },
  callback = function(ev)
    vim.keymap.set("i", "<CR>", function()
      local col = vim.fn.col(".")
      local line = vim.fn.getline(".")
      if line:sub(col - 1, col - 1) == ">" and line:sub(col, col) == "<" then
        local lnum = vim.fn.line(".")
        local indent_str = line:match("^%s*") or ""
        local indent_unit = vim.bo.expandtab and string.rep(" ", vim.fn.shiftwidth()) or "\t"
        local child_indent = indent_str .. indent_unit
        local head = line:sub(1, col - 1)
        local tail = line:sub(col)
        vim.api.nvim_buf_set_lines(0, lnum - 1, lnum, false, { head, child_indent, indent_str .. tail })
        vim.api.nvim_win_set_cursor(0, { lnum + 1, #child_indent })
        return
      end
      local keys = require("mini.pairs").cr()
      vim.api.nvim_feedkeys(keys, "n", false)
    end, { buffer = ev.buf })
  end,
})

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    -- without this, every other file's `opts.ensure_installed = {...}` (lsp-vue.lua,
    -- lsp-docker.lua, lsp-nix.lua, sql.lua, kulala.lua, octo.lua, lsp-python.lua)
    -- would deep-merge index-by-index against this list and silently clobber entries
    opts_extend = { "ensure_installed" },
    opts = {
      indent = { enable = true },
      highlight = { enable = true },
      ensure_installed = {
        "bash",
        "c",
        "diff",
        "dockerfile",
        "git_config",
        "gitcommit",
        "git_rebase",
        "gitignore",
        "gitattributes",
        "html",
        "javascript",
        "jsdoc",
        "json",
        "json5",
        "lua",
        "luadoc",
        "luap",
        "markdown",
        "markdown_inline",
        "nix",
        "printf",
        "python",
        "query",
        "regex",
        "sql",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "vue",
        "css",
        "xml",
        "yaml",
      },
    },
    config = function(_, opts)
      -- The "main" branch of nvim-treesitter dropped the old `.configs` module and
      -- its `highlight`/`indent`/`ensure_installed` opts handling entirely — `setup()`
      -- now only understands `install_dir`. Everything else (installing missing
      -- parsers, turning on highlighting/indent per filetype) has to be done by hand,
      -- ported from LazyVim's own (more elaborate) config function for this same API.
      local TS = require("nvim-treesitter")
      TS.setup({ install_dir = opts.install_dir })

      local installed = {}
      for _, lang in ipairs(TS.get_installed("parsers")) do
        installed[lang] = true
      end
      local missing = vim.tbl_filter(function(lang)
        return not installed[lang]
      end, opts.ensure_installed or {})
      if #missing > 0 then
        TS.install(missing)
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
        callback = function(ev)
          local lang = vim.treesitter.language.get_lang(ev.match) or ev.match
          if not pcall(vim.treesitter.language.add, lang) then
            -- parser not installed yet (e.g. a filetype outside ensure_installed on
            -- a fresh, non-Nix machine) — install it now instead of staying plain-text
            TS.install({ lang }):await(function()
              pcall(vim.treesitter.language.add, lang)
              if opts.highlight and opts.highlight.enable ~= false then
                pcall(vim.treesitter.start, ev.buf, lang)
              end
            end)
            return
          end
          if opts.highlight and opts.highlight.enable ~= false then
            pcall(vim.treesitter.start, ev.buf, lang)
          end
          if opts.indent and opts.indent.enable ~= false and vim.bo[ev.buf].indentexpr == "" then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = "VeryLazy",
    opts = {
      move = {
        enable = true,
        set_jumps = true,
        keys = {
          goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
          goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer" },
          goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
          goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer" },
        },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter-textobjects").setup(opts)

      local function attach(buf)
        local moves = vim.tbl_get(opts, "move", "keys") or {}
        for method, keymaps in pairs(moves) do
          for key, query in pairs(keymaps) do
            vim.keymap.set({ "n", "x", "o" }, key, function()
              require("nvim-treesitter-textobjects.move")[method](query, "textobjects")
            end, { buffer = buf, silent = true })
          end
        end
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter_textobjects", { clear = true }),
        callback = function(ev)
          attach(ev.buf)
        end,
      })
      vim.tbl_map(attach, vim.api.nvim_list_bufs())
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    event = "BufReadPost",
    opts = {},
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "BufReadPost",
    opts = { mode = "cursor", max_lines = 3 },
    keys = {
      {
        "<leader>ut",
        function()
          local tsc = require("treesitter-context")
          if tsc.enabled() then
            tsc.disable()
          else
            tsc.enable()
          end
        end,
        desc = "Toggle Treesitter Context",
      },
    },
  },
}
