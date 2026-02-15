{ pkgs, lib, config, ... }:

{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
  };
}
