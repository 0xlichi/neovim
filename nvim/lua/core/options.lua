-- UI / Display
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.numberwidth = 2
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.opt.showmode = false
vim.opt.showtabline = 1
vim.opt.cmdheight = 1
vim.opt.more = false
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"

-- Window / Scrolling
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.scrolloff = 4
vim.opt.sidescrolloff = 0
vim.opt.sidescroll = 0
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Mouse / Clipboard
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"

-- Indentation
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.breakindent = true

-- Search
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.smartcase = true
vim.opt.ignorecase = true

-- Undo / Backup / Swap
vim.opt.undofile = true
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false

-- Completion
vim.opt.completeopt = "menu,menuone,noinsert"
vim.opt.shortmess:append("c")
vim.opt.shortmess:remove("S")

-- Timing
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- Movement
vim.opt.whichwrap = "bs<>[]hl"
vim.opt.backspace = "indent,eol,start"

-- Files
vim.opt.fileencoding = "utf-8"
vim.opt.fixeol = true

-- Formatting / Keywords
vim.opt.formatoptions:remove({ "c", "r", "o" })
vim.opt.iskeyword:append("-")

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown" },
  callback = function()
    vim.opt_local.conceallevel = 2
  end,
})

-- Runtime path
vim.opt.runtimepath:remove("/usr/share/vim/vimfiles")

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "go", "python", "html", "css", "javascript" },
  callback = function()
    local ft_commentstrings = {
      go = "// %s",
      python = "# %s",
      html = "<!-- %s -->",
      css = "/* %s */",
      javascript = "// %s",
    }
    local cs = ft_commentstrings[vim.bo.filetype]
    if cs then
      vim.bo.commentstring = cs
    end
  end,
})
