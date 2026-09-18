-- Increment/decrement numbers, dates, booleans, weekdays, etc., ported from
-- LazyVim's editor.dial extra.
local function dial(increment, g)
  local mode = vim.fn.mode(true)
  local is_visual = mode == "v" or mode == "V" or mode == "\22"
  local func = (increment and "inc" or "dec") .. (g and "_g" or "_") .. (is_visual and "visual" or "normal")
  local group = vim.g.dials_by_ft[vim.bo.filetype] or "default"
  return require("dial.map")[func](group)
end

return {
  "monaqa/dial.nvim",
  keys = {
    { "<C-a>", function() return dial(true) end, expr = true, desc = "Increment", mode = { "n", "v" } },
    { "<C-x>", function() return dial(false) end, expr = true, desc = "Decrement", mode = { "n", "v" } },
    { "g<C-a>", function() return dial(true, true) end, expr = true, desc = "Increment", mode = { "n", "x" } },
    { "g<C-x>", function() return dial(false, true) end, expr = true, desc = "Decrement", mode = { "n", "x" } },
  },
  opts = function()
    local augend = require("dial.augend")
    return {
      dials_by_ft = {
        css = "css",
        vue = "vue",
        javascript = "typescript",
        typescript = "typescript",
        typescriptreact = "typescript",
        javascriptreact = "typescript",
        json = "json",
        lua = "lua",
        markdown = "markdown",
        sass = "css",
        scss = "css",
        python = "python",
      },
      groups = {
        default = {
          augend.integer.alias.decimal,
          augend.integer.alias.decimal_int,
          augend.integer.alias.hex,
          augend.date.alias["%Y/%m/%d"],
          augend.constant.alias.en_weekday,
          augend.constant.alias.en_weekday_full,
          augend.constant.alias.bool,
          augend.constant.alias.Bool,
          augend.constant.new({ elements = { "&&", "||" }, word = false, cyclic = true }),
        },
        vue = {
          augend.constant.new({ elements = { "let", "const" } }),
          augend.hexcolor.new({ case = "lower" }),
          augend.hexcolor.new({ case = "upper" }),
        },
        typescript = {
          augend.constant.new({ elements = { "let", "const" } }),
        },
        css = {
          augend.hexcolor.new({ case = "lower" }),
          augend.hexcolor.new({ case = "upper" }),
        },
        markdown = {
          augend.constant.new({ elements = { "[ ]", "[x]" }, word = false, cyclic = true }),
          augend.misc.alias.markdown_header,
        },
        json = {
          augend.semver.alias.semver,
        },
        lua = {
          augend.constant.new({ elements = { "and", "or" }, word = true, cyclic = true }),
        },
        python = {
          augend.constant.new({ elements = { "and", "or" } }),
        },
      },
    }
  end,
  config = function(_, opts)
    for name, group in pairs(opts.groups) do
      if name ~= "default" then
        vim.list_extend(group, opts.groups.default)
      end
    end
    require("dial.config").augends:register_group(opts.groups)
    vim.g.dials_by_ft = opts.dials_by_ft
  end,
}
