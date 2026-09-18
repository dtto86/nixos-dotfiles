-- Deno support: denols only activates where lua/config/deno.lua's find_root()
-- resolves one — either a plain Deno project (deno.json/deno.jsonc/deno.lock) or a
-- Supabase-style project where `.vscode/settings.json`'s `deno.enablePaths` scopes
-- Deno to a subtree like `supabase/functions` (what `supabase init`/`supabase
-- functions new` generates). vtsls (lsp-typescript.lua) is excluded from exactly
-- that subtree and otherwise restricted to Node-style projects, so the two servers
-- never both attach to the same buffer — this is nvim-lspconfig's own documented
-- recipe for denols + vtsls/ts_ls coexistence, extended to cover the Supabase case.
--
-- Mason installs the `deno` CLI itself (denols is just `deno lsp` under the hood),
-- same automatic-install path as every other server in lsp.lua.
return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    local deno = require("config.deno")
    local root_pattern = require("lspconfig.util").root_pattern

    opts.servers.denols = {
      root_dir = function(bufnr, on_dir)
        local root = deno.find_root(vim.api.nvim_buf_get_name(bufnr))
        if root then
          on_dir(root)
        end
      end,
      settings = {
        deno = {
          enable = true,
          lint = true,
          unstable = false,
        },
      },
    }

    opts.servers.vtsls = opts.servers.vtsls or {}
    opts.servers.vtsls.root_dir = function(bufnr, on_dir)
      local fname = vim.api.nvim_buf_get_name(bufnr)
      if deno.find_root(fname) then
        return -- this buffer belongs to denols instead
      end
      local root = root_pattern("package.json", "tsconfig.json", "jsconfig.json")(fname)
      if root then
        on_dir(root)
      end
    end
    opts.servers.vtsls.single_file_support = false
  end,
}
