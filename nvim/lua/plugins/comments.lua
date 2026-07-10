return {
  "numToStr/Comment.nvim",
  dependencies = {
    "JoosepAlviste/nvim-ts-context-commentstring",
  },
  config = function()
    require("ts_context_commentstring").setup({
      enable_autocmd = false,
    })
    local ts_pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook()
    require("Comment").setup({
      pre_hook = function(ctx)
        return ts_pre_hook(ctx) or vim.bo.commentstring
      end,
    })
    local key_opts = { noremap = true, silent = true }
    vim.keymap.set("n", "<C-/>", require("Comment.api").toggle.linewise.current, key_opts)
    local visual_toggle = "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>"
    vim.keymap.set("v", "<C-/>", visual_toggle, key_opts)
  end,
}
