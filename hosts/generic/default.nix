{ config, pkgs, lib, ... }:

{
  # --- Generic Fallback Profile ---
  imports = [
    ../../configuration.nix
    ./hardware-configuration.nix
  ];

  # --- Host-specific Scaling ---
  home-manager.users.alex.programs.chromium.package = lib.mkForce (pkgs.google-chrome.override {
    commandLineArgs = [
      "--ozone-platform-hint=auto"
      "--force-device-scale-factor=1.0"
    ];
  });
  home-manager.users.alex.wayland.windowManager.sway.config.output."*".scale = pkgs.lib.mkForce "1.0";

  networking.hostName = "lap1-nixos";
  hardware.enableAllFirmware = true;

  # 1. VIDEO DRIVERS
  # We use the official nvidia driver to manage the Quadro power states
  services.xserver.videoDrivers = [ "nvidia" ];

  # 2. DESKTOP ENVIRONMENTS (GNOME for Family, Sway for Alex)
  services.xserver.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  programs.sway.enable = true;

  users.groups.photos = { };

  # 3. USER ACCOUNTS
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
        extraGroups = [ "wheel" "networkmanager" "docker" "video" "render" "photos" ];
      };

      # The kids follow
      nout = kidConfig;
      emmeline = kidConfig;
      julia = kidConfig;
    };


  # testing this on the Dell
  systemd.tmpfiles.rules = [
    "d /srv/photos 2775 root photos - -"
  ];

  # XDG Portals: Moved to system level for proper Sway/Gnome compatibility
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  boot.kernelParams = [
    # 1. THE CERTIFIED HANDSHAKE (Clears Windows, adds Ubuntu)
    "acpi_osi=!"
    "acpi_osi=\"Linux\""
    "acpi_osi=\"Ubuntu2014\""

    # 2. THE HARDWARE STABILITY FIXES
    "acpi_rev_override=1"
    "intremap=no_x2apic_optout"
    "button.lid_init_state=open"
    "thermal.off=1"
    "intel_idle.max_cstate=4"
    "i915.enable_psr=0"
    "i915.enable_dc=0"

    # 3. THE "FORCE" SAFETY NET
    "acpi_enforce_resources=lax"
    "acpi_backlight=none"
    "acpi=force"
    "pcie_aspm=off"
  ];

  # 3. NVIDIA POWER MANAGEMENT
  hardware.nvidia = {
    open = false; # Required for Maxwell cards (M1000M)
    modesetting.enable = true;
    powerManagement.enable = true; # Let the driver handle sleep/wake
    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # 4. Cleanup
  boot.blacklistedKernelModules = [ "nouveau" ];
  hardware.opengl.enable = true;
  services.thermald.enable = true;


  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  services.blueman.enable = true; # provides the blueman-applet and manager


  services.tlp = {
    enable = true;
    settings = {
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MAX_PERF_ON_BAT = 60;
      USB_AUTOSUSPEND = 0;
    };
  };
  services.power-profiles-daemon.enable = false; # TLP and PPD conflict
  environment.systemPackages = [ pkgs.linuxPackages.cpupower ];
}
