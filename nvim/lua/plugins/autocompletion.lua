return {
  "hrsh7th/nvim-cmp",
  event = { "InsertEnter", "CmdlineEnter" },

  dependencies = {
    {
      "L3MON4D3/LuaSnip",
      build = (function()
        if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
          return
        end
        return "make install_jsregexp"
      end)(),
      dependencies = { "rafamadriz/friendly-snippets" },
    },
    "saadparwaiz1/cmp_luasnip",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-nvim-lsp-signature-help",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    -- Completes vim.*, vim.fn.*, etc. when editing your own Lua config -- cheap to
    -- add and immediately useful given this is a Neovim config repo.
    "hrsh7th/cmp-nvim-lua",
  },

  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")
    local compare = require("cmp.config.compare")

    local set_hl = vim.api.nvim_set_hl
    local function define_cmp_hls()
      set_hl(0, "CmpNormal", { bg = "#1a1b2e" }) -- lifted dark bg so menu doesn't bleed into code
      set_hl(0, "CmpBorder", { fg = "#7dcfff" }) -- cyan border for visual distinction
      set_hl(0, "CmpSel", { bg = "#2d3f76", bold = true }) -- selected row
      set_hl(0, "CmpGhostText", { link = "Comment", default = true })

      local kind_hl = {
        CmpItemKindFunction = "#7aa2f7",
        CmpItemKindMethod = "#7aa2f7",
        CmpItemKindConstructor = "#7aa2f7",
        CmpItemKindVariable = "#c0caf5",
        CmpItemKindField = "#c0caf5",
        CmpItemKindProperty = "#c0caf5",
        CmpItemKindClass = "#e0af68",
        CmpItemKindInterface = "#e0af68",
        CmpItemKindStruct = "#e0af68",
        CmpItemKindModule = "#e0af68",
        CmpItemKindEnum = "#e0af68",
        CmpItemKindEnumMember = "#9ece6a",
        CmpItemKindKeyword = "#bb9af7",
        CmpItemKindOperator = "#bb9af7",
        CmpItemKindSnippet = "#9ece6a",
        CmpItemKindText = "#9ece6a",
        CmpItemKindValue = "#9ece6a",
        CmpItemKindConstant = "#ff9e64",
        CmpItemKindFile = "#c0caf5",
        CmpItemKindFolder = "#c0caf5",
        CmpItemKindReference = "#c0caf5",
        CmpItemKindUnit = "#ff9e64",
        CmpItemKindEvent = "#ff9e64",
        CmpItemKindTypeParameter = "#e0af68",
      }
      for group, fg in pairs(kind_hl) do
        set_hl(0, group, { fg = fg, default = true })
      end
    end

    define_cmp_hls()

    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("CmpHighlights", { clear = true }),
      callback = define_cmp_hls,
    })

    -- ─── Snippets ─────────────────────────────────────────────────
    luasnip.config.setup({
      history = true,
      updateevents = "TextChanged,TextChangedI",
      enable_autosnippets = true,
    })
    require("luasnip.loaders.from_vscode").lazy_load()

    -- ─── Icons ────────────────────────────────────────────────────
    local kind_icons = {
      Text = "󰉿",
      Method = "󰊕",
      Function = "󰊕",
      Constructor = "",
      Field = "󰇽",
      Variable = "󰆧",
      Class = "󰌗",
      Interface = "",
      Module = "",
      Property = "",
      Unit = "",
      Value = "󰎠",
      Enum = "",
      Keyword = "󰌋",
      Snippet = "",
      Color = "󰏘",
      File = "󰈙",
      Reference = "",
      Folder = "󰉋",
      EnumMember = "",
      Constant = "󰇽",
      Struct = "",
      Event = "",
      Operator = "󰆕",
      TypeParameter = "󰊄",
    }

    local source_labels = {
      nvim_lsp = "LSP",
      nvim_lsp_signature_help = "Sig",
      luasnip = "Snip",
      buffer = "Buf",
      path = "Path",
      cmdline = "Cmd",
      nvim_lua = "Lua",
    }

    -- ─── Helpers ──────────────────────────────────────────────────
    local function has_words_before()
      local line, col = unpack(vim.api.nvim_win_get_cursor(0))
      return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
    end

    -- ─── Insert-mode completion ───────────────────────────────────
    cmp.setup({

      performance = {
        debounce = 60,
        throttle = 30,
        max_view_entries = 20,
      },

      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },

      -- Inline preview of the selected completion before you confirm it
      -- (the grayed-out "ghost" text you see in VS Code / Copilot-style UIs).
      experimental = {
        ghost_text = { hl_group = "CmpGhostText" },
      },

      -- ── Windows ──────────────────────────────────────────────
      window = {
        completion = cmp.config.window.bordered({
          border = "rounded",
          winhighlight = "Normal:CmpNormal,FloatBorder:CmpBorder,CursorLine:CmpSel,Search:None",
          col_offset = -3,
          side_padding = 1,
          scrollbar = false,
        }),
        documentation = cmp.config.window.bordered({
          border = "rounded",
          winhighlight = "Normal:CmpNormal,FloatBorder:CmpBorder",
          side_padding = 1,
          scrollbar = false,
        }),
      },

      -- ── Keymaps ──────────────────────────────────────────────
      mapping = cmp.mapping.preset.insert({

        ["<C-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
        ["<C-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),

        ["<C-d>"] = cmp.mapping.scroll_docs(4),
        ["<C-u>"] = cmp.mapping.scroll_docs(-4),

        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),

        -- Confirm only if explicitly selected — prevents accidental Enter
        ["<CR>"] = cmp.mapping.confirm({ select = false }),
        -- Force-confirm first item without selecting
        ["<C-y>"] = cmp.mapping.confirm({ select = true }),

        -- Snippet jump forward / backward
        ["<C-l>"] = cmp.mapping(function()
          if luasnip.expand_or_locally_jumpable() then
            luasnip.expand_or_jump()
          end
        end, { "i", "s" }),

        ["<C-h>"] = cmp.mapping(function()
          if luasnip.locally_jumpable(-1) then
            luasnip.jump(-1)
          end
        end, { "i", "s" }),

        -- Smart Tab: menu → snippet → trigger → fallback
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_locally_jumpable() then
            luasnip.expand_or_jump()
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { "i", "s" }),

        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.locally_jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      }),

      -- ── Sources ───────────────────────────────────────────────
      sources = cmp.config.sources({
        { name = "nvim_lsp", priority = 1000 },
        { name = "nvim_lsp_signature_help", priority = 900 },
        { name = "luasnip", priority = 800 },
        { name = "path", priority = 300 },
      }, {
        {
          name = "buffer",
          priority = 500,
          option = {
            get_bufnrs = function()
              return vim.tbl_filter(function(b)
                return vim.api.nvim_buf_is_loaded(b) and vim.bo[b].buftype == ""
              end, vim.api.nvim_list_bufs())
            end,
          },
        },
      }),

      -- ── Formatting ───────────────────────────────────────────
      formatting = {
        fields = { "kind", "abbr", "menu" },
        expandable_indicator = true,
        format = function(entry, item)
          item.kind = string.format(" %s %s", kind_icons[item.kind] or "", item.kind)
          item.menu = string.format("[%s]", source_labels[entry.source.name] or entry.source.name)
          local MAX = 40
          if vim.fn.strchars(item.abbr) > MAX then
            item.abbr = vim.fn.strcharpart(item.abbr, 0, MAX) .. "…"
          end

          return item
        end,
      },

      -- ── Behaviour ────────────────────────────────────────────
      completion = {
        completeopt = "menu,menuone,noinsert",
      },

      -- ── Sorting ──────────────────────────────────────────────
      sorting = {
        priority_weight = 2,
        comparators = {
          compare.offset,
          compare.exact,
          compare.score,
          compare.recently_used,
          compare.locality,
          compare.kind,
          compare.length,
          compare.order,
        },
      },

      -- Suppress completion inside comments
      enabled = function()
        local ctx = require("cmp.config.context")
        if vim.api.nvim_get_mode().mode == "c" then
          return true
        end
        return not ctx.in_treesitter_capture("comment") and not ctx.in_syntax_group("Comment")
      end,
    })

    -- Lua-only extra source: vim.*, vim.fn.*, etc.
    cmp.setup.filetype("lua", {
      sources = cmp.config.sources({
        { name = "nvim_lua" },
        { name = "nvim_lsp", priority = 1000 },
        { name = "luasnip", priority = 800 },
        { name = "path", priority = 300 },
      }, {
        { name = "buffer" },
      }),
    })

    -- ─── Cmdline: search (/ and ?) ────────────────────────────────
    cmp.setup.cmdline({ "/", "?" }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = { { name = "buffer" } },
    })

    -- ─── Cmdline: commands (:) ────────────────────────────────────
    -- Tab confirms the current match instead of jumping to the next one
    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline({
        ["<Tab>"] = {
          c = function()
            if cmp.visible() then
              cmp.confirm({ select = true })
            else
              cmp.complete()
            end
          end,
        },
      }),
      sources = cmp.config.sources(
        { { name = "path" } },
        { { name = "cmdline", option = { ignore_cmds = { "Man", "!" } } } }
      ),
      matching = { disallow_symbol_nonprefix_matching = false },
    })
  end,
}
