return {
  "mfussenegger/nvim-dap",
  optional = true,
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',
    {
      "mason-org/mason.nvim",
      opts = function(_, opts)
        opts.ensure_installed = opts.ensure_installed or {}
        local pkg = "js-debug-adapter"
        if not vim.tbl_contains(opts.ensure_installed, pkg) then
          table.insert(opts.ensure_installed, pkg)
        end
      end,
    },
  },
  opts = function()
    local dap = require("dap")
    if not dap.adapters["pwa-node"] then
      require("dap").adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          -- 💀 Make sure to update this path to point to your installation
          args = {
            LazyVim.get_pkg_path("js-debug-adapter", "js-debug/src/dapDebugServer.js"),
            "${port}",
          },
        },
      }
    end
    if not dap.adapters["node"] then
      dap.adapters["node"] = function(cb, config)
        if config.type == "node" then
          config.type = "pwa-node"
        end
        local nativeAdapter = dap.adapters["pwa-node"]
        if type(nativeAdapter) == "function" then
          nativeAdapter(cb, config)
        else
          cb(nativeAdapter)
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
      -- if not dap.configurations[language] then
        dap.configurations[language] = {
          -- {
          --   type = "pwa-node",
          --   request = "launch",
          --   name = "Launch file",
          --   program = "${file}",
          --   cwd = "${workspaceFolder}",
          -- },
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
            runtimeArgs = { "run", "start-api" }, -- or whatever script
            env = { NODE_OPTIONS = "--inspect" },
            -- rootPath = "${workspaceFolder}",
            -- cwd = "${workspaceFolder}",
            rootPath = find_workspace_folder,
            cwd = find_workspace_folder,
            protocol = "inspector",
            console = "integratedTerminal",
            internalConsoleOptions = "neverOpen",
            skipFiles = { find_workspace_folder() .. "/node_modules/**/*.js" },
            resolveSourceMapLocations = {
              find_workspace_folder() .. "/**",
              "!**/node_modules/**",
            },
          },
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch ui npm script",
            runtimeExecutable = "npm",
            runtimeArgs = { "run", "start" }, -- or whatever script
            env = { NODE_OPTIONS = "--inspect" },
            -- rootPath = "${workspaceFolder}/modules/risks/ui",
            -- cwd = "${workspaceFolder}/modules/risks/ui",
            rootPath = find_workspace_folder,
            cwd = find_workspace_folder,
            protocol = "inspector",
            console = "integratedTerminal",
            internalConsoleOptions = "neverOpen",
            skipFiles = { "${workspaceFolder}/node_modules/**/*.js" },
            -- resolveSourceMapLocations = {
            --   "${workspaceFolder}/**",
            --   "!**/node_modules/**",
            -- },
            resolveSourceMapLocations = {
              find_workspace_folder() .. "/**",
              "!**/node_modules/**",
            },
          },
          -- {
          --   type = 'pwa-node',
          --   request = 'attach',
          --   name = 'Attach',
          --   processId = require('dap.utils').pick_process,
          --   cwd = '${workspaceFolder}/src',
          --   skipFiles = { "${workspaceFolder}/node_modules/**/*.js" },
          -- },
        }
      -- end
    end
  end,
}
