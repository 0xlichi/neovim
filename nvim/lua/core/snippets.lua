-- LSP / Treesitter priority
-- Prevent LSP semantic tokens from overwriting Treesitter highlight groups
vim.hl.priorities.semantic_tokens = 95

-- Diagnostics
vim.diagnostic.config({
  virtual_text = {
    prefix = "●",
    format = function(d)
      local code = d.code and string.format("[%s] ", d.code) or ""
      return code .. d.message
    end,
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.INFO] = " ",
      [vim.diagnostic.severity.HINT] = "󰌵 ",
    },
  },
  underline = false,
  update_in_insert = true,
  float = { source = true },
})

-- Yank highlight
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
  pattern = "*",
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Kitty padding
-- Restore default padding when leaving Neovim
vim.api.nvim_create_autocmd("VimLeave", {
  group = vim.api.nvim_create_augroup("KittyPadding", { clear = true }),
  pattern = "*",
  callback = function()
    if vim.fn.executable("kitty") == 1 then
      vim.fn.system("kitty @ set-spacing padding=default margin=default")
    end
  end,
})
