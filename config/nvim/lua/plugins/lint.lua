-- nvim-lint core setup, ported from LazyVim's plugins/linting.lua (debounced
-- multi-linter resolution). Per-language linters_by_ft entries are added by the
-- lsp-*.lua/markdown.lua/sql.lua files via opts merging.
return {
  "mfussenegger/nvim-lint",
  event = "BufReadPost",
  opts = {
    events = { "BufWritePost", "BufReadPost", "InsertLeave" },
    linters_by_ft = {},
    linters = {},
  },
  config = function(_, opts)
    local lint = require("lint")
    for name, linter in pairs(opts.linters) do
      if type(linter) == "table" and type(lint.linters[name]) == "table" then
        lint.linters[name] = vim.tbl_deep_extend("force", lint.linters[name], linter)
      else
        lint.linters[name] = linter
      end
    end
    lint.linters_by_ft = opts.linters_by_ft

    local function debounce(ms, fn)
      local timer = vim.uv.new_timer()
      return function(...)
        local argv = { ... }
        timer:start(ms, 0, function()
          timer:stop()
          vim.schedule_wrap(fn)(unpack(argv))
        end)
      end
    end

    local function run_lint()
      local names = lint._resolve_linter_by_ft(vim.bo.filetype)
      names = vim.list_extend({}, names)
      if #names == 0 then
        vim.list_extend(names, lint.linters_by_ft["_"] or {})
      end
      vim.list_extend(names, lint.linters_by_ft["*"] or {})
      names = vim.tbl_filter(function(name)
        return lint.linters[name] ~= nil
      end, names)
      if #names > 0 then
        lint.try_lint(names)
      end
    end

    vim.api.nvim_create_autocmd(opts.events, {
      group = vim.api.nvim_create_augroup("nvim_lint", { clear = true }),
      callback = debounce(100, run_lint),
    })
  end,
}
