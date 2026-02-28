{ pkgs, config, ... }:


{
  imports = [
    ./rofi.nix
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "image/png" = [ "imv.desktop" ];
      "image/jpeg" = [ "imv.desktop" ];
      "application/pdf" = [ "org.pwmt.zathura.desktop" ]; # Or "evince.desktop"
      "text/html" = "google-chrome.desktop";
      "x-scheme-handler/http" = "google-chrome.desktop";
      "x-scheme-handler/https" = "google-chrome.desktop";
    };
  };

  programs.chromium = {
    enable = true;
    package = pkgs.google-chrome.override {
      commandLineArgs = [
        "--ozone-platform-hint=auto"
        "--force-device-scale-factor=0.8"
      ];
    };
  };

  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "Regular";
        };
      };
      font.size = 11;
      selection.save_to_clipboard = true;
      window.opacity = 0.95;
    };
  };

  programs.zathura = {
    enable = true;
    options = {
      selection-clipboard = "clipboard";
      recolor = true;
      recolor-keephue = true;
      recolor-lightcolor = "#1a1a1a";
      recolor-darkcolor = "#e0e0e0";
      page-store-threshold = 0;
    };
  };

  home.packages = with pkgs; [
    alacritty
    waybar
    pamixer
    brightnessctl
    grim
    slurp
    wl-clipboard
    clipman
    networkmanagerapplet
    wtype
    clipman
    guvcview
    mpv
    imv
    zathura
    libreoffice-fresh
    papirus-icon-theme
    gnome-themes-extra
    zapzap
    blueman
    helix
  ];
}
