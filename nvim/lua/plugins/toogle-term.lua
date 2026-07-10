return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    require("toggleterm").setup({
      size = function(term)
        if term.direction == "horizontal" then
          return 15
        elseif term.direction == "vertical" then
          return math.floor(vim.o.columns * 0.4)
        end
      end,
      open_mapping = nil,
      hide_numbers = true,
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = false,
      terminal_mappings = true,
      persist_size = true,
      persist_mode = true,
      direction = "float",
      close_on_exit = true,
      shell = vim.o.shell,
      auto_scroll = true,
      float_opts = {
        border = "rounded",
        width = math.floor(vim.o.columns * 0.90),
        height = math.floor(vim.o.lines * 0.90),
        winblend = 8,
        title_pos = "center",
      },
      highlights = {
        Normal = { link = "Normal" },
        NormalFloat = { link = "NormalFloat" },
        FloatBorder = { link = "FloatBorder" },
      },
    })
    vim.keymap.set("n", "<leader>tt", "<cmd>ToggleTerm<CR>", { desc = "Toggle floating terminal" })
    vim.keymap.set("t", "<Esc>", "<cmd>ToggleTerm<CR>", { desc = "Close terminal" })
    vim.keymap.set("t", "<leader>t", "<cmd>ToggleTerm<CR>", { desc = "Close terminal" })
    vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
      pattern = "term://*",
      callback = function()
        vim.cmd("startinsert")
      end,
    })
    vim.api.nvim_create_autocmd("TermOpen", {
      pattern = "*",
      callback = function()
        vim.keymap.set("n", "i", function()
          vim.cmd("startinsert")
        end, { buffer = true, noremap = true })
        vim.keymap.set("n", "<CR>", function()
          vim.cmd("startinsert")
        end, { buffer = true, noremap = true })
      end,
    })
  end,
}
