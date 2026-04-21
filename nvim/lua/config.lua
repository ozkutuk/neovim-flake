local tab_width = 4
vim.o.tabstop = tab_width
vim.o.softtabstop = tab_width
vim.o.shiftwidth = tab_width
vim.o.expandtab = true
vim.o.smartindent = true

vim.o.termguicolors = true
vim.o.colorcolumn = "110"

vim.g.mapleader = ","
vim.g.maplocalleader = ",,"

-- Set 7 lines to the cursor - when moving vertically using j/k
vim.o.scrolloff = 7
vim.o.relativenumber = true

-- show matching parens
vim.o.showmatch = true
vim.o.mat = 2

-- lualine shows mode anyway
vim.o.showmode = false
vim.o.cursorline = true

-- report changes regardless of changed line count
vim.o.report = 0

-- column limit on the searched syntax items (possibly remove this?)
-- vim.o.synmaxcol = 200

vim.o.foldenable = false

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching unless \C or one or more capital letters
-- in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.o.signcolumn = "yes"

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays mini.clue popup sooner (I hope)
vim.o.timeoutlen = 300

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Sets how Neovim will display certain whitespace characters
vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
vim.o.inccommand = "split"

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true
