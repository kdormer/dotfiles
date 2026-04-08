-- ~/.config/nvim/init.lua

-- =========================================================
-- INIT
-- =========================================================
vim.g.mapleader = " "
vim.cmd "filetype plugin on"   -- enable filetype detection and plugins
vim.cmd "syntax on"            -- enable syntax highlighting
local map = vim.keymap.set     -- alias for less verbose keymaps
local autocmd = vim.api.nvim_create_autocmd -- alias for less verbose autocmds


-- =========================================================
-- OPTIONS
-- =========================================================

-- Line numbers
vim.opt.relativenumber = true  -- show relative line numbers for all other lines
vim.opt.number = true          -- show absolute line number on current line

-- Tabs / indentation
vim.opt.tabstop = 4            -- how many spaces a tab character counts for visually
vim.opt.shiftwidth = 4         -- how many spaces >> and << indent by
vim.opt.expandtab = true       -- insert spaces when Tab is pressed
vim.opt.smartindent = true     -- automatically indent new lines based on context

-- Search
vim.opt.ignorecase = true      -- case insensitive search by default
vim.opt.smartcase = true       -- override ignorecase if search contains uppercase
vim.opt.hlsearch = true        -- highlight all search matches
vim.opt.grepformat = "%f:%l:%c:%m"

-- Appearance
vim.opt.termguicolors = true   -- enable 24-bit colour
vim.opt.signcolumn = "yes"     -- always show sign column to prevent layout shifting
vim.opt.statusline = "%f %m %r %y %=%l/%L :%c"  -- filename, flags, filetype, position
vim.opt.cursorline = true      -- highlight the line the cursor is on
vim.opt.ruler = false          -- hide position info, already in statusline

-- Behaviour
vim.opt.splitright = true      -- vertical splits open to the right
vim.opt.splitbelow = true      -- horizontal splits open below
vim.opt.scrolloff = 8          -- keep 8 lines visible above/below cursor when scrolling
vim.opt.timeoutlen = 800       -- ms to wait for a key sequence to complete (affects jk, leader chords)
vim.opt.clipboard = "unnamedplus"  -- use system clipboard for all yank/paste operations
vim.opt.wrap = false           -- don't wrap long lines
vim.opt.swapfile = false       -- don't create swap files
vim.opt.undofile = true        -- persist undo history across sessions
vim.opt.undodir = vim.fn.expand("~/.cache/nvim/undo") -- set undofile dir to XDG cache
vim.opt.hidden = true          -- allow switching buffers without saving
vim.opt.autoread = true        -- reload files changed outside of neovim
vim.opt.encoding = "utf-8"     -- set file encoding
vim.opt.mouse=""               -- disable mouse support
vim.opt.virtualedit="none"     -- honestly, just remind myself this exists and can be changed on the fly


-- =========================================================
-- GENERAL AUTOCMDS
-- =========================================================

