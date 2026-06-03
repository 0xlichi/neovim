return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  lazy = false,
  build = ":TSUpdate",
  dependencies = {
    { "nvim-treesitter/nvim-treesitter-textobjects", branch = "master" },
    "nvim-treesitter/nvim-treesitter-context",
  },
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "bash",
        "c",
        "css",
        "comment", -- Highlights TODO/FIXME tokens inside any language
        "diff", -- Syntax in git diffs / fugitive buffers
        "dockerfile",
        "git_config",
        "git_rebase",
        "gitcommit",
        "gitignore",
        "go",
        "gomod",
        "gosum",
        "gowork",
        "html",
        "javascript",
        "jsdoc", -- JSDoc comment blocks inside JS/TS
        "json",
        "json5",
        "jsonc",
        "lua",
        "luadoc", -- LuaDoc comment blocks
        "luap", -- Lua patterns (used by nvim internals)
        "markdown",
        "markdown_inline",
        "python",
        "query", -- Treesitter query files (.scm)
        "regex",
        "scss",
        "sql",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
      },

      auto_install = true,
      sync_install = false,
      ignore_install = {},
      modules = {},

      -- ── Highlight ────────────────────────────────────────────────────────────
      highlight = {
        enable = true,
        -- Disable on very large files to avoid lag
        disable = function(_, buf)
          local max_filesize = 500 * 1024 -- 500 KB
          local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            return true
          end
        end,
        additional_vim_regex_highlighting = false,
      },

      -- ── Indent ───────────────────────────────────────────────────────────────
      indent = {
        enable = true,
        -- Disable for languages where TS indent is still unreliable
        disable = { "python", "yaml", "c" },
      },

      -- ── Incremental selection ─────────────────────────────────────────────────
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>", -- More ergonomic than gnn
          node_incremental = "<C-space>", -- Keep expanding with same key
          scope_incremental = "<C-s>",
          node_decremental = "<bs>", -- Backspace to shrink selection
        },
      },

      -- ── Textobjects ───────────────────────────────────────────────────────────
      textobjects = {
        select = {
          enable = true,
          lookahead = true, -- Jump forward to next match automatically
          keymaps = {
            ["aa"] = { query = "@parameter.outer", desc = "outer argument" },
            ["ia"] = { query = "@parameter.inner", desc = "inner argument" },
            ["af"] = { query = "@function.outer", desc = "outer function" },
            ["if"] = { query = "@function.inner", desc = "inner function" },
            ["ac"] = { query = "@class.outer", desc = "outer class" },
            ["ic"] = { query = "@class.inner", desc = "inner class" },
            ["ai"] = { query = "@conditional.outer", desc = "outer conditional" },
            ["ii"] = { query = "@conditional.inner", desc = "inner conditional" },
            ["al"] = { query = "@loop.outer", desc = "outer loop" },
            ["il"] = { query = "@loop.inner", desc = "inner loop" },
            ["ab"] = { query = "@block.outer", desc = "outer block" },
            ["ib"] = { query = "@block.inner", desc = "inner block" },
            ["as"] = {
              query = "@scope",
              desc = "language scope",
              query_group = "locals",
            },
          },
          -- After selecting, show which mode you're in
          selection_modes = {
            ["@parameter.outer"] = "v",
            ["@function.outer"] = "V",
            ["@class.outer"] = "<C-v>",
          },
          include_surrounding_whitespace = false,
        },

        move = {
          enable = true,
          set_jumps = true, -- Populate the jumplist so <C-o>/<C-i> work
          goto_next_start = {
            ["]f"] = { query = "@function.outer", desc = "Next function start" },
            ["]c"] = { query = "@class.outer", desc = "Next class start" },
            ["]a"] = { query = "@parameter.inner", desc = "Next argument start" },
            ["]i"] = { query = "@conditional.outer", desc = "Next conditional start" },
            ["]l"] = { query = "@loop.outer", desc = "Next loop start" },
          },
          goto_next_end = {
            ["]F"] = { query = "@function.outer", desc = "Next function end" },
            ["]C"] = { query = "@class.outer", desc = "Next class end" },
          },
          goto_previous_start = {
            ["[f"] = { query = "@function.outer", desc = "Prev function start" },
            ["[c"] = { query = "@class.outer", desc = "Prev class start" },
            ["[a"] = { query = "@parameter.inner", desc = "Prev argument start" },
            ["[i"] = { query = "@conditional.outer", desc = "Prev conditional start" },
            ["[l"] = { query = "@loop.outer", desc = "Prev loop start" },
          },
          goto_previous_end = {
            ["[F"] = { query = "@function.outer", desc = "Prev function end" },
            ["[C"] = { query = "@class.outer", desc = "Prev class end" },
          },
        },

        swap = {
          enable = true,
          swap_next = { ["<leader>a"] = { query = "@parameter.inner", desc = "Swap next param" } },
          swap_previous = { ["<leader>A"] = { query = "@parameter.inner", desc = "Swap prev param" } },
        },

        -- Peek at the definition of the symbol under the cursor in a float
        lsp_interop = {
          enable = true,
          border = "rounded",
          floating_preview_opts = { max_width = 80 },
          peek_definition_code = {
            ["<leader>pf"] = { query = "@function.outer", desc = "Peek function def" },
            ["<leader>pc"] = { query = "@class.outer", desc = "Peek class def" },
          },
        },
      },
    })

    -- ── Treesitter context ────────────────────────────────────────────────────
    local ok, ctx = pcall(require, "treesitter-context")
    if ok then
      ctx.setup({
        enable = true,
        max_lines = 4,
        min_window_height = 12,
        line_numbers = true,
        multiline_threshold = 1,
        trim_scope = "outer",
        mode = "cursor",
        separator = "─", -- Thin line separating context from code
        zindex = 20,
        on_attach = function(buf)
          -- Disable context in diff / commit buffers
          local ft = vim.bo[buf].filetype
          return ft ~= "gitcommit" and ft ~= "diff"
        end,
      })

      -- Jump up into the context (e.g. jump to the enclosing function header)
      vim.keymap.set("n", "[x", function()
        require("treesitter-context").go_to_context(vim.v.count1)
      end, { silent = true, desc = "Jump to context" })
    end

    require("core.function_context").setup()
  end,
}
