-- Python virtualenv picker, ported from LazyVim's lang.python extra.
return {
  "linux-cultist/venv-selector.nvim",
  cmd = "VenvSelect",
  ft = "python",
  opts = {
    options = {
      notify_user_on_venv_activation = true,
      override_notify = false,
    },
  },
  keys = {
    { "<leader>cv", "<cmd>VenvSelect<cr>", desc = "Select VirtualEnv", ft = "python" },
  },
}
