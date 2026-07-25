-- Leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opts = { silent = true }

-- disable default space key behavior
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", opts)

-- Visual line movement (j/k and arrows respect wrapped lines)
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set("n", "<Up>", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set("i", "<Up>", "<C-o>gk", opts)
vim.keymap.set("i", "<Down>", "<C-o>gj", opts)

-- Arrow left/right move by character, no horizontal scroll surprise
vim.keymap.set("n", "<Left>", "h", opts)
vim.keymap.set("n", "<Right>", "l", opts)
vim.keymap.set("i", "<Left>", "<Left>", opts)
vim.keymap.set("i", "<Right>", "<Right>", opts)

-- Scrolling, centered
vim.keymap.set("n", "<C-d>", "<C-d>zz", opts)
vim.keymap.set("n", "<C-u>", "<C-u>zz", opts)
vim.keymap.set("n", "n", "nzzzv", opts)
vim.keymap.set("n", "N", "Nzzzv", opts)

-- Search
vim.keymap.set("n", "<Esc>", "<cmd>noh<CR>", opts)

-- Save / quit
vim.keymap.set("n", "<C-s>", "<cmd>w<CR>", opts)
vim.keymap.set("n", "<C-q>", "<cmd>q<CR>", opts)

-- Editing
vim.keymap.set("n", "x", '"_x', opts)
vim.keymap.set("n", "<leader>+", "<C-a>", opts)
vim.keymap.set("n", "<leader>-", "<C-x>", opts)

-- Window splits
vim.keymap.set("n", "<leader>vs", "<C-w>v", opts)
vim.keymap.set("n", "<leader>hs", "<C-w>s", opts)
vim.keymap.set("n", "<leader>xs", "<cmd>close<CR>", opts)

-- Window navigation
vim.keymap.set("n", "<C-k>", "<C-w>k", opts)
vim.keymap.set("n", "<C-j>", "<C-w>j", opts)
vim.keymap.set("n", "<C-h>", "<C-w>h", opts)
vim.keymap.set("n", "<C-l>", "<C-w>l", opts)

-- Window resizing
vim.keymap.set("n", "<A-Up>", "<cmd>resize -2<CR>", opts)
vim.keymap.set("n", "<A-Down>", "<cmd>resize +2<CR>", opts)
vim.keymap.set("n", "<A-Left>", "<cmd>vertical resize -2<CR>", opts)
vim.keymap.set("n", "<A-Right>", "<cmd>vertical resize +2<CR>", opts)

-- Buffer management
vim.keymap.set("n", "<leader>x", "<cmd>Bdelete!<CR>", opts)
vim.keymap.set("n", "<leader>bn", "<cmd>enew<CR>", opts)

-- Insert mode escape
vim.keymap.set("i", "<Esc>", "<Esc>:w<CR>", opts)
vim.keymap.set("i", "jj", "<Esc>:w<CR>", opts)
vim.keymap.set("i", "kk", "<Esc>:wq<CR>", opts)

-- Visual mode
vim.keymap.set("v", "<", "<gv", opts)
vim.keymap.set("v", ">", ">gv", opts)
vim.keymap.set("v", "<A-j>", ":m .+1<CR>==", opts)
vim.keymap.set("v", "<A-k>", ":m .-2<CR>==", opts)
vim.keymap.set("v", "p", '"_dP', opts)

-- Clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- Utilities
vim.keymap.set("n", "<leader>j", "*``cgn", opts)

-- Wrap toggle, also disables horizontal scroll while wrap is on
vim.keymap.set("n", "<leader>lw", function()
  local wrapped = vim.wo.wrap
  vim.wo.wrap = not wrapped
  vim.wo.sidescrolloff = wrapped and 8 or 0
  vim.o.sidescroll = wrapped and 1 or 0
  vim.notify(wrapped and "Wrap OFF" or "Wrap ON")
end, opts)

-- Diagnostics
local diagnostics_enabled = true
vim.keymap.set("n", "<leader>do", function()
  diagnostics_enabled = not diagnostics_enabled
  vim.diagnostic.enable(diagnostics_enabled)
end, opts)

vim.keymap.set("n", "[d", function()
  vim.diagnostic.jump({ count = -1, float = true })
end, opts)

vim.keymap.set("n", "]d", function()
  vim.diagnostic.jump({ count = 1, float = true })
end, opts)

vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, opts)

-- Session
vim.keymap.set("n", "<leader>ss", "<cmd>mksession! .session.vim<CR>", opts)
vim.keymap.set("n", "<leader>sl", "<cmd>source .session.vim<CR>", opts)

-- Tiny inline diagnostics
vim.keymap.set("n", "<leader>ed", "<cmd>TinyInlineDiag enable<CR>", opts)
vim.keymap.set("n", "<leader>dd", "<cmd>TinyInlineDiag disable<CR>", opts)
