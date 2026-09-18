-- vtsls (TypeScript/JavaScript/JSX/TSX), ported from LazyVim's
-- lang.typescript/vtsls.lua extra. Vue's hybrid mode (lsp-vue.lua) extends the same
-- server spec with the @vue/typescript-plugin, so this file must load its `opts`
-- first (lazy.nvim merges opts across specs of the same plugin regardless of file
-- order, so this is safe either way).
local function vtsls_exec(bufnr, command, arguments)
  local client = vim.lsp.get_clients({ bufnr = bufnr, name = "vtsls" })[1]
  if not client then
    return
  end
  client:exec_cmd({ command = command, arguments = arguments }, { bufnr = bufnr })
end

-- Registered at file-load time (every lua/plugins/*.lua is require'd once when
-- lazy.nvim scans specs, regardless of when the plugin itself lazy-loads), not via
-- a `config` field: nvim-lspconfig's `config` is already owned by lsp.lua, and
-- lazy.nvim only keeps the last `config` when a plugin has specs in multiple files.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("vtsls_extra", { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not client or client.name ~= "vtsls" then
      return
    end
    client.settings.javascript =
      vim.tbl_deep_extend("force", {}, client.settings.typescript or {}, client.settings.javascript or {})

    local buf = event.buf
    local function map(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = desc, silent = true })
    end
    map("gD", function()
      vtsls_exec(buf, "typescript.goToSourceDefinition", {
        vim.uri_from_bufnr(buf),
        vim.lsp.util.make_position_params(0, "utf-16").position,
      })
    end, "Goto Source Definition")
    map("gR", function()
      vtsls_exec(buf, "typescript.findAllFileReferences", { vim.uri_from_bufnr(buf) })
    end, "File References")
    map("<leader>cM", function()
      vim.lsp.buf.code_action({
        apply = true,
        context = { only = { "source.addMissingImports.ts" }, diagnostics = {} },
      })
    end, "Add missing imports")
    map("<leader>cD", function()
      vim.lsp.buf.code_action({
        apply = true,
        context = { only = { "source.fixAll.ts" }, diagnostics = {} },
      })
    end, "Fix all diagnostics")
  end,
})

return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      vtsls = {
        filetypes = {
          "javascript",
          "javascriptreact",
          "javascript.jsx",
          "typescript",
          "typescriptreact",
          "typescript.tsx",
        },
        settings = {
          complete_function_calls = true,
          vtsls = {
            enableMoveToFileCodeAction = true,
            autoUseWorkspaceTsdk = true,
            experimental = {
              maxInlayHintLength = 30,
              completion = { enableServerSideFuzzyMatch = true },
            },
          },
          typescript = {
            updateImportsOnFileMove = { enabled = "always" },
            suggest = { completeFunctionCalls = true },
            inlayHints = {
              enumMemberValues = { enabled = true },
              functionLikeReturnTypes = { enabled = true },
              parameterNames = { enabled = "literals" },
              parameterTypes = { enabled = true },
              propertyDeclarationTypes = { enabled = true },
              variableTypes = { enabled = false },
            },
          },
        },
      },
    },
  },
}
