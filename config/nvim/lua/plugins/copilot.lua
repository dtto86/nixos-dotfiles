-- Native Copilot LSP integration (inline ghost-text suggestions via Neovim's own
-- vim.lsp.inline_completion API), ported from LazyVim's ai.copilot-native extra.
-- Requires Neovim >= 0.12. Acceptance is wired into blink.cmp's <Tab> fallback chain
-- in completion.lua rather than a separate accept key.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("copilot_inline", { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not client or client.name ~= "copilot" then
      return
    end
    vim.schedule(function()
      vim.lsp.inline_completion.enable()
    end)
  end,
})

vim.keymap.set({ "i", "n" }, "<M-]>", function()
  vim.lsp.inline_completion.select({ count = 1 })
end, { desc = "Next Copilot Suggestion" })
vim.keymap.set({ "i", "n" }, "<M-[>", function()
  vim.lsp.inline_completion.select({ count = -1 })
end, { desc = "Prev Copilot Suggestion" })

return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      copilot = {
        -- feeds lua/config/copilot_status.lua, which the lualine component in
        -- lualine.lua reads to show an icon (and its ok/pending/error state).
        --
        -- Payload confirmed from the actual installed copilot-language-server
        -- bundle (~/.local/share/nvim/mason/packages/copilot-language-server):
        -- `didChangeStatus` sends { busy, kind, message, command }, where kind is
        -- "Normal" | "Error" | "Warning". This fires on essentially every keystroke
        -- (tied to completion request lifecycle, not just auth state), so kind
        -- flicking to "Error" transiently is normal and NOT necessarily a sign-in
        -- problem — only notify on the *transition* into an error state, once, and
        -- show the server's own message instead of guessing what's wrong.
        handlers = {
          didChangeStatus = function(err, res, ctx)
            if err or not res then
              return
            end
            local status = require("config.copilot_status")
            local new_status = (res.kind and res.kind ~= "Normal") and "error" or res.busy and "pending" or "ok"
            local was_error = status.by_client[ctx.client_id] == "error"
            status.by_client[ctx.client_id] = new_status
            if new_status == "error" and not was_error then
              vim.notify("Copilot: " .. (res.message or res.kind or "error"), vim.log.levels.WARN)
            end
          end,
        },
      },
    },
  },
}
