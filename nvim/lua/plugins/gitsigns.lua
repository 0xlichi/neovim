return {
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		signs = {
			add = { text = " ▎" },
			change = { text = " ▎" },
			delete = { text = " _ " },
			topdelete = { text = " __ " },
			changedelete = { text = " ▎" },
			untracked = { text = " ▎" },
		},
		signs_staged = {
			add = { text = " ▎" },
			change = { text = " ▎" },
			delete = { text = " _ " },
			topdelete = { text = " __ " },
			changedelete = { text = " ▎" },
		},
		signs_staged_enable = true,

		current_line_blame = false,
		current_line_blame_opts = {
			virt_text = true,
			virt_text_pos = "eol",
			delay = 400,
			ignore_whitespace = true,
		},
		current_line_blame_formatter = " <author>, <author_time:%d %b %Y> · <summary>",

		signcolumn = true,
		numhl = false,
		linehl = false,
		word_diff = false,
		watch_gitdir = { follow_files = true },
		auto_attach = true,
		attach_to_untracked = true,
		update_debounce = 100,
		max_file_length = 40000,

		preview_config = {
			border = "rounded",
			style = "minimal",
			relative = "cursor",
			row = 0,
			col = 1,
		},

		on_attach = function(bufnr)
			local gs = require("gitsigns")
			local map = function(mode, lhs, rhs, desc)
				vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
			end

			map("n", "]h", function()
				if vim.wo.diff then
					vim.cmd.normal({ "]c", bang = true })
				else
					gs.nav_hunk("next")
				end
			end, "Git: next hunk")

			map("n", "[h", function()
				if vim.wo.diff then
					vim.cmd.normal({ "[c", bang = true })
				else
					gs.nav_hunk("prev")
				end
			end, "Git: prev hunk")

			map("n", "]H", function()
				gs.nav_hunk("last")
			end, "Git: last hunk")
			map("n", "[H", function()
				gs.nav_hunk("first")
			end, "Git: first hunk")

			map({ "n", "v" }, "<leader>gs", gs.stage_hunk, "Git: stage hunk")
			map({ "n", "v" }, "<leader>gr", gs.reset_hunk, "Git: reset hunk")
			map("n", "<leader>ga", gs.stage_buffer, "Git: stage buffer")
			map("n", "<leader>gR", gs.reset_buffer, "Git: reset buffer")
			map("n", "<leader>gu", gs.undo_stage_hunk, "Git: undo stage hunk")

			map("n", "<leader>gp", gs.preview_hunk, "Git: preview hunk")
			map("n", "<leader>gP", gs.preview_hunk_inline, "Git: preview hunk inline")

			map("n", "<leader>gbl", function()
				gs.toggle_current_line_blame()
			end, "Git: toggle line blame")
			map("n", "<leader>gbf", function()
				gs.blame_line({ full = true })
			end, "Git: blame line (full)")

			map("n", "<leader>gd", gs.diffthis, "Git: diff this")
			map("n", "<leader>gD", function()
				gs.diffthis("~")
			end, "Git: diff against ~")
			map("n", "<leader>gw", gs.toggle_word_diff, "Git: toggle word diff")

			map({ "o", "x" }, "ih", ":<C-u>Gitsigns select_hunk<CR>", "Git: select hunk")
		end,
	},
}
