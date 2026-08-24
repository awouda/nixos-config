{ config, pkgs, ... }:
{
  imports =
    [
      ./modules/desktop/sway-system.nix
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # This enables the docker daemon and the docker-compose CLI plugin
  virtualisation.docker = {
    enable = true;
    package = pkgs.docker_29; # Force NixOS to use Docker 29
  };


  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking: gives us nmcli and nm-applet
  networking.networkmanager.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Allow unfree (for Broadcom a.o.)
  nixpkgs.config.allowUnfree = true;

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "nl_NL.UTF-8";
    LC_IDENTIFICATION = "nl_NL.UTF-8";
    LC_MEASUREMENT = "nl_NL.UTF-8";
    LC_MONETARY = "nl_NL.UTF-8";
    LC_NAME = "nl_NL.UTF-8";
    LC_NUMERIC = "nl_NL.UTF-8";
    LC_PAPER = "nl_NL.UTF-8";
    LC_TELEPHONE = "nl_NL.UTF-8";
    LC_TIME = "nl_NL.UTF-8";
  };

  services.flatpak.enable = true;

  systemd.settings.Manager = {
    DefaultTimeoutStopSec = "10s";
  };

  environment.variables = {
    _JAVA_AWT_WM_NONREPARENTING = "1";
    NIXOS_OZONE_GTK_V3 = "1";
    GDK_DPI_SCALE = "1";
  };

  # additional configs for speeding up gtk apps 
  services.dbus.enable = true;
  services.gvfs.enable = true; # Mount, trash, and remote fs support
  services.tumbler.enable = true; # Thumbnail support for Thunar
  services.gnome.gnome-keyring.enable = true; # Stops apps from hanging on "Secret" lookups
  # auto login gnome keyring
  security.pam.services.login.enableGnomeKeyring = true;

  # might be needed for old gtk apps
  services.xserver.enable = true;

  services.displayManager.gdm.enable = true;
  services.displayManager.gdm.wayland = true;


  # Add this back to configuration.nix, as default, has overrides in hosts/xxx/default.nix files
  users.users.alex = {
    isNormalUser = true;
    description = "alex";
    extraGroups = [ "networkmanager" "wheel" "docker" ]; # Core groups only
  };

  # Keep this! Sway uses these settings for your keyboard
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  fonts.fontconfig = {
    enable = true;
    antialias = true;
    hinting = {
      enable = true;
      style = "slight";
    };
    subpixel = {
      rgba = "rgb";
      lcdfilter = "default";
    };
    defaultFonts = {
      serif = [ "DejaVu Serif" ];
      sansSerif = [ "Inter" "DejaVu Sans" ];
      monospace = [ "JetBrainsMono Nerd Font" ];
    };
  };



  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  services.printing = {
    enable = true;
    drivers = [ pkgs.hplipWithPlugin ]; # Use hplipWithPlugin for full photo/scan support
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true; # Allows resolving .local addresses
    openFirewall = true; # Opens the ports for mDNS discovery
    publish = {
      enable = true;
      addresses = true;
      workstation = true; # Makes it show up in Finder/Network
    };
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Nix Store Management
  nix = {
    settings.auto-optimise-store = true; # Deduplicates files on every build
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
    pciutils
    usbutils
    dnsutils
    openssl
    bluez
    nwg-bar
    swaybg
    swayfx
    docker-compose

    jetbrains.idea
    spotify
    teams-for-linux
    slack

    # The File Manager
    xfce.thunar
    xfce.thunar-volman
    gvfs # Required for icons/trash in Thunar

    pkgs.shotwell
    parted
    gparted

    hdparm
    radeontop
    cpufetch
    dmidecode
    wf-recorder
    slurp

    vlc
    mpv
    totem

    # for thumbnails on mts vids
    shared-mime-info
    pkgs.xfce.tumbler
    ffmpegthumbnailer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
