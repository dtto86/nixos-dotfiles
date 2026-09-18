-- Python LSP: pyright for types/hover, ruff for lint/format (hover disabled on ruff
-- so pyright's hover wins). Ported from LazyVim's lang.python extra's LSP portion;
-- venv-selector/neotest-python/dap-python live in their own plugin files.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("ruff_no_hover", { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client.name == "ruff" then
      client.server_capabilities.hoverProvider = false
    end
  end,
})

return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      pyright = {},
      ruff = {
        cmd_env = { RUFF_TRACE = "messages" },
        init_options = {
          settings = { logLevel = "error" },
        },
      },
    },
  },
}
