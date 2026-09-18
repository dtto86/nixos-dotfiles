-- Incremental LSP rename with a command-preview, ported from LazyVim's
-- editor.inc-rename extra. Owns <leader>cr exclusively (see lsp.lua).
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("inc_rename_keymap", { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not client or not client:supports_method("textDocument/rename", event.buf) then
      return
    end
    vim.keymap.set("n", "<leader>cr", function()
      return ":IncRename " .. vim.fn.expand("<cword>")
    end, { buffer = event.buf, expr = true, desc = "Rename (inc-rename.nvim)" })
  end,
})

return {
  {
    "smjonas/inc-rename.nvim",
    cmd = "IncRename",
    opts = {},
  },
  {
    "folke/noice.nvim",
    opts = {
      presets = { inc_rename = true },
    },
  },
}
