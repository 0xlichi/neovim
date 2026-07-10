return {
  "nvim-lualine/lualine.nvim",
  config = function()
    -- Palette
    local c = {
      bg = "#1e2030",
      bg2 = "#2d3149",
      bg3 = "#252840",
      fg = "#cdd6f4",
      subtext = "#a6adc8",

      red = "#ff6e8a",
      orange = "#ff9966",
      yellow = "#ffd080",
      green = "#00e5a0",
      blue = "#6eb5ff",
      purple = "#d18eff",
      cyan = "#00d4ff",
      teal = "#00e0c0",
      pink = "#ff7edb",
    }

    -- Theme: y/z explicitly set so no mode color bleeds in
    local function make_mode(accent)
      return {
        a = { fg = c.bg, bg = accent, gui = "bold" },
        b = { fg = c.fg, bg = c.bg2 },
        c = { fg = c.fg, bg = c.bg3 },
        y = { fg = c.cyan, bg = c.bg2, gui = "bold" },
        z = { fg = accent, bg = c.bg2, gui = "bold" },
      }
    end

    local theme = {
      normal = make_mode(c.teal),
      insert = make_mode(c.blue),
      visual = make_mode(c.purple),
      replace = make_mode(c.red),
      terminal = make_mode(c.green),
      command = make_mode(c.orange),
      inactive = {
        a = { fg = c.subtext, bg = c.bg, gui = "bold" },
        b = { fg = c.subtext, bg = c.bg },
        c = { fg = c.subtext, bg = c.bg3 },
        y = { fg = c.subtext, bg = c.bg2 },
        z = { fg = c.subtext, bg = c.bg2 },
      },
    }

    local wide = function()
      return vim.fn.winwidth(0) > 100
    end

    local mode_icons = {
      n = "",
      i = "󰏫",
      v = "󰆽",
      V = "󰆽",
      ["\22"] = "󰆽",
      c = "",
      R = "󰗧",
      t = "",
    }

    local mode = {
      "mode",
      fmt = function(str)
        local icon = mode_icons[vim.fn.mode()] or "󰆾"
        return wide() and (icon .. "  " .. str .. " ") or (icon .. " " .. str:sub(1, 1) .. " ")
      end,
    }

    local file = {
      "filename",
      file_status = true,
      path = 0,
      symbols = { modified = "  ", readonly = "  ", unnamed = "  " },
    }

    local branch = {
      "branch",
      icon = " ",
      color = { fg = c.purple, gui = "bold" },
    }

    local diagnostics = {
      "diagnostics",
      sources = { "nvim_diagnostic" },
      sections = { "error", "warn", "info", "hint" },
      symbols = { error = " ", warn = " ", info = " ", hint = " " },
      diagnostics_color = {
        error = { fg = c.red },
        warn = { fg = c.yellow },
        info = { fg = c.blue },
        hint = { fg = c.teal },
      },
      colored = true,
      update_in_insert = true,
      cond = wide,
    }

    local diff = {
      "diff",
      colored = true,
      symbols = { added = " +A ", modified = " ~M ", removed = " -D " },
      diff_color = {
        added = { fg = c.green },
        modified = { fg = c.yellow },
        removed = { fg = c.red },
      },
      cond = wide,
    }

    local filetype = {
      "filetype",
      colored = true,
      icon_only = false,
      cond = wide,
    }

    local encoding = {
      "encoding",
      fmt = string.upper,
      cond = wide,
      color = { fg = c.subtext },
    }

    -- Active LSP client(s) attached to the current buffer
    local lsp_status = {
      function()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        if #clients == 0 then
          return ""
        end
        local names = {}
        for _, client in ipairs(clients) do
          if client.name ~= "null-ls" and client.name ~= "copilot" then
            names[#names + 1] = client.name
          end
        end
        if #names == 0 then
          return ""
        end
        return " " .. table.concat(names, ", ")
      end,
      color = { fg = c.pink, gui = "bold" },
      cond = wide,
    }

    -- Current file size, hidden for unsaved/empty buffers
    local filesize = {
      function()
        local size = vim.fn.getfsize(vim.fn.expand("%:p"))
        if size <= 0 then
          return ""
        end
        local units = { "B", "K", "M", "G" }
        local i = 1
        while size > 1024 and i < #units do
          size = size / 1024
          i = i + 1
        end
        return string.format("%.0f%s", size, units[i])
      end,
      color = { fg = c.subtext },
      cond = wide,
    }

    local search_count = {
      function()
        if vim.v.hlsearch == 0 or vim.fn.getreg("/") == "" then
          return ""
        end

        local ok, count = pcall(vim.fn.searchcount, {
          recompute = 1,
          maxcount = 9999,
          timeout = 50,
        })

        if not ok or count.total == 0 then
          return ""
        end

        local remaining = math.max(count.total - count.current, 0)
        return string.format(" %d/%d (%d left)", count.current, count.total, remaining)
      end,
      color = { fg = c.yellow, gui = "bold" },
    }

    require("lualine").setup({
      options = {
        icons_enabled = true,
        theme = theme,
        section_separators = { left = "", right = "" },
        component_separators = { left = "│", right = "│" },
        disabled_filetypes = { statusline = { "alpha", "neo-tree", "Avante" } },
        always_divide_middle = true,
        globalstatus = true,
        refresh = { statusline = 250 },
      },
      sections = {
        lualine_a = { mode },
        lualine_b = { branch, diff },
        lualine_c = { file, diagnostics },
        lualine_x = { lsp_status, search_count, filesize, encoding, filetype },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { file },
        lualine_x = { { "location", padding = 0 } },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      extensions = { "fugitive", "neo-tree", "lazy", "toggleterm", "trouble", "man" },
    })
  end,
}
