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
    package = pkgs.swayfx;
    checkConfig = false;
    # This bit tells Home Manager to include the standard Sway defaults 
    # so you don't lose basic things like moving windows or resizing.
    config = rec {
      modifier = "Mod4";
      terminal = "alacritty";
      menu = "fuzzel";

      window = {
        titlebar = false;
        border = 2;
      };
      floating = {
        titlebar = false;
        border = 2;
      };
      gaps = {
        inner = 4;
        outer = 10;
        smartGaps = true;
      };

      colors = {
        focused = {
          border = "#64727d";
          background = "#64727d";
          text = "#ffffff";
          indicator = "#64727d";
          childBorder = "#64727d";
        };
        focusedInactive = {
          border = "#1e1e2e";
          background = "#1e1e2e";
          text = "#ffffff";
          indicator = "#1e1e2e";
          childBorder = "#1e1e2e";
        };
        unfocused = {
          border = "#1e1e2e";
          background = "#1e1e2e";
          text = "#ffffff";
          indicator = "#1e1e2e";
          childBorder = "#1e1e2e";
        };
      };

      input = {
        # Applies to all keyboards
        "type:keyboard" = {
          xkb_options = "caps:escape,altwin:swap_lalt_lwin";
        };
        "type:touchpad" = {
          tap = "enabled";
          dwt = "enabled"; # Palm detection 
          natural_scroll = "enabled";
        };
        "type:pointer" = {
          left_handed = "enabled";
        };
      };

      output = {
        "*" = {
          bg = "${./wallpaper/light-ring.jpg} fill";
          scale = "2.0"; # This hits your laptop screen
        };
        "DP-1" = {
          # Updated from HDMI-A-2 based on your swaymsg output
          res = "3840x1600@59.994Hz"; # Updated from 29.998Hz
          pos = "0 0"; # Changed position to 0 0 if this is your primary workspace
          scale = "1.0"; # Keeps the ultrawide crisp
        };
      };

      # Keybindings (Merging your custom keys with defaults)
      keybindings = lib.mkOptionDefault {
        "${modifier}+Return" = "exec ${terminal} --working-directory ~ ";
        "${modifier}+d" = "exec ${menu}";
        "${modifier}+Shift+q" = "kill";
        "${modifier}+Shift+e" = "exec swaynag -t warning -m 'Exit Sway?' -B 'Yes' 'swaymsg exit'";
        "${modifier}+space" = "floating toggle";
        # Manual lock with Super+L
        "${modifier}+Control+l" = "exec ${pkgs.swaylock-effects}/bin/swaylock -f --screenshots --clock --indicator --effect-blur 7x5";

        # Multimedia Keys
        "XF86AudioRaiseVolume" = "exec pamixer -i 5";
        "XF86AudioLowerVolume" = "exec pamixer -d 5";
        "XF86AudioMute" = "exec pamixer -t";
        "XF86MonBrightnessUp" = "exec brightnessctl set 5%+";
        "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";

        # Screenshot (Your custom shortcut)
        "${modifier}+Control+s" = "exec grim -g \"$(slurp)\" -t png - | wl-copy -t image/png";

        # clipboard history
        # Just use the name of the script
        "${modifier}+Control+p" = "exec clip-paster";
        # Window Switcher (Classic Alt-Tab style but with Super)
        "${modifier}+Tab" = "exec sway-windows";

        # Global Finder (Raycast style)
        # Using Control + Mod4 + f to avoid the fullscreen conflict
        "Control+${modifier}+f" = "exec finder";

        "${modifier}+Shift+Backspace" = "exec swaymsg \"output * dpms on\"";
      };


      # --- Verify your Window Commands ---
      window.commands = [
        {
          criteria = { app_id = "guvcview"; };
          command = "floating enable, sticky enable, resize set 640 480, move position center";
        }
        {
          # Ensure this is a separate set in the list
          criteria = { app_id = "clipse"; };
          command = "floating enable, resize set 800 600, move position center";
        }
      ];

      # Status Bar
      bars = [{ command = "waybar"; }];

      # Autostart
      startup = [
        { command = "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator"; }
        # Watcher for text
        { command = "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store"; }
        # Watcher for images (perfect for your grim/slurp screenshots)
        { command = "${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist store"; }
      ];
    };
    extraConfig =
      # language=bash
      ''
        # Disable laptop screen when lid is closed
        bindswitch lid:on output eDP-1 disable
        # Re-enable laptop screen when lid is opened
        bindswitch lid:off output eDP-1 enable

        exec swaymsg workspace number 1

        # Corners and Shadows
        corner_radius 12
        shadows enable
        shadows_on_csd enable

        # Blur Logic
        blur enable
        blur_passes 3
        blur_radius 4

        # Apply effects to UI layers
        layer_effects "waybar" blur enable, blur_ignore_transparent enable;
        layer_effects "rofi" blur enable; shadows enable; corner_radius 12

        # Essential for making GTK apps snappy and functional on Wayland
        exec dbus-update-activation-environment --all
        exec systemctl --user import-environment PATH JAVA_HOME
      '';
  };
}
