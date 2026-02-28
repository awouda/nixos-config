{ config, pkgs, ... }:

{
  imports = [
    ../../configuration.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "mbp-nixos";

  # Apple MacBook Pro 11,1 specific config
  hardware.facetimehd.enable = true;

  nixpkgs.config.permittedInsecurePackages = [
    "broadcom-sta-6.30.223.271-59-6.12.73"
  ];

  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  boot.initrd.kernelModules = [ "wl" ];

  # Block the open-source drivers that conflict with 'wl'
  boot.blacklistedKernelModules = [ "b43" "ssb" "bcma" ];

  # Toggle Fn key behavior
  boot.kernelParams = [

    # Forces the native Intel backlight driver (fixes the "Skipping" error)
    "acpi_backlight=vendor"

    # Prevents Haswell GPUs from entering a state they can't wake up from
    "i915.enable_dc=0"

    # Fixes a specific race condition in the Intel idle states on 2014 MBPs
    "intel_idle.max_cstate=1"

    # toggle Fn key
    "hid_apple.fnmode=2"
  ];


  # Enable Bluetooth hardware support
  hardware.bluetooth.enable = true;

  # Optional: Power on the controller on boot
  hardware.bluetooth.powerOnBoot = true;

  # Enable Blueman for the tray applet and manager
  services.blueman.enable = true;

  services.tlp.settings = {
    # Keeps the internal USB/SMC bus powered for a clean wake
    USB_AUTOSUSPEND = 0;

    # Ensures the i915 driver doesn't try to save too much power on battery
    PCIE_ASPM_ON_BAT = "performance";
    CPU_SCALING_GOVERNOR_ON_AC = "performance";
    CPU_SCALING_GOVERNOR_ON_BAT = "schedutil"; # Better than powersave for responsiveness
    CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
    CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_performance";
  };

  services.logind.settings.Login = {
    # On Battery: Close lid = Sleep
    HandleLidSwitch = "suspend";

    # On Power: Close lid = Stay awake (for your external monitor)
    HandleLidSwitchExternalPower = "ignore";

    # If connected to a dock: Stay awake
    HandleLidSwitchDocked = "ignore";
  };

}
