{ pkgs, mnw }:

let
  args = { inherit pkgs; };
in
mnw.lib.wrap pkgs {
  appName = "nvim-ozkutuk";
  neovim = pkgs.neovim-unwrapped;  # must be unwrapped per mnw docs

  luaFiles = [
    ./init.lua
    ];

  plugins = {
    dev.config = {
      pure = ./nvim;
      impure = "/home/ozkutuk/dev/neovim-flake/nvim";
    };

    start = with pkgs.vimPlugins; [
      # Themes / UI
      nightfox-nvim
      lualine-nvim
      lsp_lines-nvim
      fidget-nvim

      # Language-agnostic
      vim-fugitive
      gitsigns-nvim
      nvim-surround
      snacks-nvim
      mini-nvim
      leap-nvim
      (nvim-treesitter.withPlugins (p: [
        p.tree-sitter-haskell
        p.tree-sitter-nix
        p.tree-sitter-python
        p.tree-sitter-kotlin
        p.tree-sitter-c
        p.tree-sitter-fennel
        p.tree-sitter-lua
        p.tree-sitter-todotxt
      ]))
      harpoon2
      smart-splits-nvim
      neotest
      blink-cmp
      blink-cmp-git
      blink-cmp-tmux
      luasnip

      # Language-specific
      haskell-vim
      neotest-haskell
      haskell-snippets-nvim

      vim-nix
      dhall-vim
      purescript-vim
      vim-jsonnet
      zig-vim
      kotlin-vim
      vim-just
      vim-syntax-shakespeare
      lean-nvim
      typst-preview-nvim
    ];
  };
}
