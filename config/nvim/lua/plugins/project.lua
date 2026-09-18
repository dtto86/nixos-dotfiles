-- Project root switching with a recent-projects picker, ported from LazyVim's
-- util.project extra (fzf-lua branch only, since that's this config's finder).
local function pick()
  local fzf_lua = require("fzf-lua")
  local project = require("project_nvim.project")
  local history = require("project_nvim.utils.history")
  local results = history.get_recent_projects()

  fzf_lua.fzf_exec(results, {
    fzf_colors = true,
    actions = {
      ["default"] = function(selected)
        fzf_lua.files({ cwd = selected[1] })
      end,
      ["ctrl-w"] = function(selected)
        local path = selected[1]
        if project.set_pwd(path) then
          vim.notify("Change project dir to " .. path)
        end
      end,
      ["ctrl-d"] = function(selected)
        local path = selected[1]
        if vim.fn.confirm("Delete '" .. path .. "' project? ", "&Yes\n&No") == 1 then
          history.delete_project({ value = path })
        end
        pick()
      end,
    },
  })
end

return {
  {
    "ahmedkhalf/project.nvim",
    opts = { manual_mode = true },
    event = "VeryLazy",
    config = function(_, opts)
      require("project_nvim").setup(opts)
      local history = require("project_nvim.utils.history")
      history.delete_project = function(project)
        for k, v in pairs(history.recent_projects) do
          if v == project.value then
            history.recent_projects[k] = nil
            return
          end
        end
      end
    end,
  },
  {
    "ibhagwan/fzf-lua",
    keys = {
      { "<leader>fp", pick, desc = "Projects" },
    },
  },
}
