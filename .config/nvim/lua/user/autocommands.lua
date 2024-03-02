-- Remove all trailing whitespace on save
vim.api.nvim_command([[
    autocmd BufWritePre * %s/\s\+$//e
    autocmd BufWritePre * %s/\n\+\%$//e
    autocmd BufWritePre *.[ch] %s/\%$/\r/e
]])

-- Don't continue comment on newline
vim.api.nvim_command([[
    autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
]])

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function(args)
		require("conform").format({ bufnr = args.buf })
	end,
})
