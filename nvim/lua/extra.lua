local light_theme = "dayfox"
local dark_theme = "nightfox"

-- Light theme by default
local theme = "light"
vim.cmd("colorscheme " .. light_theme)

local toggle_theme = function()
  if theme == "light" then
    theme = "dark"
    vim.cmd("colorscheme " .. dark_theme)
  else
    theme = "light"
    vim.cmd("colorscheme " .. light_theme)
  end
end

vim.keymap.set("n", "<F2>", toggle_theme)

vim.api.nvim_create_autocmd("CompleteDone", {
  pattern = "*",
  callback = function()
    vim.cmd("pclose")
  end,
})

vim.filetype.add {
  filename = {
    ["todo.txt"] = "todotxt",
  },
}

require("lualine").setup {}

vim.keymap.set({ "n", "x", "o" }, "s", function()
  require("leap").leap {
    windows = { vim.api.nvim_get_current_win() },
    inclusive = true,
  }
end)
vim.keymap.set("n", "S", function()
  require("leap").leap {
    windows = require("leap.util").get_enterable_windows(),
  }
end)

require("tiny-inline-diagnostic").setup {}

require("fidget").setup {}

require("nvim-surround").setup {}

require("gitsigns").setup {
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map("n", "]c", function()
      if vim.wo.diff then
        return "]c"
      end
      vim.schedule(function()
        gs.next_hunk()
      end)
      return "<Ignore>"
    end, { expr = true })

    map("n", "[c", function()
      if vim.wo.diff then
        return "[c"
      end
      vim.schedule(function()
        gs.prev_hunk()
      end)
      return "<Ignore>"
    end, { expr = true })

    -- Actions
    map("n", "<leader>hs", gs.stage_hunk)
    map("n", "<leader>hr", gs.reset_hunk)
    map("v", "<leader>hs", function()
      gs.stage_hunk { vim.fn.line("."), vim.fn.line("v") }
    end)
    map("v", "<leader>hr", function()
      gs.reset_hunk { vim.fn.line("."), vim.fn.line("v") }
    end)
    map("n", "<leader>hS", gs.stage_buffer)
    map("n", "<leader>hu", gs.undo_stage_hunk)
    map("n", "<leader>hR", gs.reset_buffer)
    map("n", "<leader>hp", gs.preview_hunk)
    map("n", "<leader>hb", function()
      gs.blame_line { full = true }
    end)
    map("n", "<leader>tb", gs.toggle_current_line_blame)
    map("n", "<leader>hd", gs.diffthis)
    map("n", "<leader>hD", function()
      gs.diffthis("~")
    end)
    map("n", "<leader>td", gs.toggle_deleted)

    -- Text object
    map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
  end,
}

local ls = require("luasnip")
ls.setup {
  update_events = { "TextChanged", "TextChangedI" },
}

local haskell_snippets = require("haskell-snippets").all
ls.add_snippets("haskell", haskell_snippets, { key = "haskell" })

vim.keymap.set({ "i", "s" }, "<C-k>", function()
  if ls.expand_or_jumpable() then
    ls.expand_or_jump()
  end
end, { silent = true })

vim.keymap.set({ "i", "s" }, "<C-j>", function()
  if ls.jumpable(-1) then
    ls.jump(-1)
  end
end, { silent = true })

vim.keymap.set("i", "<C-l>", function()
  if ls.choice_active() then
    ls.change_choice(1)
  end
end)

require("blink.cmp").setup {
  signature = { enabled = true },
  snippets = { preset = "luasnip" },
  keymap = {
    -- Collides with snippet expansion keymap
    -- Signature is shown automatically anyway
    ["<C-k>"] = false,
  },
  completion = {
    menu = {
      draw = {
        columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },
        components = {
          kind_icon = {
            text = function(ctx)
              local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
              -- I was expecting icon_gap to provide the ...well, gap, but apparently not?
              -- Therefore the additional whitespace
              return kind_icon .. ctx.icon_gap .. " "
            end,
            -- (optional) use highlights from mini.icons
            highlight = function(ctx)
              local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
              return hl
            end,
          },
          kind = {
            -- (optional) use highlights from mini.icons
            highlight = function(ctx)
              local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
              return hl
            end,
          },
        },
      },
    },
  },
  sources = {
    default = { "lsp", "path", "snippets", "buffer", "tmux" },

    per_filetype = {
      jjdescription = { inherit_defaults = true, "git" },
      gitcommit = { inherit_defaults = true, "git" },
      markdown = { inherit_defaults = true, "git" },
    },

    providers = {
      git = {
        module = "blink-cmp-git",
        name = "Git",
      },
      tmux = {
        module = "blink-cmp-tmux",
        name = "Tmux",
        transform_items = function(ctx, items)
          for _, item in ipairs(items) do
            -- FIXME(ozkutuk): this icon can't be rendered and I don't know why
            -- local kind_icon, _, _ = require('mini.icons').get('filetype', 'tmux')
            -- item.kind_icon = kind_icon
            item.kind_name = "Tmux"
          end
          return items
        end,
      },
    },
  },
}

