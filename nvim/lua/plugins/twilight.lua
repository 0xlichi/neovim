local state_file = vim.fn.stdpath("state") .. "/twilight_state"
local enabled = false
local function save_state(state)
  local f = io.open(state_file, "w")
  if f then
    f:write(state and "1" or "0")
    f:close()
  end
end
local function load_state()
  local f = io.open(state_file, "r")
  if f then
    local content = f:read("*a")
    f:close()
    return content == "1"
  end
  return false
end
return {
  "folke/twilight.nvim",
  event = "VeryLazy",
  opts = {
    dimming = {
      alpha = 0.25,
      color = { "Normal", "#ffffff" },
      term_bg = "#000000",
      inactive = false,
    },
    context = 10,
    treesitter = true,
    expand = {
      "function",
      "method",
      "table",
      "if_statement",
    },
    exclude = {},
  },
  config = function(_, opts)
    require("twilight").setup(opts)
    enabled = load_state()
    if enabled then
      vim.cmd("TwilightEnable")
    end
    local function toggle_twilight()
      enabled = not enabled
      if enabled then
        vim.cmd("TwilightEnable")
      else
        vim.cmd("TwilightDisable")
      end
      save_state(enabled)
    end
    vim.keymap.set("n", "<leader>tw", toggle_twilight, {
      desc = "Toggle Twilight",
      silent = true,
    })
  end,
}
