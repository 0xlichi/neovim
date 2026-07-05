return {
  "theprimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("harpoon"):setup()
  end,
  keys = {
    {
      "<leader>ha",
      function()
        require("harpoon"):list():add()
        require("noice").redirect(function()
          vim.notify("Added to Harpoon", vim.log.levels.INFO)
        end)
      end,
      desc = "add file to harpoon",
    },
    {
      "<leader>hh",
      function()
        local harpoon = require("harpoon")
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end,
      desc = "open harpoon menu",
    },
    {
      "<leader>hc",
      function()
        require("harpoon"):list():clear()
        vim.notify("Harpoon list cleared", vim.log.levels.INFO)
      end,
      desc = "clear harpoon list",
    },
    {
      "<leader>1",
      function()
        require("harpoon"):list():select(1)
      end,
      desc = "go to file 1",
    },
    {
      "<leader>2",
      function()
        require("harpoon"):list():select(2)
      end,
      desc = "go to file 2",
    },
    {
      "<leader>3",
      function()
        require("harpoon"):list():select(3)
      end,
      desc = "go to file 3",
    },
    {
      "<leader>4",
      function()
        require("harpoon"):list():select(4)
      end,
      desc = "go to file 4",
    },
    {
      "<leader>5",
      function()
        require("harpoon"):list():select(5)
      end,
      desc = "go to file 5",
    },
    {
      "<leader>6",
      function()
        require("harpoon"):list():select(6)
      end,
      desc = "go to file 6",
    },
  },
}
