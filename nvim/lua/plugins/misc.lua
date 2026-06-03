return {
  -- Autoclosing / Pair Helpers
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter", -- Load only when entering insert mode to save startup time
    config = true, -- Use default setup (auto-pairs brackets, quotes, etc.)
  },
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },
  -- Editing Helpers
  {
    "kylechui/nvim-surround",
    version = "^3.0.0", -- Stable release recommended
    event = "VeryLazy", -- Load late after startup for better performance
    config = function()
      require("nvim-surround").setup() -- Default configuration (add/change/delete surroundings)
    end,
  },
  {
    "tpope/vim-sleuth", -- Automatically detect indentation settings for each file
    -- No config needed; plugin auto-works
  },
  -- Visual Helpers / UI Enhancements
  {
    "folke/todo-comments.nvim",
    event = "VimEnter", -- Load after Vim has started
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      signs = false, -- Do not show gutter signs; highlight keywords in the code only
    },
    -- Highlights TODO, FIXME, NOTE, etc. in code for quick navigation
  },
  {
    "NvChad/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup() -- Highlight hex colors (#ff0000) in files
    end,
    -- Light plugin for visualizing colors
  },
}
