return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  branch = "main",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    require("nvim-treesitter-textobjects").setup({
      select = {
        lookahead = true,
        selection_modes = {
          ["@function.outer"] = "V",
          ["@function.inner"] = "V",
        },
        include_surrounding_whitespace = false,
      },
      move = {
        set_jumps = true,
      },
    })

    local select = require("nvim-treesitter-textobjects.select")
    local move = require("nvim-treesitter-textobjects.move")
    local swap = require("nvim-treesitter-textobjects.swap")

    -- vaf / vif / daf / dif / caf / cif work automatically since these are
    -- mapped for both x (visual) and o (operator-pending) modes: d/c/v are
    -- vim's own operators, they just call into whatever af/if resolve to.
    local function select_map(lhs, query, desc)
      vim.keymap.set({ "x", "o" }, lhs, function()
        select.select_textobject(query, "textobjects")
      end, { desc = desc })
    end

    select_map("af", "@function.outer", "Select around function")
    select_map("if", "@function.inner", "Select inside function")
    select_map("aa", "@parameter.outer", "Select around parameter")
    select_map("ia", "@parameter.inner", "Select inside parameter")
    select_map("ac", "@class.outer", "Select around class")
    select_map("ic", "@class.inner", "Select inside class")

    vim.keymap.set("n", "]f", function()
      move.goto_next_start("@function.outer", "textobjects")
    end, { desc = "Next function start" })
    vim.keymap.set("n", "]c", function()
      move.goto_next_start("@class.outer", "textobjects")
    end, { desc = "Next class start" })
    vim.keymap.set("n", "[f", function()
      move.goto_previous_start("@function.outer", "textobjects")
    end, { desc = "Prev function start" })
    vim.keymap.set("n", "[c", function()
      move.goto_previous_start("@class.outer", "textobjects")
    end, { desc = "Prev class start" })

    vim.keymap.set("n", "<leader>a", function()
      swap.swap_next("@parameter.inner")
    end, { desc = "Swap parameter with next" })
    vim.keymap.set("n", "<leader>A", function()
      swap.swap_previous("@parameter.inner")
    end, { desc = "Swap parameter with previous" })
  end,
}
