{ config, lib, pkgs, ... }:

{
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true; # otherwise some apps look like from '95
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

}