-- Neovim filetype plugins set formatoptions automatically, which causes
-- comment leaders (e.g. // or --) to be inserted on new lines.
-- BufEnter fires after filetype plugins so this override sticks.
autocmd("BufEnter", {
    pattern = "*",
    callback = function()
        vim.opt_local.formatoptions:remove({ "c", "r", "o" })
    end,
})

-- Flash the yanked region briefly so you can see what was copied
autocmd("TextYankPost", {
    callback = function()
        vim.highlight.on_yank({ higroup = "Visual", timeout = 150 })
    end,
})

-- Strip trailing whitespace from every line before saving
autocmd("BufWritePre", {
    pattern = "*",
    callback = function()
        vim.cmd [[%s/\s\+$//e]]  -- \s\+ matches one or more whitespace chars, the e flag suppresses errors if no match
    end,
})


-- =========================================================
-- ZOOM SPLIT
-- =========================================================

-- zoom_states stores per-tab zoom state so each tab is tracked independently.
-- Keyed by tabpage handle (an integer returned by nvim_get_current_tabpage).
local zoom_states = {}

map("n", "<leader>z", function()
    local tab = vim.api.nvim_get_current_tabpage()
    local state = zoom_states[tab] or { zoomed = false, wins = nil, win_count = nil }

    -- nvim_tabpage_list_wins returns all windows including floating ones (e.g. LSP popups).
    -- We filter to only normal windows using nvim_win_get_config — floating windows
    -- have a non-empty relative field, normal windows have relative == "".
    local wins = vim.tbl_filter(function(w)
        return vim.api.nvim_win_get_config(w).relative == ""
    end, vim.api.nvim_tabpage_list_wins(tab))
    local win_count = #wins

    if state.zoomed then
        if win_count ~= state.win_count then
            -- A split was opened or closed while zoomed — the saved layout is stale
            -- so just equalise all splits rather than attempting a broken restore
            vim.cmd("wincmd =")
        else
            -- winrestcmd() saved the exact window dimensions as a command string.
            -- pcall catches errors in case any window in the saved layout no longer exists.
            local ok = pcall(vim.cmd, state.wins)
            if not ok then
                vim.cmd("wincmd =")  -- fallback if restore fails
            end
        end
        zoom_states[tab] = { zoomed = false, wins = nil, win_count = nil }
    else
        if win_count == 1 then
            vim.notify("No splits to zoom", vim.log.levels.INFO)
            return
        end
        zoom_states[tab] = {
            zoomed = true,
            wins = vim.fn.winrestcmd(),  -- capture exact dimensions of all windows
            win_count = win_count,       -- snapshot count to detect layout changes later
        }
        vim.cmd("wincmd |")  -- maximise width
        vim.cmd("wincmd _")  -- maximise height
    end
end, { desc = "Toggle zoom" })

-- Clean up stale tab state when a tab is closed to prevent the table growing unboundedly
autocmd("TabClosed", {
    callback = function()
        local tab = vim.api.nvim_get_current_tabpage()
        zoom_states[tab] = nil
    end,
})


-- =========================================================
-- KEYMAPS
-- =========================================================

map("i", "jk", "<Esc>", { desc = "Exit insert mode" })
-- map("n", "<Esc>", ":nohlsearch<CR>", { desc = "Clear search highlights" })
map("n", "<S-w>", ":w | nohl<CR>", { desc = "Save and clear search highlights" })

-- Move selected lines up and down, reindenting as they move (= reindents selection)
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Split navigation
map("n", "<C-h>", "<C-w>h", { desc = "Move to left split" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower split" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper split" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right split" })

-- Split resizing
map("n", "<C-Left>",  "<C-w><", { desc = "Narrow split" })
map("n", "<C-Right>", "<C-w>>", { desc = "Widen split" })
map("n", "<C-Up>",    "<C-w>+", { desc = "Taller split" })
map("n", "<C-Down>",  "<C-w>-", { desc = "Shorter split" })

-- Buffer navigation
map("n", "<A-l>", ":bnext<CR>",     { desc = "Next buffer" })
map("n", "<A-h>", ":bprevious<CR>", { desc = "Previous buffer" })

-- Tab navigation
map("n", "<S-l>", ":tabnext<CR>",     { desc = "Next tab" })
map("n", "<S-h>", ":tabprevious<CR>", { desc = "Previous tab" })
map("n", "<leader>tn", ":tabnew<CR>",    { desc = "New tab" })
map("n", "<leader>tc", ":tabclose<CR>",  { desc = "Close tab" })
map("n", "<leader>to", ":tabonly<CR>",   { desc = "Close all other tabs" })
map("n", "<leader>te", ":tabedit %<CR>", { desc = "Open current buffer in new tab" })

-- Keep visual selection active after indenting so you can indent repeatedly
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Send deleted character to black hole register so it doesn't overwrite the yank register
map("n", "x", '"_x')

-- Delete the selection into the black hole register before pasting, so the
-- yanked text isn't replaced by the text that was just overwritten
map("v", "p", '"_dP')

 -- Insert pretty plaintext title
map("n", "<leader>ct", function()
    local line = vim.api.nvim_get_current_line()
    local trimmed = line:gsub("^%s*(.-)%s*$", "%1")
    local width = 60
    local dashes = string.rep("=", width)
    vim.api.nvim_buf_set_lines(0, vim.fn.line(".") - 1, vim.fn.line("."), false, {
        dashes,
        trimmed,
        dashes,
    })
end, { desc = "Format line as plaintext section title" })

-- =========================================================
-- FILE BROWSER (NETRW)
-- =========================================================

vim.g.netrw_banner = 0      -- hide the info banner at the top of netrw
vim.g.netrw_liststyle = 3   -- tree view (0=thin, 1=long, 2=wide, 3=tree)
vim.g.netrw_winsize = 20    -- netrw sidebar takes up 20% of screen width

-- Stores the last directory netrw was in so we can restore it on reopen
local last_netrw_dir = nil

-- vim.b.netrw_curdir is a buffer-local variable netrw sets itself to track
-- its current directory. We read it whenever we leave a netrw buffer.
autocmd("BufLeave", {
    callback = function()
        if vim.bo.filetype == "netrw" then
            local dir = vim.b.netrw_curdir
            if dir then
                last_netrw_dir = dir
            end
        end
    end,
})

-- Netrw sometimes leaves behind empty unnamed buffers as artifacts.
-- This function finds and deletes them to keep the buffer list clean.
local function clean_empty_bufs()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if
            vim.api.nvim_buf_get_name(buf) == ""  -- buffer has no file associated
            and not vim.bo[buf].modified           -- no unsaved changes
            and vim.api.nvim_buf_is_loaded(buf)   -- actually loaded in memory (not just listed)
        then
            vim.api.nvim_buf_delete(buf, {})
        end
    end
end

local function toggle_netrw()
    clean_empty_bufs()

    -- Detect if netrw is open by checking all loaded buffers for netrw's
    -- syntax marker — netrw sets the buffer variable current_syntax = "netrwlist"
    -- on all its buffers. pcall is used because nvim_buf_get_var errors if the
    -- variable doesn't exist on a given buffer.
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        local ok, syntax = pcall(vim.api.nvim_buf_get_var, buf, "current_syntax")
        if
            ok and syntax == "netrwlist"
            and not vim.bo[buf].modified
            and vim.api.nvim_buf_is_loaded(buf)
        then
            vim.api.nvim_buf_delete(buf, {})  -- deleting the buffer closes the netrw window
            return
        end
    end

    -- Netrw is not open — open it, restoring the last visited directory if available.
    -- fnameescape handles paths that contain spaces or special characters.
    if last_netrw_dir then
        vim.cmd("Lexplore " .. vim.fn.fnameescape(last_netrw_dir))
    else
        vim.cmd("Lexplore")  -- defaults to current working directory
    end
end

-- Netrw overrides <C-h> and other keys inside its buffer, breaking our split
-- navigation. We also remap o and v to open files in the correct pane rather
-- than splitting from within the netrw window itself.
autocmd("FileType", {
    pattern = "netrw",
    callback = function()
        -- Restore split navigation (netrw overrides these by default)
        map("n", "<C-h>", "<C-w>h", { buffer = true, desc = "Move to left split" })
        map("n", "<C-j>", "<C-w>j", { buffer = true, desc = "Move to lower split" })
        map("n", "<C-k>", "<C-w>k", { buffer = true, desc = "Move to upper split" })
        map("n", "<C-l>", "<C-w>l", { buffer = true, desc = "Move to right split" })

        -- o normally opens a horizontal split from the netrw window itself.
        -- Instead we jump to the editor pane first (wincmd l) then split there.
        map("n", "o", function()
            local file = vim.fn.expand("<cfile>")  -- get filename under cursor
            vim.cmd("wincmd l")
            vim.cmd("split " .. vim.fn.fnameescape(file))
        end, { buffer = true, desc = "Open file in horizontal split" })

        -- Same fix for vertical splits
        map("n", "v", function()
            local file = vim.fn.expand("<cfile>")
            vim.cmd("wincmd l")
            vim.cmd("vsplit " .. vim.fn.fnameescape(file))
        end, { buffer = true, desc = "Open file in vertical split" })

        map("n", ".", function()
            local file = vim.fn.expand("<cfile>")
            vim.api.nvim_feedkeys(":" .. file .. " ", "n", false)
        end, { buffer = true, desc = "Prepopulate command line with file under cursor" })

    end,
})

map("n", "<leader>e", toggle_netrw, { desc = "Toggle file explorer" })

-- =========================================================
-- FUZZY FINDING (BUILT-IN)
-- =========================================================

-- Search down into subfolders recursively with :find
vim.opt.path:append("**")

-- Show wildmenu completion options above the command line
vim.opt.wildmenu = true

-- Ignore these directories and files when searching
vim.opt.wildignore:append({
    "*/node_modules/*",
    "*/.git/*",
    "*/dist/*",
    "*/build/*",
    "*.o",
    "*.pyc",
    "*.class",
})

-- Open fuzzy file search — type partial name and Tab to complete
map("n", "<leader>f", ":find *",        { desc = "Fuzzy find file" })

-- Search open buffers — useful when you have many files open
map("n", "<leader>b", ":buffer *",      { desc = "Fuzzy find buffer" })

-- Live grep across project using grep (or ripgrep if set), results go to quickfix list
map("n", "<leader>g", function()
    local query = vim.fn.input("Grep: ")
    if query ~= "" then
        vim.cmd("silent grep! " .. vim.fn.shellescape(query))
        vim.cmd("copen")
    end
end, { desc = "Grep project" })

-- Grep for word under cursor across project
map("n", "<leader>*", function()
    vim.cmd("silent grep! " .. vim.fn.shellescape(vim.fn.expand("<cword>")))
    vim.cmd("copen")
end, { desc = "Grep word under cursor" })


-- =========================================================
-- QUICKFIX + LOCATION LIST
-- =========================================================

-- Toggle quickfix list
local function toggle_quickfix()
    local wins = vim.fn.getwininfo()
    for _, win in ipairs(wins) do
        if win.quickfix == 1 and win.loclist == 0 then
            vim.cmd("cclose")
            return
        end
    end
    vim.cmd("copen")
end

local function toggle_loclist()
    local wins = vim.fn.getwininfo()
    for _, win in ipairs(wins) do
        if win.quickfix == 1 and win.loclist == 1 then
            vim.cmd("lclose")
            return
        end
    end
    local ok, err = pcall(vim.cmd, "lopen")
    if not ok and err then
        vim.notify("No location list", vim.log.levels.INFO)
    end
end

map("n", "<leader>q", toggle_quickfix, { desc = "Toggle quickfix list" })
map("n", "<leader>l", toggle_loclist,  { desc = "Toggle location list" })

-- =========================================================
-- TERMINAL
-- =========================================================

-- Open terminal in a split
map("n", "<leader>th", ":split | terminal<CR>",  { desc = "Open terminal in horizontal split" })
map("n", "<leader>tv", ":vsplit | terminal<CR>", { desc = "Open terminal in vertical split" })
map("n", "<leader>tt", ":tabnew | terminal<CR>", { desc = "Open terminal in new tab" })

-- Exit terminal mode
map("t", "jk", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Split navigation from terminal mode without needing to exit first
map("t", "<C-h>", "<C-\\><C-n><C-w>h", { desc = "Move to left split from terminal" })
map("t", "<C-j>", "<C-\\><C-n><C-w>j", { desc = "Move to lower split from terminal" })
map("t", "<C-k>", "<C-\\><C-n><C-w>k", { desc = "Move to upper split from terminal" })
map("t", "<C-l>", "<C-\\><C-n><C-w>l", { desc = "Move to right split from terminal" })

-- Tab navigation from terminal mode
map("t", "<S-l>", "<C-\\><C-n>:tabnext<CR>",     { desc = "Next tab from terminal" })
map("t", "<S-h>", "<C-\\><C-n>:tabprevious<CR>", { desc = "Previous tab from terminal" })

-- Enter insert mode automatically when switching to a terminal window
autocmd("BufEnter", {
    pattern = "term://*",
    callback = function()
        vim.cmd("startinsert")
    end,
})

-- Keep terminal buffers out of main buffer list
autocmd("TermOpen", {
    callback = function()
        vim.opt_local.buflisted = false
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.cmd("startinsert")
    end,
})

-- Use H / M / L while ignoring scrolloff - best of both worlds!

-- local function with_no_scrolloff(cmd)
--   return function()
--     local so = vim.o.scrolloff
--     vim.o.scrolloff = 0
--     vim.cmd("normal! " .. cmd)
--     vim.o.scrolloff = so
--   end
-- end
--
-- vim.keymap.set("n", "H", with_no_scrolloff("H"))
-- vim.keymap.set("n", "L", with_no_scrolloff("L"))
-- vim.keymap.set("n", "M", with_no_scrolloff("M"))

