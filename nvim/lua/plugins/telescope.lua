return {
  "nvim-telescope/telescope.nvim",
  branch = "master",
  cmd = "Telescope",
  keys = {
    { "<leader>sf" },
    { "<leader>sg" },
    { "<leader>gl" },
    { "<leader>sb" },
    { "<leader>sh" },
    { "<leader>sd" },
    { "<leader>sr" },
    { "<leader>so" },
    { "<leader>sm" },
    { "<leader>gf" },
    { "<leader>gc" },
    { "<leader>gcf" },
    { "<leader>gS" },
    { "<leader>sy" },
    { "<leader>s/" },
    { "<leader>/" },
    { "<leader><tab>" },
    { "<leader>bb" },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      cond = function()
        return vim.fn.executable("make") == 1
      end,
    },
    "nvim-telescope/telescope-ui-select.nvim",
  },

  config = function()
    local telescope = require("telescope")
    local builtin = require("telescope.builtin")
    local actions = require("telescope.actions")
    local themes = require("telescope.themes")

    local function map_keys(maps)
      for mode, bindings in pairs(maps) do
        for key, action in pairs(bindings) do
          vim.keymap.set(mode, key, action, { silent = true, noremap = true })
        end
      end
    end

    telescope.setup({
      defaults = {
        sorting_strategy = "ascending",
        prompt_prefix = "   ",
        selection_caret = "❯ ",
        winblend = 5,

        layout_strategy = "horizontal",
        layout_config = {
          horizontal = {
            prompt_position = "bottom",
            preview_width = 0.6,
            width = { padding = 0 },
            height = { padding = 0 },
          },
        },

        mappings = {
          i = {
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-l>"] = actions.select_default,
            ["<C-c>"] = actions.close,
          },
          n = { ["q"] = actions.close },
        },

        path_display = {
          filename_first = { reverse_directories = true },
        },
      },

      pickers = {
        find_files = {
          hidden = true,
          file_ignore_patterns = { "node_modules", ".git", ".venv" },
        },

        buffers = {
          initial_mode = "normal",
          sort_lastused = true,
          mappings = {
            n = {
              ["d"] = function(prompt_bufnr)
                local action_state = require("telescope.actions.state")
                local selection = action_state.get_selected_entry()
                if selection then
                  actions.close(prompt_bufnr)
                  vim.api.nvim_buf_delete(selection.bufnr, { force = true })
                end
              end,
              ["l"] = actions.select_default,
            },
          },
        },

        marks = { initial_mode = "normal" },
        oldfiles = { initial_mode = "normal" },
      },

      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
        ["ui-select"] = themes.get_dropdown(),
      },
    })

    pcall(telescope.load_extension, "fzf")
    pcall(telescope.load_extension, "ui-select")

    map_keys({
      n = {
        -- Buffers & Marks
        ["<leader>sb"] = builtin.buffers,
        ["<leader><tab>"] = builtin.buffers,
        ["<leader>bb"] = builtin.buffers,
        ["<leader>sm"] = builtin.marks,
        ["<leader>so"] = builtin.oldfiles,

        -- Git
        ["<leader>gf"] = builtin.git_files,
        ["<leader>gc"] = builtin.git_commits,
        ["<leader>gcf"] = builtin.git_bcommits,
        ["<leader>gb"] = builtin.git_branches, -- no longer clashes (gitsigns blame moved to <leader>gbl)
        ["<leader>gS"] = builtin.git_status, -- no longer clashes (gitsigns stage_buffer moved to <leader>gA)

        -- Search
        ["<leader>sf"] = builtin.find_files,
        ["<leader>sh"] = builtin.help_tags,
        ["<leader>sg"] = builtin.grep_string,
        ["<leader>gl"] = builtin.live_grep,
        ["<leader>sd"] = builtin.diagnostics,
        ["<leader>sr"] = builtin.resume,

        -- LSP Symbols (renamed from <leader>sds to avoid 300ms timeout on <leader>sd)
        ["<leader>sy"] = function()
          builtin.lsp_document_symbols({
            symbols = {
              "Class",
              "Function",
              "Method",
              "Constructor",
              "Interface",
              "Module",
              "Property",
            },
          })
        end,

        -- Grep in open files only
        ["<leader>s/"] = function()
          builtin.live_grep({
            grep_open_files = true,
            prompt_title = "Live Grep in Open Files",
          })
        end,

        -- Fuzzy search current buffer
        ["<leader>/"] = function()
          builtin.current_buffer_fuzzy_find(themes.get_dropdown({ previewer = false }))
        end,
      },
    })
  end,
}
