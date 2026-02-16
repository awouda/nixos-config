{ pkgs, lib, config, ... }:

let
  myScript = name: pkgs.writeShellScriptBin name (builtins.readFile ./scripts/${name}.sh);
in
{
  imports =
    [
      ./modules/core/shell.nix
      ./neovim.nix
      ./sway-home.nix
      ./sway-bar.nix
      ./rofi.nix
    ];

  home.username = "alex";
  home.homeDirectory = "/home/alex";
  home.stateVersion = "25.11";
  home.sessionVariables = {
    XDG_DATA_DIRS = "$GSETTINGS_SCHEMAS_PATH:$XDG_DATA_DIRS:/home/alex/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share";
  };

  # fonts configuration
  fonts.fontconfig.enable = true;

  fonts.fontconfig.defaultFonts = {
    serif = [ "JetBrainsMono Nerd Font" ];
    sansSerif = [ "JetBrainsMono Nerd Font" ];
    monospace = [ "JetBrainsMono Nerd Font" ];
  };

  # Set the GTK theme and font
  gtk = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font"; # 
      size = 10;
    };
    theme = {
      name = "Adwaita-dark"; # 
      package = pkgs.gnome-themes-extra;
    };
  };


  # for speed up GTK apps
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
    config.common.default = "*";
  };

  # program specific configuration
  programs.chromium = {
    enable = true;
    package = pkgs.google-chrome.override {
      commandLineArgs = [
        "--ozone-platform-hint=auto"
        "--force-device-scale-factor=0.8" # Since you like the 2x scale
      ];
    };
  };

  programs.alacritty = {
    enable = true;
    settings = {
      font =
        {
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

  # Java. Current main version 21
  programs.java = {
    enable = true;
    package = pkgs.temurin-bin-21;
  };


  # Zathura Configuration
  programs.zathura = {
    enable = true;
    options = {
      selection-clipboard = "clipboard";
      recolor = true; # Dark mode
      recolor-keephue = true;

      # Monochrome colors to match your rice
      recolor-lightcolor = "#1a1a1a";
      recolor-darkcolor = "#e0e0e0";

      # Try setting this to true if the jumps are weird
      page-store-threshold = 0;
    };
  };



  home.packages = with pkgs; [
    (myScript "fshow")

    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only # Good to have for extra icons 
    alacritty
    rofi
    waybar
    pamixer
    brightnessctl
    grim
    slurp
    wl-clipboard
    clipman
    networkmanagerapplet
    wl-clipboard
    git
    htop
    btop
    yazi
    fzf
    azure-cli
    yq
    jq
    httpie
    wget
    curl
    tv
    kubectl
    kubectx
    kubelogin
    wtype
    cliphist
    guvcview
    bat
    silver-searcher
    zoxide
    # --- Video, Image & PDF ---
    mpv
    imv
    zathura
    # --- Productivity & Notes ---
    libreoffice-fresh
    awscli2
    # --- Appearance (The Rice) ---
    papirus-icon-theme
    gnome-themes-extra
    # WhatsApp
    zapzap
  ];
}


