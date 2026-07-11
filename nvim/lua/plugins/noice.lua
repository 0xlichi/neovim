return {
  "folke/noice.nvim",
  event = "VeryLazy",
  opts = {
    routes = {
      {
        filter = {
          event = "msg_show",
          kind = "",
          find = "Searching in files",
        },
        opts = { skip = true },
      },
    },
  },
  dependencies = {
    "MunifTanjim/nui.nvim",
    {
      "rcarriga/nvim-notify",
      opts = {
        -- Resolve to the current colorscheme's actual background instead of
        -- a hardcoded hex, so this works across every theme in Themery.
        background_colour = "NotifyBackground",
        render = "compact",
        stages = "slide",
        timeout = 3000,
      },
      config = function(_, opts)
        vim.api.nvim_set_hl(0, "NotifyBackground", { bg = "#1e2030" })
        vim.api.nvim_create_autocmd("ColorScheme", {
          group = vim.api.nvim_create_augroup("NotifyBgSync", { clear = true }),
          callback = function()
            local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
            local bg = normal.bg and string.format("#%06x", normal.bg) or "#1e2030"
            vim.api.nvim_set_hl(0, "NotifyBackground", { bg = bg })
          end,
        })
        require("notify").setup(opts)
      end,
    },
  },
}
