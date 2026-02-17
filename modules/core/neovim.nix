{ pkgs, lib, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
    withPython3 = true;
    # this is the extra old 'vimrc' config 
    extraConfig = ''
      set clipboard+=unnamedplus
      set number
      set relativenumber

      " Remap S to yank to system clipboard [cite: 2026-02-12]
      nnoremap S "+y
      vnoremap S "+y

      autocmd BufWritePost *.nix silent! !${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt %
      " Set leader to comma
      let mapleader = ","

      " JSON Formatting Shortcut
      " Requires 'jq' package in home.packages
      command! FormatJSON %!${pkgs.jq}/bin/jq .
      nnoremap <leader>j :FormatJSON<CR>

    '';
  };
}


