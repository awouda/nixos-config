{ pkgs, ... }:

{
  programs.waybar = {
    enable = true;

    # This section handles the look (CSS)
    style = ''
        * {
            font-family: "JetBrainsMono Nerd Font";
            font-size: 13px;
            border: none;
            border-radius: 0;
        }

        window#waybar {
            background-color: rgba(26, 26, 26, 0.9);
            border-bottom: 2px solid #333333;
            color: #ffffff;
        }

        #workspaces button {
            padding: 0 5px;
            background-color: transparent;
            color: #888888;
        }

        #workspaces button.focused {
            color: #00ff00; /* Minimalist green accent */
            border-bottom: 2px solid #00ff00;
        }

       #window {
      padding: 0 30px; /* Adds space around the window title */
      color: #bbbbbb;
      font-weight: bold;
       }

        #battery, #clock, #cpu, #memory, #network, #pulseaudio, #tray {
            padding: 0 10px;
            background: transparent;
            color: #ffffff;
        }

        #battery.charging {
            color: #00ff00;
        }

        #battery.warning:not(.charging) {
            color: #ffaa00;
        }
    '';

    # This section handles the logic and modules
    settings = [{
      layer = "top";
      position = "top";
      height = 30;

      modules-center = [ "sway/window" "clock" ];
      modules-left = [ "sway/workspaces" "sway/mode" ];
      modules-right = [ "cpu" "memory" "pulseaudio" "network" "battery" "tray" ];

      "sway/workspaces" = {
        disable-scroll = true;
        all-outputs = true;
        format = "{name}";
      };

      "clock" = {
        format = "{:%H:%M | %a %d %b}";
        tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
      };

      "cpu" = {
        format = "  {usage}%";
      };

      "memory" = {
        format = "  {}%";
      };

      "pulseaudio" = {
        format = "{icon} {volume}%";
        format-muted = "󰝟 ";
        format-icons = {
          default = [ " " " " " " ];
        };
        on-click = "pavucontrol";
      };

      "network" = {
        format-wifi = "  {essid}";
        format-ethernet = "󰈀  {ipaddr}";
        format-disconnected = "󰤮  Disconnected";
        on-click = "rofi-wifi-menu"; # Matches your requested script!
      };

      "battery" = {
        states = {
          warning = 30;
          critical = 15;
        };
        format = "{icon} {capacity}%";
        format-charging = "󱐋 {capacity}%";
        format-icons = [ "  " "  " "  " "  " "  " ];
      };

      "tray" = {
        spacing = 10;
      };
    }];
  };
}
