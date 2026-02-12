{ config, lib, pkgs, ... }:

{

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };


  # 3. Fix the Display Manager warnings (New 25.11 Syntax)
  services.displayManager = {
    sessionPackages = [ pkgs.sway ];
    gdm = {
      enable = true;
      wayland = true;
    };
  };


  # 4. Environment Variables
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; 
    GDK_SCALE = "2";
    QT_SCALE_FACTOR = "2";
  };
}
