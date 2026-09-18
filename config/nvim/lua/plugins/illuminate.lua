-- Highlights other instances of the word under the cursor (LSP/treesitter/regexp),
-- ported from LazyVim's editor.illuminate extra.
return {
  "RRethy/vim-illuminate",
  event = "BufReadPost",
  opts = {
    delay = 200,
    large_file_cutoff = 2000,
    large_file_overrides = { providers = { "lsp" } },
  },
  config = function(_, opts)
    require("illuminate").configure(opts)

    vim.keymap.set("n", "<leader>ux", function()
      local m = require("illuminate")
      if require("illuminate.engine").is_paused() then
        m.resume()
      else
        m.pause()
      end
    end, { desc = "Toggle Illuminate" })

    local function map(key, dir, buffer)
      vim.keymap.set("n", key, function()
        require("illuminate")["goto_" .. dir .. "_reference"](false)
      end, { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. " Reference", buffer = buffer })
    end
    map("]]", "next")
    map("[[", "prev")
    vim.api.nvim_create_autocmd("FileType", {
      callback = function()
        local buffer = vim.api.nvim_get_current_buf()
        map("]]", "next", buffer)
        map("[[", "prev", buffer)
      end,
    })
  end,
  keys = {
    { "]]", desc = "Next Reference" },
    { "[[", desc = "Prev Reference" },
  },
}
