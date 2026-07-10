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

    -- Mason: auto-install every tool declared below
    mason_null_ls.setup({
      ensure_installed = {
        "prettier", -- JS / TS / HTML / CSS / JSON / YAML / Markdown
        "stylua", -- Lua
        "ruff", -- Python (format only here; linting owned by the ruff LSP client)
        "shfmt", -- Shell
        "hadolint", -- Dockerfile
       -- "gofumpt",
       -- "goimports",
       -- "sqlfluff",
      },
      automatic_installation = true,
    })

    -- Sources
    null_ls.setup({
      default_timeout = 5000,
      debug = false,

      sources = {
        -- Web
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

        -- Lua
        formatting.stylua.with({
          extra_args = { "--indent-type", "Spaces", "--indent-width", "2" },
          condition = function(utils)
            return utils.root_has_file({ "stylua.toml", ".stylua.toml" }) or true
          end,
        }),

        -- Python
        require("none-ls.formatting.ruff_format"),

        -- Go
        formatting.gofumpt,
        formatting.goimports.with({
          extra_args = { "-local", "" }, -- Replace with your module path for local grouping
        }),

        -- Shell
        formatting.shfmt.with({
          extra_args = { "-i", "2", "-ci", "-sr" },
          filetypes = { "sh", "bash", "zsh" },
        }),

        -- SQL
        formatting.sqlfluff.with({
          extra_args = { "--dialect", "mysql" },
        }),
        diagnostics.sqlfluff.with({
          extra_args = { "--dialect", "mysql" },
        }),

        -- Dockerfile
        diagnostics.hadolint,
      },

      on_attach = function(_, bufnr)
        vim.bo[bufnr].formatexpr = ""
      end,
    })

    -- Format dispatcher
    local function format(bufnr)
      bufnr = bufnr or vim.api.nvim_get_current_buf()
      local ft = vim.bo[bufnr].filetype
      local has_none_ls_formatter = #null_ls.get_source({ method = null_ls.methods.FORMATTING, filetype = ft }) > 0

      local filter = function(client)
        if has_none_ls_formatter then
          return client.name == "null-ls"
        end
        return client.name ~= "null-ls"
      end

      local candidates = vim.tbl_filter(function(c)
        return filter(c) and c:supports_method("textDocument/formatting")
      end, vim.lsp.get_clients({ bufnr = bufnr }))

      if #candidates == 0 then
        return
      end

      vim.lsp.buf.format({ bufnr = bufnr, async = false, timeout_ms = 3000, filter = filter })
    end

    -- Format-on-save (global toggle via <leader>tf)
    local fmt_enabled = true

    local fmt_augroup = vim.api.nvim_create_augroup("NoneLsFmt", { clear = true })
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = fmt_augroup,
      callback = function(args)
        if fmt_enabled then
          format(args.buf)
        end
      end,
    })

    local ruff_organize_imports_augroup = vim.api.nvim_create_augroup("RuffOrganizeImports", { clear = true })
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = ruff_organize_imports_augroup,
      pattern = "*.py",
      callback = function(args)
        local clients = vim.lsp.get_clients({ bufnr = args.buf, name = "ruff" })
        if #clients == 0 then
          return
        end
        local client = clients[1]

        local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
        ---@diagnostic disable-next-line: inject-field
        params.context = { only = { "source.organizeImports" }, diagnostics = {} }

        local result = vim.lsp.buf_request_sync(args.buf, "textDocument/codeAction", params, 1000)
        if not result then
          return
        end

        for _, res in pairs(result) do
          for _, action in pairs(res.result or {}) do
            if action.edit then
              vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
            elseif action.command then
              client:exec_cmd(action.command, { bufnr = args.buf })
            end
          end
        end
      end,
    })

    vim.keymap.set("n", "<leader>tf", function()
      fmt_enabled = not fmt_enabled
      vim.notify("Format-on-save " .. (fmt_enabled and "enabled" or "disabled"), vim.log.levels.INFO)
    end, { desc = "None-ls: toggle format-on-save" })

    vim.keymap.set({ "n", "v" }, "<leader>lf", function()
      format()
    end, { desc = "None-ls: format buffer / range" })
  end,
}
