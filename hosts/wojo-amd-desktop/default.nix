{ config, pkgs, lib, bleedingedge, ... }:

{
  assertions = [
    {
      assertion = config.networking.hostName == "wojo-amd-desktop";
      message = "ERROR: You are trying to build the AMD Desktop config on a different host!";
    }
  ];


  imports = [
    ../../configuration.nix # Global settings (Locales, Timezone, Pipewire)
    ./hardware-configuration.nix # Generated hardware file
    #./ai.nix # The ROCm 7.x / Ollama stack we built #we disabled as we removed the noise R9700 GPU
  ];

  # NETWORKING & KERNEL (Ryzen 9000 & Wi-Fi 7 Readiness)
  networking.hostName = "wojo-amd-desktop";
  boot.kernelPackages = pkgs.linuxPackages_latest; # Crucial for 2026 hardware
  hardware.enableAllFirmware = true;
  hardware.wirelessRegulatoryDatabase = true;

  # Ensure the GPU wakes up early during boot
  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];

  boot.kernelParams = [
    "amdgpu.ppfeaturemask=0xfffd7fff"
    "amd_pstate=active"
    "lockdown=none"
    "iommu=pt"
    "pcie_aspm=off"
    "transparent_hugepage=always"
  ];

  # MSI fans (Nuvoton)
  boot.kernelModules = [
    "nct6687"
    "i2c-dev"
    "ath12k_pci"
  ];

  boot.extraModulePackages = [ config.boot.kernelPackages.nct6687d ];

  boot.extraModprobeConfig = ''
    options nct6687 fan_config=msi_alt1
  '';

  # --- Tmpfs (RAM-disk) ---
  boot.tmp = {
    useTmpfs = true;
    tmpfsSize = "32G";
  };

  # --- Nix Build Optimalisatie ---
  nix.settings = {
    # use all 32 threads from 9950X
    max-jobs = "auto";
    cores = 32;
    auto-optimise-store = true;
  };

  programs.coolercontrol.enable = true;

  # LACT: for amd gpu overrides
  systemd.services.lactd = {
    description = "AMDGPU Control Daemon";
    enable = true;
    serviceConfig = {
      ExecStart = "${pkgs.lact}/bin/lact daemon";
      Restart = "always";
    };
    wantedBy = [ "multi-user.target" ];
  };

  # DESKTOP ENVIRONMENTS (GNOME for Family, Sway for Alex)
  services.xserver.enable = true;
  services.desktopManager.gnome.enable = true;
  programs.sway = {
    enable = true;
    extraSessionCommands = ''
      eval $(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
      export GNOME_KEYRING_CONTROL
      export SSH_AUTH_SOCK
    '';
  };

  # Enable the gnome-keyring service
  services.gnome.gnome-keyring.enable = true;

  # Unlock keyring on login
  security.pam.services.login.enableGnomeKeyring = true;

  # If you use greetd (highly likely on a NixOS/Sway setup), add this too:
  security.pam.services.greetd.enableGnomeKeyring = true;

  # XDG Portals: Moved to system level for proper Sway/Gnome compatibility
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  # USER ACCOUNTS & GROUPS
  users.groups.photos = { };
  users.users =
    let
      kidConfig = {
        isNormalUser = true;
        extraGroups = [ "networkmanager" "photos" "video" ];
      };
    in
    {
      alex = {
        isNormalUser = true;
        description = "alex";
        extraGroups = [ "wheel" "networkmanager" "docker" "video" "render" "photos" "uinput" ];
      };
      nout = kidConfig;
      emmeline = kidConfig;
      julia = kidConfig;
    };


  # STORAGE & MAINTENANCE
  # Shared photos directory with group write permissions
  systemd.tmpfiles.rules = [
    "d /srv/photos 2775 root photos - -"
  ];

  services.fstrim.enable = true; # SSD health

  # 5. POWER MANAGEMENT (Desktop Profile)
  # Force TLP off (it's for laptops) and use GNOME's preferred daemon
  services.tlp.enable = lib.mkForce false;
  services.power-profiles-daemon.enable = true;

  services.openssh.enable = true;

  # We use /. + to force Nix to recognize this as an absolute path in a Flake
  security.pki.certificateFiles = [ /etc/nixos/certs/comp.crt ];

  # SYSTEM TOOLS & NIX-LD
  # Nix-LD allows you to run unpatched binaries (VS Code, AI tools, etc.)
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    fuse3
    icu
    nss
    openssl
    curl
    expat
  ];

  environment.systemPackages = with pkgs; [
    swaynotificationcenter # For your Tokyo Midnight Sway theme
    libnotify
    exiftool # For your massive photo project
    pciutils # Helpful for GPU debugging (lspci)
    bluez
    blueman
    lm_sensors
    rocmPackages.rocm-smi
    rocmPackages.rocminfo
    amdgpu_top
    coolercontrol.coolercontrol-gui
    lact
    pkgs.polkit_gnome
  ];

  # 7. HARDWARE SUPPORT
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Swap with zram
  zramSwap.enable = true;
  zramSwap.memoryPercent = 50;

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 8 * 1024;
  }];

  boot.kernel.sysctl = {
    "vm.swappiness" = 10; # first use zram, then swapfile
  };
}