require("nvim-treesitter").setup()

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "haskell", "nix", "python", "kotlin", "c", "fennel", "lua", "todotxt" },
  callback = function()
    vim.treesitter.start()

    vim.opt.foldmethod = "expr"
    vim.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})

-- LSP stuff, copied and adapted from `nvim-lspconfig` README
-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, opts)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist, opts)
vim.diagnostic.config {
  float = { border = "single" },
  -- Disable virtual_text since it's redundant due to lsp_lines.
  virtual_text = false,
}
vim.api.nvim_set_hl(0, "NormalFloat", { background = "None", foreground = "None" })

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
  vim.api.nvim_buf_set_option(bufnr, "tagfunc", "v:lua.vim.lsp.tagfunc")

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
  vim.keymap.set("n", "K", function()
    vim.lsp.buf.hover { border = "single" }
  end, bufopts)
  -- Following are not supported by HLS
  -- vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  -- vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, bufopts)
  vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, bufopts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
  vim.keymap.set("n", "<space>f", function()
    vim.lsp.buf.format { async = true }
  end, bufopts)

  vim.api.nvim_command(
    [[autocmd CursorHold,CursorHoldI,InsertLeave <buffer> lua vim.lsp.codelens.enable(true)]]
  )
  vim.api.nvim_buf_set_keymap(
    bufnr,
    "n",
    "<space>cl",
    "<Cmd>lua vim.lsp.codelens.run()<CR>",
    { silent = true }
  )

  -- hack: HLS has Cabal file support but doesn't provide inlay hints for it,
  -- so we explicitly disallow inlay hints for Cabal files
  if client.server_capabilities.inlayHintProvider and vim.bo[bufnr].filetype ~= "cabal" then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end
end

local function make_hls_command(use_local, dbg)
  local cmd = {}

  if use_local then
    local ghc_version = "9.10.3"
    local hls_version = "2.13.0.0"
    local hls_path = "/home/ozkutuk/dev/haskell-language-server/dist-newstyle/build/x86_64-linux/ghc-"
      .. ghc_version
      .. "/haskell-language-server-"
      .. hls_version
      .. "/x/haskell-language-server/build/haskell-language-server/haskell-language-server"
    table.insert(cmd, hls_path)
  else
    table.insert(cmd, "haskell-language-server-wrapper")
  end

  table.insert(cmd, "--lsp")
  if dbg then
    table.insert(cmd, "--debug")
  end

  return cmd
end

vim.lsp.config("hls", {
  on_attach = on_attach,
  filetypes = { "haskell", "lhaskell", "cabal" },
  cmd = make_hls_command(true, true),
  settings = {
    ["haskell"] = {
      formattingProvider = "fourmolu",
      cabalFormattingProvider = "cabal-gild",
      plugin = {
        ["hlint"] = {
          diagnosticsOn = false,
        },
      },
    },
  },
})
vim.lsp.enable("hls")

vim.lsp.config("zls", {
  on_attach = on_attach,
})
vim.lsp.enable("zls")

vim.lsp.config("ccls", {
  on_attach = on_attach,
})
vim.lsp.enable("ccls")

vim.lsp.config("elmls", {
  on_attach = on_attach,
})
vim.lsp.enable("elmls")

vim.lsp.config("nil_ls", {
  on_attach = on_attach,
  settings = {
    ["nil"] = {
      formatting = {
        command = { "alejandra", "-q" },
      },
    },
  },
})
vim.lsp.enable("nil_ls")

vim.lsp.config("dhall_lsp_server", {
  on_attach = on_attach,
})
vim.lsp.enable("dhall_lsp_server")

vim.lsp.config("tinymist", {
  on_attach = on_attach,
})
vim.lsp.enable("tinymist")

require("typst-preview").setup {}

require("lean").setup { mappings = true }

require("mini.comment").setup {}
require("mini.icons").setup {
  filetype = {
    tmux = { glyph = "" },
  },
}
require("mini.bracketed").setup {}
require("mini.ai").setup {}

local miniclue = require("mini.clue")
miniclue.setup {
  triggers = {
    -- Leader triggers
    { mode = "n", keys = "<Leader>" },
    { mode = "x", keys = "<Leader>" },

    -- Some custom LSP keymaps I have
    { mode = "n", keys = "<Space>" },
    { mode = "x", keys = "<Space>" },

    -- Built-in completion
    { mode = "i", keys = "<C-x>" },

    -- `g` key
    { mode = "n", keys = "g" },
    { mode = "x", keys = "g" },

    -- Marks
    { mode = "n", keys = "'" },
    { mode = "n", keys = "`" },
    { mode = "x", keys = "'" },
    { mode = "x", keys = "`" },

    -- Registers
    { mode = "n", keys = '"' },
    { mode = "x", keys = '"' },
    { mode = "i", keys = "<C-r>" },
    { mode = "c", keys = "<C-r>" },

    -- Window commands
    { mode = "n", keys = "<C-w>" },

    -- `z` key
    { mode = "n", keys = "z" },
    { mode = "x", keys = "z" },
  },

  clues = {
    -- Enhance this by adding descriptions for <Leader> mapping groups
    miniclue.gen_clues.builtin_completion(),
    miniclue.gen_clues.g(),
    miniclue.gen_clues.marks(),
    miniclue.gen_clues.registers(),
    miniclue.gen_clues.windows(),
    miniclue.gen_clues.z(),
  },
}

