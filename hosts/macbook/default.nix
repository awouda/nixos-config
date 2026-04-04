{ config, pkgs, lib, ... }:

{
  imports = [
    ../../configuration.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "mbp-nixos";

  # --- MacBook Pro 11,1 Specifieke Hardware ---
  hardware.facetimehd.enable = true;

  nixpkgs.config.permittedInsecurePackages = [
    "broadcom-sta-6.30.223.271-59-6.12.77"
  ];

  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  boot.initrd.kernelModules = [ "wl" ];
  boot.blacklistedKernelModules = [ "b43" "ssb" "bcma" ];

  boot.kernelParams = [
    "acpi_backlight=vendor" # Native Intel backlight
    "i915.enable_dc=0" # Haswell GPU wake-up fix
    "intel_idle.max_cstate=1" # Race condition fix
    "hid_apple.fnmode=2" # Media keys als default, F-keys via Fn
  ];

  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  services.xserver.xkb = {
    layout = "us";
    # Verwijder 'altwin:swap_lalt_lwin'
    options = lib.mkForce "caps:escape";
  };

  programs.dconf.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-gtk
    ];
    config.common.default = "gnome"; # Forceert GNOME portals
  };

  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = lib.mkForce "GNOME";
  };

  programs.sway = {
    enable = true;
    extraSessionCommands = ''
      eval $(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
      export XDG_CURRENT_DESKTOP=sway
      export XDG_SESSION_DESKTOP=sway
      export GNOME_KEYRING_CONTROL
      export SSH_AUTH_SOCK
    '';
  };

  # Keyring support (overgenomen van wojo-bak voor consistentie)
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;

  # --- Gebruikers ---
  users.users = {
    alex = {
      isNormalUser = true;
      description = "alex";
      extraGroups = [ "wheel" "networkmanager" "docker" "video" "render" "uinput" ];
    };
    julia = {
      isNormalUser = true;
      description = "Julia";
      extraGroups = [ "networkmanager" "video" "render" ];
    };
  };

  # --- Power Management (TLP is beter voor deze generatie MacBook) ---
  services.tlp = {
    enable = true;
    settings = {
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MAX_PERF_ON_BAT = 60;
      USB_AUTOSUSPEND = 0;
    };
  };
  services.power-profiles-daemon.enable = false; # Voorkom conflict met TLP

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  # --- Systeem Tools ---
  environment.systemPackages = with pkgs; [
    pkgs.linuxPackages.cpupower
    blueman
    libnotify
    glib # Voor gsettings
    gnome-tweaks # Voor extra thema opties
    gnome-backgrounds # De standaard collectie wallpapers
    adwaita-icon-theme
  ];

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;
}
