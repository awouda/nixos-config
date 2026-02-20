{ config, pkgs, ... }:

{
  # --- Dell XPS 14/16 (Intel Panther Lake X7 358H) ---
  imports = [
    ../../configuration.nix
    ../../hardware-configuration.nix
  ];

  networking.hostName = "xps-nixos";

  # Enable proprietary firmware (crucial for modern Intel microcode and WiFi)
  hardware.enableAllFirmware = true;

  # Require the latest kernel for brand-new architecture support
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Intel Arc iGPU (Xe2 / Battlemage) Hardware Acceleration
  services.xserver.videoDrivers = [ "modesetting" ];
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # VA-API hardware video decode
      vpl-gpu-rt # oneVPL / QuickSync
      intel-compute-runtime # OpenCL for Arc
    ];
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };

  # Panther Lake Suspend Workaround 
  # (Keeps the machine running with the screen off until S0ix sleep is fixed upstream)
  services.logind = {
    lidSwitch = "ignore";
    lidSwitchExternalPower = "ignore";
  };

  # Intel Thermal Daemon (Prevents thermal throttling on modern Intel CPUs)
  services.thermald.enable = true;
}
