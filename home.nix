{ pkgs, lib, config, ... }:

let
  myScript = name: pkgs.writeShellScriptBin name (builtins.readFile ./modules/core/scripts/${name}.sh);
in
{
  imports =
    [
      ./modules/core/shell.nix
      ./modules/desktop/default.nix

      # ---- THEME TOGGLE ----
      #./modules/rices/monochrome/sway.nix
      #./modules/rices/monochrome/waybar.nix
      ./modules/rices/sway-minimal/sway.nix
      ./modules/rices/sway-minimal/waybar.nix
    ];

  home.username = "alex";
  home.homeDirectory = "/home/alex";
  home.stateVersion = "25.11";
  home.sessionVariables = {
    XDG_DATA_DIRS = "$GSETTINGS_SCHEMAS_PATH:$XDG_DATA_DIRS:/home/alex/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    WLR_DRM_DEVICES = "/dev/dri/card1:/dev/dri/card0"; #remove when new GPU arrives
  };

  # fonts configuration
  fonts.fontconfig.enable = true;

  fonts.fontconfig.defaultFonts = {
    # This lets GNOME use standard readable fonts (Inter/Cantarell).
    serif = [ "DejaVu Serif" ];
    sansSerif = [ "DejaVu Sans" ];
    monospace = [ "JetBrainsMono Nerd Font" ]; # Keep this for your terminal/coding
  };

  # Set the GTK theme and font
  gtk = {
    enable = true;
    font = {
      name = "Cantarell"; # std Sans font for GTK apps globally
      size = 10;
    };
    theme = {
      name = "Adwaita-dark"; # 
      package = pkgs.gnome-themes-extra;
    };
  };

  dconf.settings = {
    "org/gnome/desktop/input-sources" = {
      xkb-options = [ "altwin:swap_lalt_lwin" ];
    };
  };

  # Java. Current main version 21
  programs.java = {
    enable = true;
    package = pkgs.temurin-bin-21;
  };

  programs.git = {
    enable = true;
    userName = "Alex Wouda";
    userEmail = "alex.boxcar902@passinbox.com";
  };

  services.cliphist = {
    enable = true;
    allowImages = true;
  };

  # ONLY CLI, DevOps Tools, and Fonts remain here!
  home.packages = with pkgs; [
    (myScript "fshow")
    (myScript "wifi")
    (myScript "sway-windows")
    (myScript "finder")
    (myScript "clip-paster")
    (myScript "togglemouse")
    (myScript "pull-project")
    (myScript "push-project")
    (myScript "sync-gradle-cache")
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    # --- DevOps & CLI ---
    home-manager
    git
    htop
    yazi
    azure-cli
    yq
    jq
    fd
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
    k9s
    lazydocker
    blesh
    nixpkgs-fmt
    clipse

    zip
    xz
    unzip
    p7zip

    eza
    fastfetch
    # networking tools
    mtr # A network diagnostic tool
    iperf3
    dnsutils # `dig` + `nslookup`
    ldns # replacement of `dig`, it provide the command `drill`
    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    ipcalc # it is a calculator for the IPv4/v6 addresses

    # misc
    cowsay
    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd
    gnupg

    # nix related
    #
    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor

    # productivity
    hugo # static site generator
    glow # markdown previewer in terminal

    btop # replacement of htop/nmon
    iotop # io monitoring
    iftop # network monitoring

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    # system tools
    sysstat
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb
  ];
}
