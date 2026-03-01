{ config, pkgs, lib, ... }:

{
  # --- Generic Fallback Profile ---
  imports = [
    ../../configuration.nix
    ./hardware-configuration.nix
  ];


# Host-specific override for Chrome scaling
home-manager.users.alex.programs.chromium.package = lib.mkForce (pkgs.google-chrome.override {
    commandLineArgs = [
      "--ozone-platform-hint=auto"
      "--force-device-scale-factor=1.0"
    ];
  });

           # This is the "Veto": Force scale 1.0 for the XPS
  # We use lib.mkForce to make sure it wins over the shared module
  home-manager.users.alex.wayland.windowManager.sway.config.output."*".scale = pkgs.lib.mkForce "1.0";

  networking.hostName = "lap1-nixos";
  # 1. Load all standard Linux firmware (Gets Wi-Fi/Bluetooth working on 99% of machines)
  hardware.enableAllFirmware         = true;

  # 2. Universal Graphics Fallback (Works safely on Intel, AMD, and basic Nvidia)
  services.xserver.videoDrivers = [ "modesetting" ];

  # 3. Intel Thermal Daemon (Prevents throttling on older Intel chips, sits dormant on AMD)
  services.thermald.enable = true;
}
