-- Debugging: core keymaps/UI ported from LazyVim's dap.core extra; JS/TS adapters +
-- the custom "Launch npm script" configs ported unchanged from the previous config's
-- lua/plugins/nvim-dap.lua; Python wiring (debugpy) added since it was previously
-- provided implicitly by LazyVim's lang.python extra rather than hand-written here.
local function get_args(config)
  local args = type(config.args) == "function" and (config.args() or {}) or config.args or {}
  local args_str = type(args) == "table" and table.concat(args, " ") or args
  config = vim.deepcopy(config)
  config.args = function()
    local new_args = vim.fn.expand(vim.fn.input("Run with args: ", args_str))
    return require("dap.utils").splitstr(new_args)
  end
  return config
end

return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      { "theHamsta/nvim-dap-virtual-text", opts = {} },
    },
    keys = {
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "Breakpoint Condition" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      { "<leader>dc", function() require("dap").continue() end, desc = "Run/Continue" },
      { "<leader>da", function() require("dap").continue({ before = get_args }) end, desc = "Run with Args" },
      { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
      { "<leader>dg", function() require("dap").goto_() end, desc = "Go to Line (No Execute)" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
      { "<leader>dj", function() require("dap").down() end, desc = "Down" },
      { "<leader>dk", function() require("dap").up() end, desc = "Up" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "Run Last" },
      { "<leader>do", function() require("dap").step_out() end, desc = "Step Out" },
      { "<leader>dO", function() require("dap").step_over() end, desc = "Step Over" },
      { "<leader>dP", function() require("dap").pause() end, desc = "Pause" },
      { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
      { "<leader>ds", function() require("dap").session() end, desc = "Session" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
      { "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },
    },
    config = function()
      vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })
      local vscode = require("dap.ext.vscode")
      local json = require("plenary.json")
      vscode.json_decode = function(str)
        return vim.json.decode(json.json_strip_comments(str))
      end
    end,
  },

  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "nvim-neotest/nvim-nio" },
    keys = {
      { "<leader>du", function() require("dapui").toggle({}) end, desc = "Dap UI" },
      { "<leader>de", function() require("dapui").eval() end, desc = "Eval", mode = { "n", "x" } },
    },
    opts = {},
    config = function(_, opts)
      local dap, dapui = require("dap"), require("dapui")
      dapui.setup(opts)
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open({}) end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close({}) end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close({}) end
    end,
  },

  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = "mason.nvim",
    cmd = { "DapInstall", "DapUninstall" },
    opts = {
      automatic_installation = true,
      ensure_installed = { "js-debug-adapter", "debugpy" },
      handlers = {
        -- nvim-dap-python manages the python adapter itself
        python = function() end,
      },
    },
    config = function(_, opts)
      require("mason-nvim-dap").setup(opts)
    end,
  },

  -- JS/TS/Vue: pwa-node adapter + this user's own npm-script launch configs
  {
    "mfussenegger/nvim-dap",
    optional = true,
    opts = function()
      local dap = require("dap")
      for _, adapter_type in ipairs({ "node", "chrome", "msedge" }) do
        local pwa_type = "pwa-" .. adapter_type
        if not dap.adapters[pwa_type] then
          dap.adapters[pwa_type] = {
            type = "server",
            host = "localhost",
            port = "${port}",
            executable = { command = "js-debug-adapter", args = { "${port}" } },
          }
        end
        if not dap.adapters[adapter_type] then
          dap.adapters[adapter_type] = function(cb, config)
            config.type = pwa_type
            local native_adapter = dap.adapters[pwa_type]
            if type(native_adapter) == "function" then
              native_adapter(cb, config)
            else
              cb(native_adapter)
            end
          end
        end
      end

      local js_filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact", "vue" }

      local function find_workspace_folder()
        local file = vim.api.nvim_buf_get_name(0)
        local cwd = vim.fn.fnamemodify(file, ":p:h")
        while cwd ~= "/" do
          if vim.fn.isdirectory(cwd .. "/node_modules") == 1 then
            return cwd
          end
          cwd = vim.fn.fnamemodify(cwd, ":h")
        end
        return vim.fn.getcwd()
      end

      local vscode = require("dap.ext.vscode")
      vscode.type_to_filetypes["node"] = js_filetypes
      vscode.type_to_filetypes["pwa-node"] = js_filetypes

      for _, language in ipairs(js_filetypes) do
        dap.configurations[language] = {
          {
            type = "pwa-node",
            request = "attach",
            name = "Attach",
            processId = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
          },
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch api npm script",
            runtimeExecutable = "npm",
            runtimeArgs = { "run", "start-api" },
            env = { NODE_OPTIONS = "--inspect" },
            rootPath = find_workspace_folder,
            cwd = find_workspace_folder,
            protocol = "inspector",
            console = "integratedTerminal",
            internalConsoleOptions = "neverOpen",
            skipFiles = { "${workspaceFolder}/node_modules/**/*.js" },
            resolveSourceMapLocations = { "${workspaceFolder}/**", "!**/node_modules/**" },
          },
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch ui npm script",
            runtimeExecutable = "npm",
            runtimeArgs = { "run", "start" },
            env = { NODE_OPTIONS = "--inspect" },
            rootPath = find_workspace_folder,
            cwd = find_workspace_folder,
            protocol = "inspector",
            console = "integratedTerminal",
            internalConsoleOptions = "neverOpen",
            skipFiles = { "${workspaceFolder}/node_modules/**/*.js" },
            resolveSourceMapLocations = { "${workspaceFolder}/**", "!**/node_modules/**" },
          },
        }
      end
    end,
  },

  -- Python: debugpy via nvim-dap-python
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    keys = {
      { "<leader>dPt", function() require("dap-python").test_method() end, desc = "Debug Method", ft = "python" },
      { "<leader>dPc", function() require("dap-python").test_class() end, desc = "Debug Class", ft = "python" },
    },
    config = function()
      require("dap-python").setup("debugpy-adapter")
    end,
  },
}
