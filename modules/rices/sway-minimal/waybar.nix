{ pkgs, ... }:

{
  programs.waybar = {
    enable = true;

    # This section handles the "Floating Pill" look
    style = ''

@define-color bg_pill rgba(30, 30, 46, 0.95); /* Deep dark blue/grey */
@define-color blue #89b4fa;
@define-color red #f38ba8;
@define-color green #a6e3a1;
@define-color orange #fab387;
@define-color yellow #f9e2af;

#workspaces, #window, #cpu, #memory, #pulseaudio, #network, #battery, #clock, #tray, #custom-pm {
    background-color: @bg_pill;
    color: #ffffff;
    border-radius: 12px;
    margin: 4px 2px;
    padding: 0 10px;
}

#pulseaudio { color: @yellow; }
#network { color: @blue; }
#custom-pm { color: @red; }


      * {
          border: none;
          border-radius: 0;
          font-family: "JetBrainsMono Nerd Font";
          font-size: 14px;
          font-weight: bold;
          min-height: 0;
      }

      /* Make the main bar invisible to create the 'floating' effect */
      window#waybar {
          background: transparent;
          color: #ffffff;
      }

      /* Base styling for all our 'pills' */
      #workspaces,
      #clock,
      #window,
      #cpu,
      #memory,
      #pulseaudio,
      #network,
      #battery,
      #tray,
      #custom-pm {
          background: rgba(30, 30, 46, 0.8);
          border-radius: 12px;
          padding: 2px 12px;
          margin: 4px 4px; /* This creates the 'gaps' between modules */
      }

      /* Specific adjustments for Workspace buttons inside the pill */
      #workspaces button {
          padding: 0 4px;
          color: #888888;
      }

      #workspaces button.focused {
          color: @blue;
          background-color: rgba(255, 255, 255, 0.1);
          border-radius: 10px;
      }

      #workspaces button:hover {
          background: rgba(255, 255, 255, 0.2);
          border-radius: 10px;
      }

      /* Window Title specific styling */
      #window {
          background: rgba(30, 30, 46, 0.8);
          padding: 0 20px;
      }

      /* Battery Alerts */
      #battery.charging {
          color: #34ff88;
      }

      #battery.warning:not(.charging) {
          color: #ffaa00;
      }

      #battery.critical:not(.charging) {
          background-color: #f53c3c;
          color: #ffffff;
      }
    '';

    settings = [{
      layer = "top";
      position = "top";
      height = 34;
      margin-top = 4;
      margin-left = 4;
      margin-right = 4;

      # Aligning to your requested layout
      modules-left = [ "sway/workspaces" "sway/mode" ];
      modules-center = [ "sway/window" ];
      modules-right = [ "cpu" "memory" "pulseaudio" "network" "battery" "clock" "tray" "custom/pm" ];

      "custom/pm" = {
        format = "";
        on-click = "nwg-bar";
        tooltip = false;
      };

      "sway/workspaces" = {
        disable-scroll = true;
        all-outputs = true;
        format = "{name}";
      };

      "sway/window" = {
        max-length = 50;
        tooltip = false;
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

      # Sticking to your working logic: Using internal Waybar volume module 
      # which respects your system/hardware media keys automatically.
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
