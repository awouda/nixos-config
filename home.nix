{ pkgs, lib, config, ... }:

let
  myScript = name: pkgs.writeShellScriptBin name (builtins.readFile ./scripts/${name}.sh);
in
{
  imports =
    [
      ./modules/core/shell.nix
      ./modules/desktop/default.nix
      ./sway-home.nix
      ./sway-bar.nix
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

  # Java. Current main version 21
  programs.java = {
    enable = true;
    package = pkgs.temurin-bin-21;
  };

  # ONLY CLI, DevOps Tools, and Fonts remain here!
  home.packages = with pkgs; [
    (myScript "fshow")
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    # --- DevOps & CLI ---
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
    bat
    silver-searcher
    zoxide
    awscli2
  ];
}