local snacks = require("snacks")
snacks.setup {
  bigfile = { enabled = true },
  bufdelete = { enabled = true },
  gh = { enabled = true },
  indent = { enabled = true },
  input = { enabled = true },
  explorer = { enabled = true },
  notifier = {
    enabled = true,
    timeout = 3000,
  },
  picker = {
    enabled = true,
  },
  quickfile = { enabled = true },
  zen = { enabled = true },
}

vim.keymap.set("n", "<leader>e", function()
  snacks.picker.smart()
end, { desc = "Find files (smart)" })
vim.keymap.set("n", "<leader>b", function()
  snacks.picker.buffers()
end, { desc = "Buffers" })
vim.keymap.set("n", "<leader>r", function()
  snacks.picker.grep()
end, { desc = "Grep" })
vim.keymap.set("n", "<leader>fh", function()
  snacks.picker.help()
end, { desc = "Help pages" })
vim.keymap.set("n", "<Leader>lt", function()
  snacks.picker.lsp_workspace_symbols()
end, { desc = "LSP workspace symbols" })
vim.keymap.set("n", "<Leader>d", function()
  snacks.picker.diagnostics_buffer()
end, { desc = "Diagnostics (buffer)" })
vim.keymap.set("n", "<Leader>D", function()
  snacks.picker.diagnostics()
end, { desc = "Diagnostics" })
vim.keymap.set("n", "<Leader>fb", function()
  snacks.explorer()
end, { desc = "File browser" })

vim.keymap.set("n", "<leader>z", function()
  snacks.zen()
end, { desc = "Toggle Zen Mode" })
vim.keymap.set("n", "<leader>Z", function()
  snacks.zen.zoom()
end, { desc = "Toggle Zoom" })
vim.keymap.set("n", "<leader>Bd", function()
  snacks.bufdelete()
end, { desc = "Delete Buffer" })

vim.keymap.set("n", "<leader>gl", function()
  Snacks.picker.git_log()
end, { desc = "Git Log" })
vim.keymap.set("n", "<leader>gi", function()
  Snacks.picker.gh_issue()
end, { desc = "GitHub Issues (open)" })
vim.keymap.set("n", "<leader>gI", function()
  Snacks.picker.gh_issue { state = "all" }
end, { desc = "GitHub Issues (all)" })
vim.keymap.set("n", "<leader>gp", function()
  Snacks.picker.gh_pr()
end, { desc = "GitHub Pull Requests (open)" })
vim.keymap.set("n", "<leader>gP", function()
  Snacks.picker.gh_pr { state = "all" }
end, { desc = "GitHub Pull Requests (all)" })

-- require('neotest').setup({
--   adapters = {
--     require('neotest-haskell'),
--   },
-- })
--
-- vim.keymap.set('n', '<leader>t', function() require('neotest').run.run() end, { desc = "Run the nearest test" })
-- vim.keymap.set('n', '<leader>T', function() require('neotest').run.run(vim.fn.expand('%')) end, { desc = "Run all tests in file" })
--
-- smart-splits.nvim mappings
--
-- recommended mappings
-- resizing splits
-- these keymaps will also accept a range,
-- for example `10<A-h>` will `resize_left` by `(10 * config.default_amount)`
vim.keymap.set("n", "<A-h>", require("smart-splits").resize_left)
vim.keymap.set("n", "<A-j>", require("smart-splits").resize_down)
vim.keymap.set("n", "<A-k>", require("smart-splits").resize_up)
vim.keymap.set("n", "<A-l>", require("smart-splits").resize_right)
-- moving between splits
vim.keymap.set("n", "<C-h>", require("smart-splits").move_cursor_left)
vim.keymap.set("n", "<C-j>", require("smart-splits").move_cursor_down)
vim.keymap.set("n", "<C-k>", require("smart-splits").move_cursor_up)
vim.keymap.set("n", "<C-l>", require("smart-splits").move_cursor_right)
vim.keymap.set("n", "<C-\\>", require("smart-splits").move_cursor_previous)
-- swapping buffers between windows
vim.keymap.set(
  "n",
  "<leader><A-h>",
  require("smart-splits").swap_buf_left,
  { desc = "Swap buffer: left" }
)
vim.keymap.set(
  "n",
  "<leader><A-j>",
  require("smart-splits").swap_buf_down,
  { desc = "Swap buffer: down" }
)
vim.keymap.set(
  "n",
  "<leader><A-k>",
  require("smart-splits").swap_buf_up,
  { desc = "Swap buffer: up" }
)
vim.keymap.set(
  "n",
  "<leader><A-l>",
  require("smart-splits").swap_buf_right,
  { desc = "Swap buffer: right" }
)
