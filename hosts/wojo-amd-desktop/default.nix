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
    ./ai.nix # The ROCm 7.x / Ollama stack we built
  ];

  # 1. NETWORKING & KERNEL (Ryzen 9000 & Wi-Fi 7 Readiness)
  networking.hostName = "wojo-amd-desktop";
  boot.kernelPackages = pkgs.linuxPackages_latest; # Crucial for 2026 hardware
  hardware.enableAllFirmware = true;

  # Ensure the GPU wakes up early during boot
  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];


  # 1. Forceer de modernste AMD energie-sturing
  boot.kernelParams = [
    "amd_pstate=active"
    "lockdown=none"
  ];


  # 1. De driver voor je MSI moederbord fans (Nuvoton)
  boot.kernelModules = [
    "nct6687"
    "i2c-dev"
  ];
  boot.extraModulePackages = [ config.boot.kernelPackages.nct6687d ];

  # 2. De MSI-specifieke fix voor de fansnelheid-uitlezing
  boot.extraModprobeConfig = ''
    options nct6687 fan_config=msi_alt1
  '';

  programs.coolercontrol.enable = true;


  # LACT: De redding voor AMD GPU controle
  systemd.services.lactd = {
    description = "AMDGPU Control Daemon";
    enable = false;
    serviceConfig = {
      ExecStart = "${pkgs.lact}/bin/lact daemon";
      Restart = "always";
    };
    wantedBy = [ "multi-user.target" ];
  };


  # Enable SSH for rsyncing files from your MacBook

  # 2. DESKTOP ENVIRONMENTS (GNOME for Family, Sway for Alex)
  services.xserver.enable = true;
  services.desktopManager.gnome.enable = true;
  programs.sway.enable = true;

  # XDG Portals: Moved to system level for proper Sway/Gnome compatibility
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  # 3. USER ACCOUNTS & GROUPS
  users.groups.photos = { };

  # Main User (Alex) - Needs access to everything

  # 3. USER ACCOUNTS
  users.users =
    let
      kidConfig = {
        isNormalUser = true;
        extraGroups = [ "networkmanager" "photos" "video" ];
      };
    in
    {
      # Move alex inside the set here
      alex = {
        isNormalUser = true;
        description = "alex";
        extraGroups = [ "wheel" "networkmanager" "docker" "video" "render" "photos" ];
      };

      # The kids follow
      nout = kidConfig;
      emmeline = kidConfig;
      julia = kidConfig;
    };


  # 4. STORAGE & MAINTENANCE
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

  # 6. SYSTEM TOOLS & NIX-LD
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
