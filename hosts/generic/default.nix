{ config, pkgs, ... }:

{
  # --- Generic Fallback Profile ---
  imports = [
    ../../configuration.nix
    ../../hardware-configuration.nix
  ];

  networking.hostName = "lap1-nixos";
  # 1. Load all standard Linux firmware (Gets Wi-Fi/Bluetooth working on 99% of machines)
  hardware.enableAllFirmware = true;

  # 2. Universal Graphics Fallback (Works safely on Intel, AMD, and basic Nvidia)
  services.xserver.videoDrivers = [ "modesetting" ];

  # 3. Intel Thermal Daemon (Prevents throttling on older Intel chips, sits dormant on AMD)
  services.thermald.enable = true;
}
