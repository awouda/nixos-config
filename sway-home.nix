{ pkgs, lib, ... }:

{
  # Sway Services config
  services.swayidle = {
    enable = true;
    timeouts = [
      {
        timeout = 180;
        command = "${pkgs.swaylock-effects}/bin/swaylock -f --screenshots --clock --indicator --effect-blur 7x5";
      }
      {
        timeout = 420;
        command = "${pkgs.sway}/bin/swaymsg 'output * power off'";
        resumeCommand = "${pkgs.sway}/bin/swaymsg 'output * power on'";
      }
    ];
    events = [
      { event = "before-sleep"; command = "${pkgs.swaylock}/bin/swaylock -f -c 000000"; }
    ];
  };

  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects; # This tells the module to use the effects version
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

      window = {
        titlebar = false;
        border = 1;
      };
      floating = {
        titlebar = false;
      };
      gaps = {
        inner = 8;
        outer = 10;
        smartGaps = true;
      };


      colors = {
        focused = {
          border = "#bbbbbb"; # Slightly softer white/gray
          background = "#282828";
          text = "#ffffff";
          indicator = "#444444";
          childBorder = "#bbbbbb";
        };
        focusedInactive = {
          border = "#333333";
          background = "#282828";
          text = "#888888";
          indicator = "#282828";
          childBorder = "#333333";
        };
      };

      # Output (Display Scaling & Position)
      output = {
        "eDP-1" = {
          scale = "1.8";
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
        "${modifier}+space" = "floating toggle";
        # Clipboard History
        "${modifier}+Control+h" = "exec cliphist list | rofi -dmenu | cliphist decode | wl-copy";
        # Manual lock with Super+L
        "${modifier}+Control+l" = "exec ${pkgs.swaylock-effects}/bin/swaylock -f --screenshots --clock --indicator --effect-blur 7x5";

        # Multimedia Keys
        "XF86AudioRaiseVolume" = "exec pamixer -i 5";
        "XF86AudioLowerVolume" = "exec pamixer -d 5";
        "XF86AudioMute" = "exec pamixer -t";
        "XF86MonBrightnessUp" = "exec brightnessctl set 5%+";
        "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";

        # Screenshot (Your custom shortcut)
        "Control+Mod4+s" = "exec grim -g \"$(slurp)\" - | wl-copy";


      };
      window.commands = [
        {
          command = "floating enable, sticky enable, resize set 640 480, move position center";
          criteria = { app_id = "guvcview"; };
        }
      ];

      # Status Bar
      bars = [{ command = "waybar"; }];

      # Autostart
      startup = [
        { command = "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator"; }
        { command = "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store"; }
        { command = "${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist store"; }
      ];
    };
    extraConfig = ''
      exec swaymsg workspace number 1

      # Essential for making GTK apps snappy and functional on Wayland
      exec dbus-update-activation-environment --all
      exec systemctl --user import-environment PATH JAVA_HOME
    '';
  };
}


