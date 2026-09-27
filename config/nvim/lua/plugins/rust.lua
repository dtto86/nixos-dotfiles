-- Rust development: rustaceanvim (LSP via rust-analyzer + DAP + the :RustLsp
-- command family — the modern all-in-one choice for Rust in Neovim). It manages its
-- own LSP client directly via `vim.lsp.start()` rather than through
-- nvim-lspconfig/lsp.lua, so rust_analyzer is deliberately NOT added to lsp.lua's
-- servers table — that would double-attach. crates.nvim handles Cargo.toml
-- (dependency version completion/info, upgrade commands).
--
-- No Rust toolchain (cargo/rustc/rustup) is installed by this config on purpose —
-- this config is meant to be portable across machines, and the user manages
-- cargo/rustc themselves per-project (flake/devenv). Only rust-analyzer and
-- codelldb are provided here, both Mason-managed (not tied to any toolchain) and
-- found on $PATH the same way on any machine.
return {
  {
    "mrcjkb/rustaceanvim",
    version = "^6",
    ft = { "rust" },
    config = function()
      local codelldb = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension"
      local codelldb_path = codelldb .. "/adapter/codelldb"
      local liblldb_path = codelldb .. "/lldb/lib/liblldb.so"

      vim.g.rustaceanvim = {
        tools = {
          hover_actions = { auto_focus = true },
        },
        server = {
          default_settings = {
            ["rust-analyzer"] = {
              check = { command = "clippy" },
              cargo = { allFeatures = true },
            },
          },
          on_attach = function(_, bufnr)
            local function map(lhs, rhs, desc)
              vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
            end
            map("<leader>ca", function()
              vim.cmd.RustLsp("codeAction")
            end, "Code Action")
            map("<leader>cR", function()
              vim.cmd.RustLsp("runnables")
            end, "Runnables")
            map("<leader>dR", function()
              vim.cmd.RustLsp("debuggables")
            end, "Debuggables")
            map("K", function()
              vim.cmd.RustLsp({ "hover", "actions" })
            end, "Hover Actions")
            map("<leader>cM", function()
              vim.cmd.RustLsp("expandMacro")
            end, "Expand Macro")
            map("<leader>cp", function()
              vim.cmd.RustLsp("parentModule")
            end, "Parent Module")
            map("<leader>cE", function()
              vim.cmd.RustLsp("explainError")
            end, "Explain Error")
          end,
        },
        dap = {
          adapter = (vim.fn.executable(codelldb_path) == 1)
              and require("rustaceanvim.config").get_codelldb_adapter(codelldb_path, liblldb_path)
            or nil,
        },
      }
    end,
  },

  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    opts = {
      -- Completion reaches blink.cmp through crates.nvim's in-process LSP
      -- (lsp.completion), not a blink-specific toggle.
      lsp = {
        enabled = true,
        completion = true,
        actions = true,
        hover = true,
        on_attach = function(_, bufnr)
          vim.keymap.set("n", "<leader>cu", function()
            require("crates").upgrade_crate()
          end, { buffer = bufnr, desc = "Upgrade Crate" })
        end,
      },
    },
  },

  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "rust-analyzer", "codelldb" } },
  },

  -- mason-lspconfig's automatic_enable would otherwise start rust_analyzer for the
  -- Mason-installed binary above, double-attaching alongside rustaceanvim.
  {
    "neovim/nvim-lspconfig",
    opts = { servers = { rust_analyzer = { enabled = false } } },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "rust", "ron" } },
  },
}
