local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.notify("Take a coffee while setting up the configuration this will be done in a minute.", vim.log.levels.INFO)
  local repo = "https://github.com/folke/lazy.nvim.git"
  local result = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    repo,
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.notify("Failed to clone lazy.nvim:\n" .. result, vim.log.levels.ERROR)
    return
  end
end
vim.opt.rtp:prepend(lazypath)
-- ── Core config (must run before plugins) ─────────────────────────────────────
require("core.options")
require("core.keymaps")
require("core.snippets")
-- ── Plugins ───────────────────────────────────────────────────────────────────
require("lazy").setup({
  spec = {
    { import = "plugins.alpha" },
    { import = "plugins.autocompletion" },
    { import = "plugins.bufferline" },
    { import = "plugins.colortheme-switcher" },
    { import = "plugins.comments" },
    { import = "plugins.misc" },
    { import = "plugins.gitsigns" },
    { import = "plugins.indent-blankline" },
    { import = "plugins.lualine" },
    { import = "plugins.lsp" },
    { import = "plugins.none-ls" },
    { import = "plugins.telescope" },
    { import = "plugins.tiny-inline-diagnostic" },
    { import = "plugins.undotree" },
    { import = "plugins.yazi" },
    { import = "plugins.treesitter" },
    { import = "plugins.toogle-term" },
    { import = "plugins.debug" },
  },
  change_detection = {
    enabled = true,
    notify = false,
  },
  performance = {
    cache = { enabled = true },
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
  ui = {
    border = "rounded",
    size = { width = 0.85, height = 0.85 },
    icons = vim.g.have_nerd_font and {} or {
      cmd = "⌘",
      config = "🛠",
      event = "📅",
      ft = "📂",
      init = "⚙",
      keys = "🗝",
      plugin = "🔌",
      runtime = "💻",
      require = "🌙",
      source = "📄",
      start = "🚀",
      task = "📌",
      lazy = "💤",
    },
  },
})
-- ── Restore cursor position on file open ──────────────────────────────────────
vim.api.nvim_create_autocmd("BufReadPost", {
  group = vim.api.nvim_create_augroup("RestoreCursor", { clear = true }),
  callback = function(ev)
    local ft = vim.bo[ev.buf].filetype
    if ft == "gitcommit" or ft == "gitrebase" then
      return
    end
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    local line = mark[1]
    local total = vim.api.nvim_buf_line_count(ev.buf)
    if line > 1 and line <= total then
      vim.schedule(function()
        vim.cmd('normal! g`"zz')
      end)
    end
  end,
})
