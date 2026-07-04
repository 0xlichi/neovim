-- lua/plugins/treesitter-textobjects.lua
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
          ["@function.outer"] = "V", -- linewise select for whole function
          ["@function.inner"] = "V",
        },
        include_surrounding_whitespace = false,
      },
    })

    local select = require("nvim-treesitter-textobjects.select")

    -- vaf / vif -> works automatically because these are mapped
    -- for both x (visual) and o (operator-pending) modes.
    -- That single mapping set gives you vaf, vif, daf, dif, caf, cif for free,
    -- since d/c/v are vim's own operators — they just call into whatever
    -- af/if resolve to in operator-pending mode.

    vim.keymap.set({ "x", "o" }, "af", function()
      select.select_textobject("@function.outer", "textobjects")
    end, { desc = "Select around function" })

    vim.keymap.set({ "x", "o" }, "if", function()
      select.select_textobject("@function.inner", "textobjects")
    end, { desc = "Select inside function" })
  end,
}
