if lazyvim_docs then
  -- Set to false to disable auto format
  vim.g.lazyvim_eslint_auto_format = true
end

local auto_format = vim.g.lazyvim_eslint_auto_format == nil or vim.g.lazyvim_eslint_auto_format

local eslint_config_files = {
  '.eslintrc',
  '.eslintrc.js',
  '.eslintrc.cjs',
  '.eslintrc.yaml',
  '.eslintrc.yml',
  '.eslintrc.json',
  'eslint.config.js',
  'eslint.config.mjs',
  'eslint.config.cjs',
  'eslint.config.ts',
  'eslint.config.mts',
  'eslint.config.cts',
}

return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "nvim-lua/plenary.nvim", -- for Path module
    },
    -- other settings removed for brevity
    opts = {
      ---@type table<string, vim.lsp.Config>
      servers = {
        eslint = {
          filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx", "vue" },
          settings = {
            -- helps eslint find the eslintrc when it's placed in a subfolder instead of the cwd root
            workingDirectories = { mode = "auto" },
            format = auto_format,
            nodePath = (function()
              local Path = require("plenary.path")
              -- local util = require("lspconfig.util")

              local fname = vim.api.nvim_buf_get_name(0)
              local dir = vim.fn.fnamemodify(fname, ":p:h")
              local current = Path:new(dir)

              while current.filename ~= current:parent().filename do
                if current:joinpath("node_modules/eslint"):is_dir() then
                  -- print("Found node_modules in: " .. current:absolute())
                  -- return current:absolute()
                  return current:joinpath("node_modules"):absolute()
                end
                current = current:parent()
              end

              -- print("No node_modules found, using default path")
              -- return vim.fn.getcwd() -- fallback to CWD
              -- return "/home/pravin/.nvm/versions/node/v20.18.0/lib/node_modules/eslint/"
              -- return "/home/pravin/.nvm/versions/node/v20.18.0/lib/node_modules"
              return "/home/pravin/.nvm/versions/node/v22.17.0/lib/node_modules"
              -- return "/home/pravin/.nvm/versions/node/v20.18.0/bin"
            end)(),
          },
          -- root_dir = function(fname)
          --   local util = require("lspconfig.util")
          --   return util.root_pattern("eslint.config.mjs", ".eslintrc.js")(fname) or nil
          -- end,
          root_dir = function(bufnr, on_dir)
            local util = require("lspconfig.util")
            -- Add monorepo and ESLint config markers
            local root_markers = { 'eslint.config.mjs', 'rush.json' }
            root_markers = vim.fn.has('nvim-0.11.3') == 1 and { root_markers, { '.git' } }
            or vim.list_extend(root_markers, { '.git' })
            local project_root = vim.fs.root(bufnr, root_markers) or vim.fn.getcwd()
            -- print("project_root: " .. project_root)
            local filename = vim.api.nvim_buf_get_name(bufnr)
            local eslint_config_files_with_package_json =
            util.insert_package_json(eslint_config_files, 'eslintConfig', filename)
            local is_buffer_using_eslint = vim.fs.find(eslint_config_files_with_package_json, {
              path = filename,
              type = 'file',
              limit = 1,
              upward = true,
              stop = vim.fs.dirname(project_root),
            })[1]
            -- print("is_buffer_using_eslint: " .. tostring(is_buffer_using_eslint))
            if not is_buffer_using_eslint then
              return
            end
            on_dir(project_root)
          end,
          on_attach = function(client, bufnr)
            -- print("on_attach called for eslint")
            -- if client.config.on_attach then
            --   client.config.on_attach(client, bufnr)
            -- end

            -- vim.api.nvim_buf_create_user_command(0, 'LspEslintFixAll', function()
            --   client:request_sync('workspace/executeCommand', {
            --     command = 'eslint.applyAllFixes',
            --     arguments = {
            --       {
            --         uri = vim.uri_from_bufnr(bufnr),
            --         version = vim.lsp.util.buf_versions[bufnr],
            --       },
            --     },
            --   }, nil, bufnr)
            -- end, {})
            vim.api.nvim_create_autocmd("BufWritePre", {
              pattern = "*",
              callback = function(args)
                if auto_format then
                  local buf = args.buf
                  vim.lsp.buf.format({ bufnr = buf, filter = function(c) return c.name == "eslint" end })
                end
                if vim.fn.has("nvim-0.11") == 1 then
                  local buf = args.buf
                  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
                  if #lines > 0 and lines[#lines] ~= "" then
                    vim.api.nvim_buf_set_lines(buf, -1, -1, false, {""})
                  end
                end
              end,
            })
          end,
        },
      },
      setup = {
        eslint = function()
          if not auto_format then
            return
          end

          local formatter = LazyVim.lsp.formatter({
            name = "eslint: lsp",
            primary = false,
            priority = 200,
            filter = "eslint",
          })

          -- register the formatter with LazyVim
          LazyVim.format.register(formatter)
        end,
      },
    },
  },
}
