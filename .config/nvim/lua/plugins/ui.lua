return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd([[colorscheme tokyonight-night]])
		end,
	},
	{
		"rebelot/kanagawa.nvim",
		opts = {},
	},
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({
				options = { theme = "auto" },
				sections = {
					lualine_a = { "mode" },
					lualine_c = { "filename" },
					lualine_b = { "branch", "diff", "diagnostics" },
					lualine_x = { "encoding", "fileformat", "filetype" },
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
				tabline = {
					lualine_a = { "buffers" },
					lualine_b = {},
					lualine_c = {},
					lualine_x = {},
					lualine_y = {},
					lualine_z = { "tabs" },
				},
			})
		end,
	},
	{
		"nvim-tree/nvim-tree.lua",
		version = "",
		lazy = false,
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")
			require("nvim-tree").setup({
				sort = { sorter = "case_sensitive" },
				view = { width = 35 },
				-- filters = { dotfiles = true }
			})
		end,
	},
	{
		"dimtion/guttermarks.nvim",
		event = { "BufReadPost", "BufNewFile", "BufWritePre", "FileType" },
		config = function()
			vim.keymap.set("n", "m;", require("guttermarks.actions").delete_mark, { desc = "Delete mark under cursor" })

			vim.keymap.set(
				"n",
				"]m",
				require("guttermarks.actions").next_buf_mark,
				{ desc = "Next mark in current buffer" }
			)

			vim.keymap.set(
				"n",
				"[m",
				require("guttermarks.actions").prev_buf_mark,
				{ desc = "Previous mark in current buffer" }
			)

			vim.keymap.set("n", "<leader>mq", function()
				require("guttermarks.actions").marks_to_quickfix()
				vim.cmd("copen")
			end, { desc = "Send marks to quickfix" })

			vim.keymap.set("n", "<leader>mQ", function()
				require("guttermarks.actions").marks_to_quickfix({
					special_mark = true,
				})
				vim.cmd("copen")
			end, { desc = "Send marks to quickfix (include special marks)" })
		end,
	},
	{
		"ibhagwan/fzf-lua",
		dependencies = { "nvim-tree/nvim-web-devicons" }, -- install rg + fd for best performance
		config = function()
			local fzf = require("fzf-lua")
			fzf.setup({
				keymap = {
					fzf = {
						true, -- inherit defaults
						["alt-j"] = "down",
						["alt-k"] = "up",
						["ctrl-d"] = "half-page-down",
						["ctrl-u"] = "half-page-up",
						["ctrl-a"] = "beginning-of-line",
						["ctrl-e"] = "end-of-line",
						["ctrl-g"] = "first",
						["ctrl-G"] = "last",
						["ctrl-z"] = "abort",
					},
					actions = {
						true, -- inherit defaults
						["enter"] = fzf.actions.file_edit_or_qf,
						["ctrl-s"] = fzf.actions.file_split,
						["ctrl-v"] = fzf.actions.file_vsplit,
						["ctrl-t"] = fzf.actions.file_tabedit,
						["alt-q"] = fzf.actions.file_sel_to_qf,
						["alt-Q"] = fzf.actions.file_sel_to_ll,
						["alt-i"] = fzf.actions.toggle_ignore,
						["alt-h"] = fzf.actions.toggle_hidden,
						["alt-f"] = fzf.actions.toggle_follow,
					},
				},
			})

			-- TODO: setup fzf to list lsp refs, defs, decs etc (?)
			vim.keymap.set("n", "<leader>ff", fzf.files, { desc = "Find files" })
			-- vim.keymap.set("n", "<leader>fr", fzf.oldfiles, { desc = "Find recent files" })
			vim.keymap.set("n", "<leader>fb", fzf.buffers, { desc = "Find buffers" })
			vim.keymap.set("n", "<leader>fg", fzf.live_grep, { desc = "Live grep for search string" })
			vim.keymap.set("n", "<leader>*", fzf.grep_cword, { desc = "Search for word under cursor" })
		end,
	},
	-- {
	-- TODO: add gitsigns or mini.diff?
	-- },
	-- {
	-- 	"akinsho/bufferline.nvim",
	-- 	version = "*",
	-- 	dependencies = "nvim-tree/nvim-web-devicons",
	-- 	config = function()
	-- 		require("bufferline").setup({})
	-- 	end,
	-- },
}
