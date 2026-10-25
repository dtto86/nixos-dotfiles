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
-- codelldb are provided here, both Mason-managed (not tied to any toolchain).
-- The Mason rust-analyzer is only a fallback: when the project's toolchain ships its
-- own (rustup/devenv `rust-analyzer` component), that one is preferred so it matches
-- the project's rustc. Mason prepends its bin dir to $PATH, so it's skipped explicitly.
local function rust_analyzer_cmd()
  local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
  for _, dir in ipairs(vim.split(vim.env.PATH or "", ":", { trimempty = true })) do
    local exe = dir .. "/rust-analyzer"
    if dir ~= mason_bin and vim.fn.executable(exe) == 1 then
      -- rustup puts a rust-analyzer proxy next to itself even when the component isn't
      -- installed (it then just errors), so ask rustup for the real binary and skip the
      -- proxy if there's none. The timeout guards against rustup auto-installing a
      -- toolchain from rust-toolchain.toml.
      local rustup = dir .. "/rustup"
      if vim.fn.executable(rustup) == 0 then
        return { exe }
      end
      local res = vim.system({ rustup, "which", "rust-analyzer" }, { text = true }):wait(5000)
      local real = vim.trim(res.stdout or "")
      if res.code == 0 and vim.fn.executable(real) == 1 then
        return { real }
      end
    end
  end
  return { "rust-analyzer" }
end

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
          cmd = rust_analyzer_cmd,
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
