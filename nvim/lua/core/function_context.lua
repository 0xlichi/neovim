local M = {}
local ns = vim.api.nvim_create_namespace("function_context_hint")

-- ── Constants (defined once at module level, not recreated on every call) ──
local FT_LABELS = {
  python = "def",
  go = "func",
  rust = "fn",
  lua = "function",
  javascript = "function",
  typescript = "function",
  cpp = "void",
  c = "void",
  java = "method",
  ruby = "def",
  php = "function",
  swift = "func",
  kotlin = "fun",
  scala = "def",
  haskell = "let",
  elixir = "def",
  erlang = "fun",
  zig = "fn",
  nim = "proc",
  crystal = "def",
  ocaml = "let",
  fsharp = "let",
  dart = "void",
  r = "function",
  julia = "function",
}

local METHOD_LABELS = {
  python = "def",
  java = "method",
  ruby = "def",
  javascript = "method",
  typescript = "method",
  go = "func",
  rust = "fn",
  cpp = "method",
  kotlin = "fun",
  swift = "func",
}

-- ── Cache: skip re-render if row hasn't changed ────────────────────────────
-- key: winid, value: { row, text }
local last_render = {}

-- ── Debounce timer ─────────────────────────────────────────────────────────
local timer = vim.uv.new_timer()
local DEBOUNCE_MS = 80

local function is_function_node(node)
  local t = node:type()
  return t:find("function", 1, true) or t:find("method", 1, true) or t == "constructor_declaration"
end

-- Iterative instead of recursive — avoids stack overhead on deep trees
local function find_identifier(root, bufnr)
  local queue = { root }
  local i = 1
  while i <= #queue do
    local node = queue[i]
    i = i + 1
    local t = node:type()
    if t == "identifier" or t == "property_identifier" or t == "field_identifier" then
      return vim.treesitter.get_node_text(node, bufnr)
    end
    for child in node:iter_children() do
      queue[#queue + 1] = child
    end
  end
end

local function name_from_related_node(node, bufnr)
  if not node then
    return nil
  end
  for _, field in ipairs({ "name", "declarator" }) do
    local nodes = node:field(field)
    if nodes and nodes[1] then
      local name = find_identifier(nodes[1], bufnr)
      if name then
        return name
      end
    end
  end
  local start_row = node:range()
  local line = vim.api.nvim_buf_get_lines(bufnr, start_row, start_row + 1, false)[1] or ""
  return line:match("function%s+([%w_%.:]+)")
    or line:match("def%s+([%w_]+)")
    or line:match("func%s+[%w_()%s%*]*%s([%w_]+)%s*%(")
    or line:match("([%w_]+)%s*[:=]%s*function")
    or line:match("([%w_]+)%s*=%s*.-=>")
end

local function name_from_node(node, bufnr)
  return name_from_related_node(node, bufnr) or name_from_related_node(node:parent(), bufnr) or "<anonymous>"
end

local function get_label(ft, node)
  local t = node:type()
  if t == "constructor_declaration" then
    return "new"
  end
  if t:find("arrow", 1, true) then
    return "=>"
  end
  if t == "lambda_expression" or t == "lambda" then
    return "lambda"
  end
  if t:find("method", 1, true) then
    return METHOD_LABELS[ft] or "method"
  end
  return FT_LABELS[ft] or "function"
end

local function current_function_stack(bufnr, row, col)
  -- treesitter keeps its own incremental parse — no need to call parser:parse()
  local ok, node = pcall(vim.treesitter.get_node, {
    bufnr = bufnr,
    pos = { row, col },
    ignore_injections = false,
  })
  if not ok or not node then
    return nil
  end

  local ft = vim.bo[bufnr].filetype
  local results = {}
  while node do
    if is_function_node(node) then
      table.insert(results, 1, {
        label = get_label(ft, node),
        name = name_from_node(node, bufnr),
      })
    end
    node = node:parent()
  end
  return results
end

local function has_diagnostic_on_line(bufnr, row)
  return #vim.diagnostic.get(bufnr, { lnum = row }) > 0
end

local function render(winid, bufnr, row, col)
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  local stack = current_function_stack(bufnr, row, col)
  if not stack or #stack == 0 then
    last_render[winid] = nil
    return
  end

  local parts = {}
  for _, entry in ipairs(stack) do
    parts[#parts + 1] = entry.label .. " " .. entry.name
  end
  local text = " " .. table.concat(parts, " -> ")

  -- skip extmark update if text is identical to last render on this row
  local cache = last_render[winid]
  if cache and cache.row == row and cache.text == text then
    return
  end
  last_render[winid] = { row = row, text = text }

  local pos = has_diagnostic_on_line(bufnr, row) and "right_align" or "eol"

  vim.api.nvim_buf_set_extmark(bufnr, ns, row, 0, {
    virt_text = { { text, "Comment" } },
    virt_text_pos = pos,
    hl_mode = "combine",
    priority = 100,
  })
end

function M.update()
  -- debounce: reset timer on every event, only fire after DEBOUNCE_MS of silence
  timer:stop()
  timer:start(
    DEBOUNCE_MS,
    0,
    vim.schedule_wrap(function()
      local winid = vim.api.nvim_get_current_win()
      local bufnr = vim.api.nvim_get_current_buf()

      if vim.bo[bufnr].buftype ~= "" then
        vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
        last_render[winid] = nil
        return
      end

      local cursor = vim.api.nvim_win_get_cursor(0)
      local row = cursor[1] - 1
      local col = cursor[2]

      -- skip if cursor row hasn't changed since last render
      local cache = last_render[winid]
      if cache and cache.row == row and cache.text ~= nil then
        return
      end

      local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1]
      if not line then
        return
      end

      render(winid, bufnr, row, col)
    end)
  )
end

function M.setup()
  local group = vim.api.nvim_create_augroup("FunctionContextHint", { clear = true })
  vim.api.nvim_create_autocmd(
    { "BufEnter", "CursorMoved", "CursorMovedI", "TextChanged", "TextChangedI" },
    { group = group, callback = M.update }
  )
  -- clean up cache when a window is closed
  vim.api.nvim_create_autocmd("WinClosed", {
    group = group,
    callback = function(ev)
      last_render[tonumber(ev.match)] = nil
    end,
  })
end

return M
