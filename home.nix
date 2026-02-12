{ pkgs, lib, ... }:




{
  home.username = "alex";
  home.homeDirectory = "/home/alex";
  home.stateVersion = "25.11";


  programs.google-chrome = {
    enable = true;
  };


  # This is where your Ghostty, Starship, and Zinit settings go!
  programs.starship.enable = true;

  # We can start moving your sway.nix text blocks here next.

  # --- Parked: Atuin (Ctrl+R) ---
  programs.atuin = {
    enable = true;
    enableBashIntegration = true; # Links it to your shell
    # Add this to ensure it hooks into the shell correctly
    flags = [ "--disable-up-arrow" ];
  };

  programs.bash = {
    enable = true;
    # This is the "magic" that fixes the $ATUIN_SESSION error
    initExtra = ''
      # extra atuin config below
    '';
    shellAliases = {
      nrs = "sudo nixos-rebuild switch";
      # added sudo chown -R alex:users /etc/nixos
      # so we can use git without sudo in /etc/nixos
      nconf = "vi /etc/nixos/configuration.nix";
      hconf = "vi /etc/nixos/home.nix";
    };
  };


  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true; # This is the "Ops" way to map 'vi' to 'nvim'
    vimAlias = true; # Maps 'vim' to 'nvim' as well
    withNodeJs = true;
    withPython3 = true;
    # this is the extra old 'vimrc' config 
    extraConfig = ''
      set clipboard+=unnamedplus
      set number          " Shows the current line number
      set relativenumber  " Shows relative numbers for all other lines
 
      " Auto-format .nix files on save
      autocmd BufWritePost *.nix silent! !${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt %

      " (We'll add your custom functions and the shortcut for +y later!)
    '';
  };


  # --- Sway Configuration ---
  wayland.windowManager.sway = {
    enable = true;
    # This bit tells Home Manager to include the standard Sway defaults 
    # so you don't lose basic things like moving windows or resizing.
    config = rec {
      modifier = "Mod4";
      terminal = "alacritty";
      menu = "rofi -show drun -show-icons";

      # Output (Display Scaling & Position)
      output = {
        "eDP-1" = {
          scale = "2";
          pos = "0 0";
        };
        "HDMI-A-2" = {
          res = "3840x1600@29.998Hz";
          pos = "1280 0";
          scale = "1";
        };
      };

      # Keybindings (Merging your custom keys with defaults)
      keybindings = lib.mkOptionDefault {
        "${modifier}+Return" = "exec ${terminal}";
        "${modifier}+d" = "exec ${menu}";
        "${modifier}+Shift+q" = "kill";
        "${modifier}+Shift+e" = "exec swaynag -t warning -m 'Exit Sway?' -B 'Yes' 'swaymsg exit'";

        # Clipboard History
        "${modifier}+Control+h" = "exec clipman pick -t rofi";

        # Multimedia Keys
        "XF86AudioRaiseVolume" = "exec pamixer -i 5";
        "XF86AudioLowerVolume" = "exec pamixer -d 5";
        "XF86AudioMute" = "exec pamixer -t";
        "XF86MonBrightnessUp" = "exec brightnessctl set 5%+";
        "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";

        # Screenshot (Your custom shortcut)
        "Control+Mod4+s" = "exec grim -g \"$(slurp)\" - | wl-copy";
      };

      # Status Bar
      bars = [{ command = "waybar"; }];

      # Autostart
      startup = [
        { command = "nm-applet --indicator"; }
        { command = "wl-paste -t text --watch clipman store --no-persist"; }
      ];
    };
  };

  # Add necessary packages for the rice
  home.packages = with pkgs; [
    alacritty
    rofi
    waybar
    pamixer
    brightnessctl
    grim
    slurp
    wl-clipboard
    clipman
    networkmanagerapplet
    wl-clipboard
    git
    htop
    btop
    yazi
    fzf
  ];
}


