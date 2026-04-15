return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		opts = {
			ensure_installed = { "all" },
			auto_install = true,
			highlight = {
				enable = true,
				-- disable treesitter on large files (slow)
				disable = function(lang, buf)
					local max_filesize = 100 * 1024 -- 100 KB
					local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
					if ok and stats and stats.size > max_filesize then
						return true
					end
				end,
			},
		},
	},
	{
		"https://github.com/neovim/nvim-lspconfig",
		-- no opts: passing opts is deprecated
	},
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
		opts = {},
	},
	{
		"numToStr/Comment.nvim",
		dependencies = {},
		keys = {},
		opts = { "JoosepAlviste/nvim-ts-context-commentstring" },
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		-- off by default, but still want to check indents on demand
		opts = { enabled = false },
	},
	{
		-- code outline (requires lsp/treesitter enabled for lang)
		"stevearc/aerial.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<CR>")
			require("aerial").setup({
				on_attach = function(bufnr)
					vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
					vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
				end,
			})
		end,
	},
	{
		"stevearc/conform.nvim",
		config = function()
			require("conform").setup({
				format_on_save = {
					timeout_ms = 500,
					lsp_format = "fallback",
				},
				formatters_by_ft = {
					lua = { "stylua" },
					go = { "goimports", "gofmt" },
					rust = { "rustfmt" },
					markdown = { "rumdl" },
				},
			})
		end,
	},
	{
		"saghen/blink.cmp",
		branch = "v1",
		dependencies = { "rafamadriz/friendly-snippets" },
		opts = {
			keymap = {
				preset = "default",
				["<C-n>"] = { "select_next", "fallback" },
				["<C-p>"] = { "select_prev", "fallback" },
				["<C-j>"] = { "scroll_documentation_down", "fallback" },
				["<C-k>"] = { "scroll_documentation_up", "fallback" },
				-- ["<C-l>"] = { "snippet_forward", "fallback" },
				-- ["<C-h>"] = { "snippet_backward", "fallback" },
			},
			appearance = {
				nerd_font_variant = "normal",
				use_nvim_cmp_as_default = true,
			},
			completion = {
				menu = {
					auto_show = false,
				},
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 200,
				},
				ghost_text = { enabled = false },
			},
			sources = {
				default = { "lsp", "path", "buffer", "snippets" },
			},
			fuzzy = {
				implementation = "prefer_rust_with_warning",
			},
		},
	},
}
