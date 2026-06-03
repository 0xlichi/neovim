return {
  "nvimtools/none-ls.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "nvimtools/none-ls-extras.nvim",
    "jay-babu/mason-null-ls.nvim",
    "nvim-lua/plenary.nvim",
  },
  config = function()
    local null_ls = require("null-ls")
    local mason_null_ls = require("mason-null-ls")
    local formatting = null_ls.builtins.formatting
    local diagnostics = null_ls.builtins.diagnostics

    -- ── Mason: auto-install every tool declared below ──────────────────────────
    mason_null_ls.setup({
      ensure_installed = {
        "prettier", -- JS / TS / HTML / CSS / JSON / YAML / Markdown
        -- "stylua", -- Lua
        -- "ruff", -- Python (format + lint)
        -- "gofumpt", -- Go – strict gofmt superset
        -- "goimports", -- Go – organise imports
        -- "shfmt", -- Shell
        -- "sqlfluff", -- SQL
        -- "hadolint", -- Dockerfile
      },
      automatic_installation = true,
    })

    -- ── Format-on-save (opt-in per buffer with <leader>tf) ─────────────────────
    local fmt_enabled = true -- global toggle

    local fmt_augroup = vim.api.nvim_create_augroup("NoneLsFmt", { clear = true })
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = fmt_augroup,
      callback = function()
        if not fmt_enabled then
          return
        end
        local ft = vim.bo.filetype
        local sources = null_ls.get_source({ method = null_ls.methods.FORMATTING, filetype = ft })
        if #sources > 0 then
          vim.lsp.buf.format({
            async = false,
            timeout_ms = 3000,
            filter = function(client)
              return client.name == "null-ls"
            end,
          })
        end
      end,
    })

    vim.keymap.set("n", "<leader>tf", function()
      fmt_enabled = not fmt_enabled
      vim.notify("Format-on-save " .. (fmt_enabled and "enabled" or "disabled"), vim.log.levels.INFO)
    end, { desc = "None-ls: toggle format-on-save" })

    vim.keymap.set({ "n", "v" }, "<leader>lf", function()
      vim.lsp.buf.format({ async = false, timeout_ms = 3000 })
    end, { desc = "None-ls: format buffer / range" })

    -- ── Sources ────────────────────────────────────────────────────────────────
    null_ls.setup({
      -- Show null-ls as a named source in :LspInfo / status lines
      default_timeout = 5000,
      debug = false, -- flip to true to trace source activity

      -- ── Web ────────────────────────────────────────────────────────────────
      sources = {
        formatting.prettier.with({
          filetypes = {
            "html",
            "css",
            "scss",
            "less",
            "javascript",
            "javascriptreact",
            "typescript",
            "typescriptreact",
            "vue",
            "svelte",
            "astro",
            "json",
            "jsonc",
            "yaml",
            "toml",
            "markdown",
            "mdx",
            "graphql",
          },
          -- Respect local .prettierrc if present; fall back to these
          extra_args = function(params)
            local rc = vim.fn.findfile(".prettierrc", params.root .. ";")
            if rc ~= "" then
              return {}
            end
            return {
              "--single-quote",
              "--trailing-comma",
              "es5",
              "--print-width",
              "100",
            }
          end,
          condition = function(utils)
            return not utils.root_has_file({ ".prettierignore" })
              and not utils.root_has_file({ ".prettierrc.js", ".prettierrc.cjs" })
          end,
        }),

        -- ── Lua ──────────────────────────────────────────────────────────────
        formatting.stylua.with({
          extra_args = { "--indent-type", "Spaces", "--indent-width", "2" },
          -- Prefer project-level stylua.toml when present
          condition = function(utils)
            return utils.root_has_file({ "stylua.toml", ".stylua.toml" }) or true -- fall back to extra_args above if no config file
          end,
        }),

        -- ── Python ───────────────────────────────────────────────────────────
        require("none-ls.formatting.ruff_format").with({
          extra_args = { "--line-length", "100" },
        }),
        require("none-ls.diagnostics.ruff").with({
          extra_args = { "--select", "E,F,W,I,N,UP,B,C4,SIM,RUF" },
        }),

        -- ── Go ───────────────────────────────────────────────────────────────
        formatting.gofumpt,
        formatting.goimports.with({
          extra_args = { "-local", "" }, -- Replace with your module path for local grouping
        }),

        -- ── Shell ─────────────────────────────────────────────────────────────
        formatting.shfmt.with({
          extra_args = { "-i", "2", "-ci", "-sr" }, -- 2-space indent, case-indent, space after redirect
          filetypes = { "sh", "bash", "zsh" },
        }),

        -- ── SQL ───────────────────────────────────────────────────────────────
        formatting.sqlfluff.with({
          extra_args = { "--dialect", "mysql" }, -- Change to ansi/postgres/bigquery as needed
        }),
        diagnostics.sqlfluff.with({
          extra_args = { "--dialect", "mysql" },
        }),

        -- ── Dockerfile ────────────────────────────────────────────────────────
        diagnostics.hadolint,

        -- ── Markdown ──────────────────────────────────────────────────────────
        diagnostics.markdownlint.with({
          extra_args = { "--disable", "MD013" }, -- Disable line-length rule (prettier handles it)
        }),
      },

      -- Diagnostics appear only after the buffer is saved to reduce noise
      on_attach = function(_, bufnr)
        vim.bo[bufnr].formatexpr = ""
      end,
    })
  end,
}
