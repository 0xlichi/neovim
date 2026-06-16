return {
  "nvim-telescope/telescope.nvim",
  branch = "master",
  cmd = "Telescope",
  keys = {
    { "<leader>sf", desc = "Find Files" },
    { "<leader>sg", desc = "Grep Word Under Cursor" },
    { "<leader>gl", desc = "Live Grep" },
    { "<leader>sb", desc = "Buffers" },
    { "<leader>sh", desc = "Help Tags" },
    { "<leader>sd", desc = "Diagnostics" },
    { "<leader>sr", desc = "Resume Last Search" },
    { "<leader>so", desc = "Old Files" },
    { "<leader>sm", desc = "Marks" },
    { "<leader>gf", desc = "Git Files" },
    { "<leader>gc", desc = "Git Commits" },
    { "<leader>gcf", desc = "Git Buffer Commits" },
    { "<leader>gb", desc = "Git Branches" },
    { "<leader>gS", desc = "Git Status" },
    { "<leader>sy", desc = "LSP Symbols" },
    { "<leader>s/", desc = "Grep Open Files" },
    { "<leader>/", desc = "Fuzzy Find In Buffer" },
    { "<leader><tab>", desc = "Buffers" },
    { "<leader>bb", desc = "Buffers" },
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
          local desc, fn = nil, action
          -- allow { fn, "description" } pairs without changing every call site
          if type(action) == "table" then
            fn, desc = action[1], action[2]
          end
          vim.keymap.set(mode, key, fn, { silent = true, noremap = true, desc = desc })
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
        ["<leader>sb"] = { builtin.buffers, "Buffers" },
        ["<leader><tab>"] = { builtin.buffers, "Buffers" },
        ["<leader>bb"] = { builtin.buffers, "Buffers" },
        ["<leader>sm"] = { builtin.marks, "Marks" },
        ["<leader>so"] = { builtin.oldfiles, "Old Files" },

        -- Git
        ["<leader>gf"] = { builtin.git_files, "Git Files" },
        ["<leader>gc"] = { builtin.git_commits, "Git Commits" },
        ["<leader>gcf"] = { builtin.git_bcommits, "Git Buffer Commits" },
        ["<leader>gb"] = { builtin.git_branches, "Git Branches" },
        ["<leader>gS"] = { builtin.git_status, "Git Status" },

        -- Search
        ["<leader>sf"] = { builtin.find_files, "Find Files" },
        ["<leader>sh"] = { builtin.help_tags, "Help Tags" },
        ["<leader>sg"] = { builtin.grep_string, "Grep Word Under Cursor" },
        ["<leader>gl"] = { builtin.live_grep, "Live Grep" },
        ["<leader>sd"] = { builtin.diagnostics, "Diagnostics" },
        ["<leader>sr"] = { builtin.resume, "Resume Last Search" },

        -- LSP Symbols (renamed from <leader>sds to avoid 300ms timeout on <leader>sd)
        ["<leader>sy"] = {
          function()
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
          "LSP Symbols",
        },

        -- Grep in open files only
        ["<leader>s/"] = {
          function()
            builtin.live_grep({
              grep_open_files = true,
              prompt_title = "Live Grep in Open Files",
            })
          end,
          "Grep Open Files",
        },

        -- Fuzzy search current buffer
        ["<leader>/"] = {
          function()
            builtin.current_buffer_fuzzy_find(themes.get_dropdown({ previewer = false }))
          end,
          "Fuzzy Find In Buffer",
        },
      },
    })
  end,
}
