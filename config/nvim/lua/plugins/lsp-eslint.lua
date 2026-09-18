-- Monorepo-aware ESLint LSP setup, ported unchanged from the previous LazyVim config's
-- lua/plugins/eslint-lspconfig.lua: walks up for a local node_modules/eslint (falling
-- back to the global npm root) for `nodePath`, only attaches when an eslint config is
-- actually found upward from the buffer (supports monorepos via eslint.config.mjs /
-- rush.json / .git root markers), and formats on save via eslint's own on_attach when
-- `vim.g.lazyvim_eslint_auto_format` is true (set in lua/config/options.lua).
local auto_format = vim.g.lazyvim_eslint_auto_format == nil or vim.g.lazyvim_eslint_auto_format

local eslint_config_files = {
  ".eslintrc",
  ".eslintrc.js",
  ".eslintrc.cjs",
  ".eslintrc.yaml",
  ".eslintrc.yml",
  ".eslintrc.json",
  "eslint.config.js",
  "eslint.config.mjs",
  "eslint.config.cjs",
  "eslint.config.ts",
  "eslint.config.mts",
  "eslint.config.cts",
}

return {
  "neovim/nvim-lspconfig",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    servers = {
      eslint = {
        filetypes = {
          "javascript",
          "javascriptreact",
          "javascript.jsx",
          "typescript",
          "typescriptreact",
          "typescript.tsx",
          "vue",
        },
        settings = {
          workingDirectories = { mode = "auto" },
          format = auto_format,
          nodePath = (function()
            local Path = require("plenary.path")
            local fname = vim.api.nvim_buf_get_name(0)
            local dir = vim.fn.fnamemodify(fname, ":p:h")
            local current = Path:new(dir)
            while current.filename ~= current:parent().filename do
              if current:joinpath("node_modules/eslint"):is_dir() then
                return current:joinpath("node_modules"):absolute()
              end
              current = current:parent()
            end
            return vim.fn.trim(vim.fn.system("npm root -g 2>/dev/null"))
          end)(),
        },
        root_dir = function(bufnr, on_dir)
          local util = require("lspconfig.util")
          local root_markers = { "eslint.config.mjs", "rush.json" }
          root_markers = vim.fn.has("nvim-0.11.3") == 1 and { root_markers, { ".git" } }
            or vim.list_extend(root_markers, { ".git" })
          local project_root = vim.fs.root(bufnr, root_markers) or vim.fn.getcwd()
          local filename = vim.api.nvim_buf_get_name(bufnr)
          local eslint_config_files_with_package_json =
            util.insert_package_json(eslint_config_files, "eslintConfig", filename)
          local is_buffer_using_eslint = vim.fs.find(eslint_config_files_with_package_json, {
            path = filename,
            type = "file",
            limit = 1,
            upward = true,
            stop = vim.fs.dirname(project_root),
          })[1]
          if not is_buffer_using_eslint then
            return
          end
          on_dir(project_root)
        end,
        on_attach = function(_, bufnr)
          local group = vim.api.nvim_create_augroup("EslintFormat_" .. bufnr, { clear = true })
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = group,
            buffer = bufnr,
            callback = function(args)
              if auto_format then
                local buf = args.buf
                vim.lsp.buf.format({ bufnr = buf, filter = function(c)
                  return c.name == "eslint"
                end })
              end
              local buf = args.buf
              local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
              if #lines > 0 and lines[#lines] ~= "" then
                vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "" })
              end
            end,
          })
        end,
      },
    },
  },
}
