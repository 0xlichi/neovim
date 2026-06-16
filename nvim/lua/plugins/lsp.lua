return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },

  dependencies = {
    {
      "mason-org/mason.nvim",
      opts = {
        ui = {
          border = "rounded",
          icons = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" },
        },
      },
    },
    "mason-org/mason-lspconfig.nvim",
    "hrsh7th/cmp-nvim-lsp",
    {
      "j-hui/fidget.nvim",
      opts = { notification = { window = { winblend = 0 } } },
    },
  },

  config = function()
    local lsp = vim.lsp
    local api = vim.api
    local tb = require("telescope.builtin")

    -- ─── Diagnostic UI ───────────────────────────────────────────
    vim.diagnostic.config({
      underline = true,
      update_in_insert = false,
      severity_sort = true,
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = " ",
          [vim.diagnostic.severity.WARN] = " ",
          [vim.diagnostic.severity.HINT] = " ",
          [vim.diagnostic.severity.INFO] = " ",
        },
      },
      float = {
        border = "rounded",
        source = true,
        header = "",
        prefix = "",
      },
    })

    -- ─── Augroups (must be defined BEFORE use) ───────────────────
    local attach_group = api.nvim_create_augroup("UserLspAttach", { clear = true })
    local highlight_group = api.nvim_create_augroup("LspHighlight", { clear = true })
    local hint_group = api.nvim_create_augroup("LspInlayHints", { clear = true })

    -- ─── On Attach ───────────────────────────────────────────────
    api.nvim_create_autocmd("LspAttach", {
      group = attach_group,
      callback = function(event)
        local buf = event.buf
        local client = lsp.get_client_by_id(event.data.client_id)
        local methods = lsp.protocol.Methods

        local map = function(keys, fn, desc, mode)
          vim.keymap.set(mode or "n", keys, fn, { buffer = buf, desc = "LSP: " .. desc })
        end

        -- ── Navigation ──────────────────────────────────────────
        map("gd", tb.lsp_definitions, "Goto Definition")
        map("gD", lsp.buf.declaration, "Goto Declaration")
        map("gr", tb.lsp_references, "Goto References")
        map("gI", tb.lsp_implementations, "Goto Implementation")
        map("gy", tb.lsp_type_definitions, "Goto Type Definition")

        -- ── Symbols ─────────────────────────────────────────────
        map("<leader>ds", tb.lsp_document_symbols, "Document Symbols")
        map("<leader>ws", tb.lsp_dynamic_workspace_symbols, "Workspace Symbols")

        -- ── Actions ─────────────────────────────────────────────
        map("<leader>rn", lsp.buf.rename, "Rename Symbol")
        map("<leader>ca", lsp.buf.code_action, "Code Action")
        map("<leader>ca", lsp.buf.code_action, "Code Action", "v")

        -- ── Hover & Signature (modern API with border) ───────────
        map("K", function()
          lsp.buf.hover({ border = "rounded", max_width = 80 })
        end, "Hover Documentation")
        map("gK", function()
          lsp.buf.signature_help({ border = "rounded", max_width = 80 })
        end, "Signature Help")
        map("<C-k>", function()
          lsp.buf.signature_help({ border = "rounded", max_width = 80 })
        end, "Signature Help", "i")

        -- ── Diagnostics ──────────────────────────────────────────
        map("[d", function()
          vim.diagnostic.jump({ count = -1 })
        end, "Prev Diagnostic")
        map("]d", function()
          vim.diagnostic.jump({ count = 1 })
        end, "Next Diagnostic")
        map("[e", function()
          vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR })
        end, "Prev Error")
        map("]e", function()
          vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR })
        end, "Next Error")
        map("<leader>dl", vim.diagnostic.open_float, "Line Diagnostics")
        map("<leader>dq", vim.diagnostic.setloclist, "Diagnostics to Quickfix")

        -- ── Document Highlight ───────────────────────────────────
        if client and client:supports_method(methods.textDocument_documentHighlight) then
          api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            buffer = buf,
            group = highlight_group,
            callback = lsp.buf.document_highlight,
          })
          api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            buffer = buf,
            group = highlight_group,
            callback = lsp.buf.clear_references,
          })
        end

        -- ── Inlay Hints ──────────────────────────────────────────
        if client and client:supports_method(methods.textDocument_inlayHint) then
          map("<leader>th", function()
            local enabled = lsp.inlay_hint.is_enabled({ bufnr = buf })
            lsp.inlay_hint.enable(not enabled, { bufnr = buf })
          end, "Toggle Inlay Hints")

          api.nvim_create_autocmd({ "BufEnter", "InsertLeave" }, {
            buffer = buf,
            group = hint_group,
            callback = function()
              lsp.inlay_hint.enable(true, { bufnr = buf })
            end,
          })
          api.nvim_create_autocmd("InsertEnter", {
            buffer = buf,
            group = hint_group,
            callback = function()
              lsp.inlay_hint.enable(false, { bufnr = buf })
            end,
          })
        end

        -- ── Code Lens ────────────────────────────────────────────
        if client and client:supports_method(methods.textDocument_codeLens) then
          lsp.codelens.enable(true, { bufnr = buf })
          map("<leader>cl", lsp.codelens.run, "Run Code Lens")
        end
      end,
    })

    -- ─── Capabilities ─────────────────────────────────────────────
    local capabilities = vim.tbl_deep_extend(
      "force",
      lsp.protocol.make_client_capabilities(),
      require("cmp_nvim_lsp").default_capabilities()
    )
    capabilities.textDocument.completion.completionItem.labelDetailsSupport = true
    capabilities.textDocument.foldingRange = { dynamicRegistration = false, lineFoldingOnly = true }

    -- ─── LSP Servers ──────────────────────────────────────────────
    local servers = {

      lua_ls = {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = {
              checkThirdParty = false,
              library = api.nvim_get_runtime_file("", true),
            },
            hint = {
              enable = true,
              setType = true,
              paramName = "All",
            },
            format = { enable = false },
          },
        },
      },

      -- basedpyright = {
      --   settings = {
      --     python = {
      --       pythonPath = vim.fn.exepath("python3"),
      --       analysis = {
      --         typeCheckingMode = "standard",
      --         diagnosticMode = "workspace",
      --         autoSearchPaths = true,
      --         useLibraryCodeForTypes = true,
      --         inlayHints = {
      --           variableTypes = true,
      --           functionReturnTypes = true,
      --           callArgumentNames = true,
      --           pytestParameters = true,
      --         },
      --       },
      --     },
      --   },
      -- },
      --
      -- ruff = {
      --   on_attach = function(client)
      --     client.server_capabilities.hoverProvider = false
      --     client.server_capabilities.documentFormattingProvider = false
      --     client.server_capabilities.documentRangeFormattingProvider = false
      --   end,
      -- },
      --
      -- -- ── C / C++ ─────────────────────────────────────────────────
      -- clangd = {
      --   cmd = {
      --     "clangd",
      --     "--background-index",
      --     "--clang-tidy",
      --     "--header-insertion=iwyu",
      --     "--completion-style=detailed",
      --     "--function-arg-placeholders",
      --     "--fallback-style=llvm",
      --   },
      --   filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
      --   -- clangd needs a compile_commands.json (or compile_flags.txt) to fully
      --   -- understand your project; without one it still works but falls back
      --   -- to single-file heuristics. CMake: `set(CMAKE_EXPORT_COMPILE_COMMANDS
      --   -- ON)`; Makefiles: generate one with `bear -- make` or `compiledb make`.
      -- },
      --
      -- -- ── Rust ────────────────────────────────────────────────────
      -- rust_analyzer = {
      --   settings = {
      --     ["rust-analyzer"] = {
      --       cargo = {
      --         allFeatures = true,
      --         buildScripts = { enable = true },
      --       },
      --       checkOnSave = true,
      --       check = { command = "clippy" },
      --       procMacro = { enable = true },
      --       inlayHints = {
      --         bindingModeHints = { enable = false },
      --         chainingHints = { enable = true },
      --         closureReturnTypeHints = { enable = "always" },
      --         lifetimeElisionHints = { enable = "skip_trivial" },
      --         reborrowHints = { enable = "mutable" },
      --         typeHints = { enable = true },
      --       },
      --     },
      --   },
      -- },
      --
      -- -- ── .NET / C# ───────────────────────────────────────────────
      -- omnisharp = {
      --   cmd = { "omnisharp" },
      --   enable_roslyn_analyzers = true,
      --   enable_import_completion = true,
      --   organize_imports_on_format = true,
      --   settings = {
      --     FormattingOptions = { EnableEditorConfigSupport = true },
      --     RoslynExtensionsOptions = { enableAnalyzersSupport = true },
      --   },
      -- },
      --
      -- ts_ls = {
      --   settings = {
      --     typescript = {
      --       format = { enable = false },
      --       inlayHints = {
      --         includeInlayParameterNameHints = "all",
      --         includeInlayParameterNameHintsWhenArgumentMatchesName = false,
      --         includeInlayFunctionParameterTypeHints = true,
      --         includeInlayVariableTypeHints = true,
      --         includeInlayPropertyDeclarationTypeHints = true,
      --         includeInlayFunctionLikeReturnTypeHints = true,
      --         includeInlayEnumMemberValueHints = true,
      --       },
      --     },
      --
      --     javascript = {
      --       format = { enable = false },
      --       inlayHints = {
      --         includeInlayParameterNameHints = "literals",
      --         includeInlayFunctionLikeReturnTypeHints = true,
      --       },
      --     },
      --   },
      -- },
      --
      -- gopls = {
      --   settings = {
      --     gopls = {
      --       gofumpt = true,
      --       staticcheck = true,
      --       vulncheck = "Imports",
      --       usePlaceholders = false,
      --       completeFunctionCalls = true,
      --       matcher = "Fuzzy",
      --       semanticTokens = true,
      --       diagnosticsDelay = "500ms",
      --
      --       analyses = {
      --         unusedparams = true,
      --         unusedvariable = true,
      --         shadow = true,
      --         nilness = true,
      --         useany = true,
      --         appends = true,
      --         assign = true,
      --         atomic = true,
      --         bools = true,
      --         composites = true,
      --         copylocks = true,
      --         defers = true,
      --         deprecated = true,
      --         errorsas = true,
      --         httpresponse = true,
      --         infertypeargs = true,
      --         loopclosure = true,
      --         lostcancel = true,
      --         printf = true,
      --         slog = true,
      --         sortslice = true,
      --         stdversion = true,
      --         stringintconv = true,
      --         testinggoroutine = true,
      --         timeformat = true,
      --         unmarshal = true,
      --         unreachable = true,
      --         unusedresult = true,
      --         waitgroup = true,
      --       },
      --
      --       codelenses = {
      --         generate = true,
      --         regenerate_cgo = true,
      --         tidy = true,
      --         upgrade_dependency = true,
      --         vendor = true,
      --         vulncheck = true,
      --         test = true,
      --         gc_details = false,
      --       },
      --
      --       hints = {
      --         assignVariableTypes = true,
      --         compositeLiteralFields = true,
      --         compositeLiteralTypes = true,
      --         constantValues = true,
      --         functionTypeParameters = true,
      --         parameterNames = false,
      --         rangeVariableTypes = true,
      --       },
      --     },
      --   },
      -- },
      --
      -- html = { filetypes = { "html" } },
      -- eslint = { settings = { workingDirectory = { mode = "auto" } } },
      -- bashls = {
      --   settings = {
      --     bashIde = { globPattern = "**/*@(.sh|.bash|.zsh|.command)" },
      --   },
      -- },
      --
      -- tailwindcss = {
      --   filetypes = {
      --     "html",
      --     "css",
      --     "scss",
      --     "javascript",
      --     "javascriptreact",
      --     "typescript",
      --     "typescriptreact",
      --     "vue",
      --     "svelte",
      --   },
      --   init_options = { userLanguages = { eelixir = "html" } },
      -- },
      --
      -- dockerls = {},
      -- docker_compose_language_service = {},
    }

    -- ─── Install & Register ───────────────────────────────────────
    for name, cfg in pairs(servers) do
      cfg.capabilities = vim.tbl_deep_extend("force", {}, capabilities, cfg.capabilities or {})
      lsp.config(name, cfg)
    end

    require("mason-lspconfig").setup({
      ensure_installed = vim.tbl_keys(servers),
      automatic_enable = true,
    })
  end,
}
