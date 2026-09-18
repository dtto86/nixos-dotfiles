-- Tracks the native Copilot LSP client's status (ok/pending/error), written to by
-- lua/plugins/copilot.lua's `didChangeStatus` handler and read by the lualine
-- component in lua/plugins/lualine.lua. Kept as its own small module (like
-- lua/config/deno.lua) instead of cross-file lazy.nvim opts merging, since that
-- would be fragile here: which of copilot.lua's / lualine.lua's function-valued
-- `opts` runs first isn't something worth depending on.
local M = {}

--- client_id -> "ok" | "pending" | "error"
M.by_client = {}

--- @return "ok"|"pending"|"error"|nil status of the attached copilot client for the
--- current buffer, or nil if copilot isn't attached here
function M.get()
  local clients = vim.lsp.get_clients({ name = "copilot", bufnr = 0 })
  if #clients == 0 then
    return nil
  end
  return M.by_client[clients[1].id] or "ok"
end

return M
