-- File explorer, ported from LazyVim's editor.neo-tree extra. LazyVim's smart
-- root-dir detection is simplified to plain cwd here (see fzf-lua.lua's note).
return {
  "nvim-neo-tree/neo-tree.nvim",
  cmd = "Neotree",
  keys = {
    {
      "<leader>fe",
      function()
        require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
      end,
      desc = "Explorer NeoTree (cwd)",
    },
    { "<leader>e", "<leader>fe", desc = "Explorer NeoTree (cwd)", remap = true },
    {
      "<leader>ge",
      function()
        require("neo-tree.command").execute({ source = "git_status", toggle = true })
      end,
      desc = "Git Explorer",
    },
    {
      "<leader>be",
      function()
        require("neo-tree.command").execute({ source = "buffers", toggle = true })
      end,
      desc = "Buffer Explorer",
    },
  },
  deactivate = function()
    vim.cmd([[Neotree close]])
  end,
  -- The directory-argument auto-open (netrw replacement) is triggered from
  -- lua/config/autocmds.lua's VimEnter handler instead of an init/BufEnter hook here,
  -- so it runs *after* persistence.nvim's session restore rather than racing it.
  opts = {
    sources = { "filesystem", "buffers", "git_status" },
    open_files_do_not_replace_types = { "terminal", "Trouble", "qf", "edgy" },
    filesystem = {
      bind_to_cwd = false,
      follow_current_file = { enabled = true },
      use_libuv_file_watcher = true,
    },
    window = {
      mappings = {
        ["l"] = "open",
        ["h"] = "close_node",
        ["<space>"] = "none",
        ["Y"] = {
          function(state)
            vim.fn.setreg("+", state.tree:get_node():get_id(), "c")
          end,
          desc = "Copy Path to Clipboard",
        },
      },
    },
    default_component_configs = {
      indent = {
        with_expanders = true,
        expander_collapsed = "▸",
        expander_expanded = "▾",
        expander_highlight = "NeoTreeExpander",
      },
      git_status = {
        symbols = { unstaged = "󰄱", staged = "󰱒" },
      },
    },
  },
}
