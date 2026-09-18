-- fzf-lua, ported from LazyVim's editor.fzf extra. LazyVim's smart "root dir"
-- picking (LazyVim.root(), walks up for a .git/lsp root) is simplified here to plain
-- cwd — a small, transparent trade-off rather than porting that whole util module.

-- gd/gr/gI/gy: owns these instead of lsp.lua's plain vim.lsp.buf.* (see lsp.lua),
-- since these are the ones actually worth pickers for.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("fzf_lua_lsp_keys", { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not client then
      return
    end
    local buf = event.buf
    local function map(lhs, rhs, desc, has)
      if has and not client:supports_method(has, buf) then
        return
      end
      vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = desc, silent = true })
    end
    map("gd", "<cmd>FzfLua lsp_definitions jump1=true ignore_current_line=true<cr>", "Goto Definition", "textDocument/definition")
    map("gr", "<cmd>FzfLua lsp_references jump1=true ignore_current_line=true<cr>", "References")
    map("gI", "<cmd>FzfLua lsp_implementations jump1=true ignore_current_line=true<cr>", "Goto Implementation")
    map("gy", "<cmd>FzfLua lsp_typedefs jump1=true ignore_current_line=true<cr>", "Goto Type Definition")
  end,
})

return {
  {
    "ibhagwan/fzf-lua",
    cmd = "FzfLua",
    opts = function(_, opts)
      local fzf = require("fzf-lua")
      local config = fzf.config
      local actions = fzf.actions

      config.defaults.keymap.fzf["ctrl-q"] = "select-all+accept"
      config.defaults.keymap.fzf["ctrl-u"] = "half-page-up"
      config.defaults.keymap.fzf["ctrl-d"] = "half-page-down"
      config.defaults.keymap.builtin["<c-f>"] = "preview-page-down"
      config.defaults.keymap.builtin["<c-b>"] = "preview-page-up"
      config.defaults.actions.files["ctrl-t"] = require("trouble.sources.fzf").actions.open

      return {
        "default-title",
        fzf_colors = true,
        fzf_opts = { ["--no-scrollbar"] = true },
        defaults = { formatter = "path.dirname_first" },
        files = {
          cwd_prompt = false,
          actions = {
            ["alt-i"] = { actions.toggle_ignore },
            ["alt-h"] = { actions.toggle_hidden },
          },
        },
        grep = {
          actions = {
            ["alt-i"] = { actions.toggle_ignore },
            ["alt-h"] = { actions.toggle_hidden },
          },
        },
      }
    end,
    config = function(_, opts)
      if opts[1] == "default-title" then
        local function fix(t)
          t.prompt = t.prompt ~= nil and " " or nil
          for _, v in pairs(t) do
            if type(v) == "table" then
              fix(v)
            end
          end
          return t
        end
        opts = vim.tbl_deep_extend("force", fix(require("fzf-lua.profiles.default-title")), opts)
        opts[1] = nil
      end
      require("fzf-lua").setup(opts)
    end,
    init = function()
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "fzf-lua" } })
        require("fzf-lua").register_ui_select()
        return vim.ui.select(...)
      end
    end,
    keys = {
      { "<leader>,", "<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>", desc = "Switch Buffer" },
      -- <leader>b alone (not followed by another key within timeoutlen) opens this;
      -- <leader>bd/bo/bp/etc. (bound elsewhere) still work as their own sequences.
      { "<leader>b", "<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>", desc = "Buffers" },
      { "<leader>/", function() require("fzf-lua").live_grep() end, desc = "Grep (cwd)" },
      { "<leader>:", "<cmd>FzfLua command_history<cr>", desc = "Command History" },
      { "<leader><space>", function() require("fzf-lua").files() end, desc = "Find Files (cwd)" },
      { "<leader>fb", "<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>", desc = "Buffers" },
      { "<leader>ff", function() require("fzf-lua").files() end, desc = "Find Files (cwd)" },
      { "<leader>fg", "<cmd>FzfLua git_files<cr>", desc = "Find Files (git-files)" },
      { "<leader>fr", "<cmd>FzfLua oldfiles<cr>", desc = "Recent" },
      { "<leader>gc", "<cmd>FzfLua git_commits<CR>", desc = "Commits" },
      { "<leader>gd", "<cmd>FzfLua git_diff<cr>", desc = "Git Diff (files)" },
      { "<leader>gl", "<cmd>FzfLua git_commits<CR>", desc = "Commits" },
      { "<leader>gs", "<cmd>FzfLua git_status<CR>", desc = "Status" },
      { "<leader>gS", "<cmd>FzfLua git_stash<cr>", desc = "Git Stash" },
      { '<leader>s"', "<cmd>FzfLua registers<cr>", desc = "Registers" },
      { "<leader>s/", "<cmd>FzfLua search_history<cr>", desc = "Search History" },
      { "<leader>sa", "<cmd>FzfLua autocmds<cr>", desc = "Auto Commands" },
      { "<leader>sb", "<cmd>FzfLua lines<cr>", desc = "Buffer Lines" },
      { "<leader>sc", "<cmd>FzfLua command_history<cr>", desc = "Command History" },
      { "<leader>sC", "<cmd>FzfLua commands<cr>", desc = "Commands" },
      { "<leader>sd", "<cmd>FzfLua diagnostics_workspace<cr>", desc = "Diagnostics" },
      { "<leader>sD", "<cmd>FzfLua diagnostics_document<cr>", desc = "Buffer Diagnostics" },
      { "<leader>sg", function() require("fzf-lua").live_grep() end, desc = "Grep (cwd)" },
      { "<leader>sh", "<cmd>FzfLua help_tags<cr>", desc = "Help Pages" },
      { "<leader>sH", "<cmd>FzfLua highlights<cr>", desc = "Search Highlight Groups" },
      { "<leader>sj", "<cmd>FzfLua jumps<cr>", desc = "Jumplist" },
      { "<leader>sk", "<cmd>FzfLua keymaps<cr>", desc = "Key Maps" },
      { "<leader>sm", "<cmd>FzfLua marks<cr>", desc = "Jump to Mark" },
      { "<leader>sR", "<cmd>FzfLua resume<cr>", desc = "Resume" },
      { "<leader>sq", "<cmd>FzfLua quickfix<cr>", desc = "Quickfix List" },
      { "<leader>sw", function() require("fzf-lua").grep_cword() end, desc = "Word (cwd)" },
      { "<leader>sw", function() require("fzf-lua").grep_visual() end, mode = "x", desc = "Selection (cwd)" },
      { "<leader>uC", function() require("fzf-lua").colorschemes() end, desc = "Colorscheme with Preview" },
      { "<leader>ss", function() require("fzf-lua").lsp_document_symbols() end, desc = "Goto Symbol" },
      { "<leader>sS", function() require("fzf-lua").lsp_live_workspace_symbols() end, desc = "Goto Symbol (Workspace)" },
    },
  },
}
