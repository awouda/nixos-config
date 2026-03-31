{ pkgs, lib, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
    withPython3 = true;

    extraConfig = ''
      set clipboard+=unnamedplus
      set number
      set relativenumber

      " Remap S to yank to system clipboard
      nnoremap S "+y
      vnoremap S "+y

      autocmd BufWritePost *.nix silent! !nixpkgs-fmt %

      let mapleader = ","

      command! FormatJSON %!${pkgs.jq}/bin/jq .
      nnoremap <leader>j :FormatJSON<CR>
    '';

    extraLuaConfig = ''
      -- 1. Setup Treesitter
      require('nvim-treesitter.configs').setup {
        highlight = { enable = true },
        indent = { enable = true },
      }

      -- 2. Apply a modern colorscheme
      vim.cmd.colorscheme "tokyonight-night"

      -- 3. Custom Highlight Overrides for Java/Rust/etc.
      -- This gives you the specific granular control you asked for:
      local hl = vim.api.nvim_set_hl
      hl(0, "@attribute", { fg = "#e0af68", bold = true })       -- Annotations (@Component)
      hl(0, "@keyword.modifier", { fg = "#bb9af7", italic = true }) -- public, static, final
      hl(0, "@type.qualifier", { fg = "#7dcfff" })               -- final (in some languages)
      hl(0, "@constant", { fg = "#ff9e64", bold = true })        -- JOB_KEY, etc.
    '';

    plugins = with pkgs.vimPlugins; [
      # Added TokyoNight for better Treesitter support
      tokyonight-nvim

      (nvim-treesitter.withPlugins (p: with p; [
        java
        rust
        scala
        go
        javascript
        typescript
        nix
        lua
        bash
      ]))
    ];
  };
}
