return {
  -- Themes
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = {
      transparent = true,
      dim_inactive = true,
      lualine_bold = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        sidebars = "transparent",
        floats = "transparent",
      },
      on_highlights = function(hl, c)
        hl.WinSeparator = { fg = c.blue0 }
        hl.IblIndent = { fg = c.bg_highlight }
        hl.IblScope = { fg = c.blue0 }
      end,
    },
  },

  {
    "tiagovla/tokyodark.nvim",
    lazy = true,
    opts = {
      transparent_background = true,
      gamma = 1.0,
    },
  },

  {
    "samharju/synthweave.nvim",
    lazy = true,
  },

  {
    "maxmx03/fluoromachine.nvim",
    lazy = true,
    opts = {
      glow = true,
      theme = "fluoromachine",
      transparent = true,
      brightness = 0.05,
    },
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = true,
    opts = {
      variant = "auto",
      dark_variant = "moon",
      dim_inactive_windows = true,
      extend_background_behind_borders = true,
      styles = {
        bold = true,
        italic = true,
        transparency = true,
      },
      highlight_groups = {
        TelescopeBorder = { fg = "overlay", bg = "none" },
        TelescopeNormal = { bg = "none" },
        TelescopePromptNormal = { bg = "base" },
        IblScope = { fg = "rose", blend = 30 },
      },
    },
  },

  {
    "bluz71/vim-moonfly-colors",
    lazy = true,
    init = function()
      vim.g.moonflyCursorColor = true
      vim.g.moonflyItalics = true
      vim.g.moonflyTransparent = true
      vim.g.moonflyUndercurls = true
      vim.g.moonflyWinSeparator = 2
      vim.g.moonflyVirtualTextColor = true
    end,
  },

  { "nyoom-engineering/oxocarbon.nvim", lazy = true },

  -- Neon / Cyberpunk
  {
    "scottmckendry/cyberdream.nvim",
    lazy = true,
    opts = {
      transparent = true,
      italic_comments = true,
      hide_fillchars = true,
      borderless_telescope = true,
      terminal_colors = true,
    },
  },

  { "dasupradyumna/midnight.nvim", lazy = true },

  -- Neon Pink / Synthwave
  {
    "sainnhe/edge",
    lazy = true,
    init = function()
      vim.g.edge_style = "neon"
      vim.g.edge_transparent_background = 2
      vim.g.edge_enable_italic = 1
      vim.g.edge_better_performance = 1
      vim.g.edge_dim_inactive_windows = 1
    end,
  },

  -- Minimal / Other
  { "shatur/neovim-ayu", lazy = true },

  {
    "Tsuzat/NeoSolarized.nvim",
    lazy = true,
    opts = {
      style = "dark",
      transparent = true,
      terminal_colors = true,
      enable_italics = true,
    },
  },

  -- Themery: picker + persistence
  {
    "zaldih/themery.nvim",
    priority = 1000,
    lazy = false,
    config = function()
      vim.g.edge_style = "neon"

      pcall(require("themery").loadTheme)

      require("themery").setup({
        livePreview = true,
        themes = {
          -- Neon Pink / Synthwave
          { name = "Fluoromachine", colorscheme = "fluoromachine" },
          { name = "Synthweave", colorscheme = "synthweave" },
          { name = "Edge Neon", colorscheme = "edge" },
          -- Neon / Cyberpunk
          { name = "Cyberdream", colorscheme = "cyberdream" },
          { name = "Midnight", colorscheme = "midnight" },
          { name = "Oxocarbon", colorscheme = "oxocarbon" },
          -- Dark
          { name = "Tokyo Night", colorscheme = "tokyonight" },
          { name = "Tokyo Night Storm", colorscheme = "tokyonight-storm" },
          { name = "Tokyo Night Moon", colorscheme = "tokyonight-moon" },
          { name = "Tokyo Dark", colorscheme = "tokyodark" },
          { name = "Rose Pine", colorscheme = "rose-pine" },
          { name = "Rose Pine Moon", colorscheme = "rose-pine-moon" },
          { name = "Moonfly", colorscheme = "moonfly" },
          { name = "NeoSolarized", colorscheme = "NeoSolarized" },
          -- One
          { name = "Ayu Dark", colorscheme = "ayu-dark" },
        },
      })

      vim.keymap.set("n", "<leader>ct", "<cmd>Themery<CR>", { desc = "Theme switcher" })
    end,
  },
}
