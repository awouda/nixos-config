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
  boot.kernelParams = [ "hid_apple.fnmode=2" ];

}
