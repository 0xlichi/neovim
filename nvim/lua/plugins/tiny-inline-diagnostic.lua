return {
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    priority = 1000,
    config = function()
      require("tiny-inline-diagnostic").setup({
        preset = "ghost",
        transparent_bg = false,
        transparent_cursorline = true,
        hi = {
          error = "DiagnosticError",
          warn = "DiagnosticWarn",
          info = "DiagnosticInfo",
          hint = "DiagnosticHint",
          arrow = "NonText",
          background = "CursorLine",
          mixing_color = "Normal",
        },
        disabled_ft = {},
        options = {
          show_source = {
            enabled = true,
            if_many = false,
          },
          use_icons_from_diagnostic = false,
          set_arrow_to_diag_color = false,
          throttle = 20,
          softwrap = 30,
          add_messages = {
            messages = true,
            display_count = false,
            use_max_severity = false,
            show_multiple_glyphs = true,
          },
          overflow = {
            mode = "wrap",
            padding = 0,
          },
          break_line = {
            enabled = false,
            after = 30,
          },
          multilines = {
            enabled = true,
            always_show = true,
            trim_whitespaces = false,
            tabstop = 4,
            severity = nil,
          },
          show_related = {
            enabled = true,
            max_count = 6,
          },
          show_all_diags_on_cursorline = false,
          show_diags_only_under_cursor = false,
          enable_on_insert = true,
          enable_on_select = true,
          severity = {
            vim.diagnostic.severity.ERROR,
            vim.diagnostic.severity.WARN,
            vim.diagnostic.severity.INFO,
            vim.diagnostic.severity.HINT,
          },
          virt_texts = { priority = 2048 },
          format = nil,
          overwrite_events = nil,
          override_open_float = true,
        },
        experimental = {
          use_window_local_extmarks = false,
        },
      })
      vim.diagnostic.config({ virtual_text = false })
    end,
  },
}
