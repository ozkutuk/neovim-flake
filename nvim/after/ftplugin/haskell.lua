vim.bo.shiftwidth = 2

-- disable indentation from haskell-vim
vim.g.haskell_indent_disable = 1

-- ...use treesitter indentation instead
vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
