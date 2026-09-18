-- Core LSP setup: mason.nvim + mason-lspconfig.nvim + nvim-lspconfig, universal
-- keymaps, diagnostics and inlay hints. Per-language server settings live in their
-- own lua/plugins/lsp-<lang>.lua files, which only set `opts.servers.<name>` (or
-- extend it) — this file is the only one that actually enables servers, ported from
-- LazyVim's lua/lazyvim/plugins/lsp/init.lua without its cross-file `keys` merging
-- machinery (that's replaced by per-server LspAttach autocmds where needed, see
-- lsp-typescript.lua / lsp-python.lua).
return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason.nvim",
      { "mason-org/mason-lspconfig.nvim", config = function() end },
    },
    -- IMPORTANT: this must merge with (not replace) the incoming `opts`, since every
    -- lsp-<lang>.lua file's plain-table `opts.servers.<name>` is deep-merged into it
    -- by lazy.nvim *before* this function runs (function-valued opts always run last).
    -- Returning a fresh table here instead of merging would silently discard every
    -- per-language server config from every lsp-*.lua file.
    opts = function(_, opts)
      return vim.tbl_deep_extend("force", {
        diagnostics = {
          underline = true,
          update_in_insert = false,
          virtual_text = { spacing = 4, source = "if_many", prefix = "●" },
          severity_sort = true,
          signs = {
            text = {
              [vim.diagnostic.severity.ERROR] = "E",
              [vim.diagnostic.severity.WARN] = "W",
              [vim.diagnostic.severity.HINT] = "H",
              [vim.diagnostic.severity.INFO] = "I",
            },
          },
        },
        inlay_hints = { enabled = true, exclude = { "vue" } },
        folds = { enabled = true },
        ---@type table<string, vim.lsp.Config|{mason?:boolean, enabled?:boolean}>
        servers = {
          ["*"] = {
            capabilities = {
              workspace = { fileOperations = { didRename = true, willRename = true } },
            },
          },
          stylua = { enabled = false },
          lua_ls = {
            settings = {
              Lua = {
                workspace = { checkThirdParty = false },
                codeLens = { enable = true },
                completion = { callSnippet = "Replace" },
                doc = { privateName = { "^_" } },
                hint = {
                  enable = true,
                  setType = false,
                  paramType = true,
                  paramName = "Disable",
                  semicolon = "Disable",
                  arrayIndex = "Disable",
                },
              },
            },
          },
        },
      }, opts or {})
    end,
    ---@param opts {diagnostics: vim.diagnostic.Opts, inlay_hints: {enabled: boolean, exclude: string[]}, folds: {enabled: boolean}, servers: table}
    config = function(_, opts)
      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

      -- universal keymaps, set on every LSP attach
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp_keymaps", { clear = true }),
        callback = function(event)
          local buf = event.buf
          local client = assert(vim.lsp.get_client_by_id(event.data.client_id))

          local function map(mode, lhs, rhs, desc, has)
            if has and not client:supports_method(has, buf) then
              return
            end
            vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc, silent = true })
          end

          -- gd/gr/gI/gy are owned by fzf-lua.lua instead (fuzzy-picker goto lists),
          -- so they aren't bound here to avoid two competing mappings.
          map("n", "gD", vim.lsp.buf.declaration, "Goto Declaration")
          map("n", "K", vim.lsp.buf.hover, "Hover")
          map("n", "gK", vim.lsp.buf.signature_help, "Signature Help", "textDocument/signatureHelp")
          map("i", "<c-k>", vim.lsp.buf.signature_help, "Signature Help", "textDocument/signatureHelp")
          map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action", "textDocument/codeAction")
          -- <leader>cr (Rename) is owned by lsp-inc-rename.lua instead (cmdline-preview
          -- rename), so it isn't bound here to avoid two competing mappings.
          if client:supports_method("textDocument/codeLens", buf) then
            -- vim.lsp.codelens.refresh() is deprecated (nvim 0.12+): .enable() both
            -- turns codelens on for this buffer and keeps it auto-refreshed via the
            -- buffer's decoration provider, so no BufEnter/CursorHold autocmd is
            -- needed to keep re-triggering it anymore.
            vim.lsp.codelens.enable(true, { bufnr = buf })
            map({ "n", "x" }, "<leader>cc", vim.lsp.codelens.run, "Run Codelens")
            map("n", "<leader>cC", function()
              vim.lsp.codelens.enable(true, { bufnr = buf })
            end, "Refresh & Display Codelens")
          end
          map("n", "<leader>co", function()
            vim.lsp.buf.code_action({
              apply = true,
              context = { only = { "source.organizeImports" }, diagnostics = {} },
            })
          end, "Organize Imports", "textDocument/codeAction")

          -- inlay hints
          if
            opts.inlay_hints.enabled
            and client:supports_method("textDocument/inlayHint", buf)
            and not vim.tbl_contains(opts.inlay_hints.exclude, vim.bo[buf].filetype)
          then
            vim.lsp.inlay_hint.enable(true, { bufnr = buf })
          end

          -- folding (built-in LSP folding, nvim 0.10+)
          if opts.folds.enabled and client:supports_method("textDocument/foldingRange", buf) then
            vim.wo.foldmethod = "expr"
            vim.wo.foldexpr = "v:lua.vim.lsp.foldexpr()"
          end
        end,
      })

      -- merge blink.cmp's completion capabilities into every server
      local capabilities = vim.tbl_deep_extend(
        "force",
        vim.lsp.protocol.make_client_capabilities(),
        require("blink.cmp").get_lsp_capabilities(),
        (opts.servers["*"] or {}).capabilities or {}
      )
      vim.lsp.config("*", { capabilities = capabilities })

      -- enable each configured server, either directly (mason = false) or via
      -- mason-lspconfig's automatic_enable once it's installed
      local ensure_installed = {} ---@type string[]
      local mason_exclude = {} ---@type string[]
      for server, sopts in pairs(opts.servers) do
        if server ~= "*" then
          sopts = sopts == true and {} or sopts
          if sopts.enabled == false then
            mason_exclude[#mason_exclude + 1] = server
          else
            vim.lsp.config(server, sopts)
            if sopts.mason == false then
              mason_exclude[#mason_exclude + 1] = server
              vim.lsp.enable(server)
            else
              ensure_installed[#ensure_installed + 1] = server
            end
          end
        end
      end

      require("mason-lspconfig").setup({
        ensure_installed = ensure_installed,
        automatic_enable = { exclude = mason_exclude },
      })
    end,
  },

  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    -- without this, lsp-docker.lua/markdown.lua/sql.lua's `opts.ensure_installed`
    -- would deep-merge index-by-index against this list instead of appending
    opts_extend = { "ensure_installed" },
    opts = {
      ensure_installed = { "stylua", "shfmt" },
    },
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require("mason-registry")
      mr:on("package:install:success", function()
        vim.defer_fn(function()
          require("lazy.core.handler.event").trigger({
            event = "FileType",
            buf = vim.api.nvim_get_current_buf(),
          })
        end, 100)
      end)
      mr.refresh(function()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end)
    end,
  },
}
