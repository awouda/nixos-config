{ config, lib, pkgs, ... }:

{

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true; # otherwise some apps look like from '95
  };


  #  We need those for pam/login
  services.displayManager = {
    sessionPackages = [ pkgs.sway ];
    gdm = {
      enable = true;
      wayland = true;
    };
  };


  #  Environment Variables
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # use Wayland
  };
}
