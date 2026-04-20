local tab_width = 4
vim.opt.tabstop = tab_width
vim.opt.softtabstop = tab_width
vim.opt.shiftwidth = tab_width
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.termguicolors = true
vim.opt.colorcolumn = "110"

vim.g.mapleader = ","
vim.g.maplocalleader = ",,"

-- Set 7 lines to the cursor - when moving vertically using j/k
vim.opt.scrolloff = 7
vim.opt.relativenumber = true

-- show matching parens
vim.opt.showmatch = true
vim.opt.mat = 2

-- lualine shows mode anyway
vim.opt.showmode = false
vim.opt.cursorline = true

-- report changes regardless of changed line count
vim.opt.report = 0

-- column limit on the searched syntax items (possibly remove this?)
-- vim.opt.synmaxcol = 200

vim.opt.foldenable = false

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching unless \C or one or more capital letters
-- in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays mini.clue popup sooner (I hope)
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how Neovim will display certain whitespace characters
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
vim.o.inccommand = "split"

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true
