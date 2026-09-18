-- Shared Deno-detection helper, used by both lua/plugins/lsp-deno.lua (denols vs.
-- vtsls root_dir) and lua/plugins/conform.lua (deno fmt vs. prettier/eslint).
--
-- Handles two shapes of Deno project:
-- 1. A plain Deno project with deno.json/deno.jsonc/deno.lock at its root.
-- 2. A Supabase-style project: a Node app with a `supabase/functions/` subtree that
--    runs on Deno, marked by `.vscode/settings.json`'s `deno.enablePaths` (this is
--    what `supabase init`/`supabase functions new` generates) rather than a deno.json
--    at the repo root — the rest of the repo still uses tsserver/vtsls normally.
local M = {}

local util = require("lspconfig.util")

local function read_jsonc(path)
  local f = io.open(path, "r")
  if not f then
    return nil
  end
  local content = f:read("*a")
  f:close()

  local ok, decoded = pcall(vim.json.decode, content)
  if ok then
    return decoded
  end

  -- fall back to a best-effort comment strip for jsonc (// and /* */) — this can
  -- mis-strip a `//` that appears inside a string value (e.g. a URL), but plain
  -- vim.json.decode above already handles the common no-comments case correctly
  content = content:gsub("//[^\n]*", ""):gsub("/%*.-%*/", "")
  ok, decoded = pcall(vim.json.decode, content)
  return ok and decoded or nil
end

---@param fname string absolute path of the file being checked
---@return string[]? enable_paths relative to the .vscode/settings.json's directory
---@return string? root directory containing .vscode/settings.json
local function vscode_deno_paths(fname)
  local vscode_dir = util.root_pattern(".vscode")(fname)
  if not vscode_dir then
    return nil
  end
  local settings = read_jsonc(vscode_dir .. "/.vscode/settings.json")
  if not settings or settings["deno.enable"] == false then
    return nil
  end
  local paths = settings["deno.enablePaths"]
  if not paths or #paths == 0 then
    return settings["deno.enable"] and { "." } or nil, vscode_dir
  end
  return paths, vscode_dir
end

local function under(fname, root, rel)
  local abs = vim.fs.normalize(vim.fs.joinpath(root, rel))
  return vim.startswith(vim.fs.normalize(fname), abs)
end

--- Find the Deno project root for `fname`, or nil if it isn't part of one.
---@param fname string absolute file path
---@return string? root_dir
function M.find_root(fname)
  local direct = util.root_pattern("deno.json", "deno.jsonc", "deno.lock")(fname)
  if direct then
    return direct
  end

  local paths, root = vscode_deno_paths(fname)
  if paths and root then
    for _, rel in ipairs(paths) do
      if under(fname, root, rel) then
        return root
      end
    end
  end
  return nil
end

return M
