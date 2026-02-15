{ pkgs, config, ... }:

{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    theme =
      let
        inherit (config.lib.formats.rasi) mkLiteral;
      in
      {
        "*" = {
          background-color = mkLiteral "transparent";
          # This is a global reset to prevent "Ghost White" backgrounds
        };

        "window" = {
          background-color = mkLiteral "#1a1a1a"; # Solid 80% Black
          border = mkLiteral "2px";
          border-color = mkLiteral "#ffffff"; # Solid White Border
          border-radius = mkLiteral "12px";
          width = mkLiteral "35%";
          padding = mkLiteral "15px";
        };

        "mainbox" = {
          background-color = mkLiteral "transparent";
          children = map mkLiteral [ "inputbar" "listview" ];
        };

        "inputbar" = {
          background-color = mkLiteral "transparent";
          children = map mkLiteral [ "prompt" "entry" ];
          padding = mkLiteral "0 0 10px 0";
        };

        "entry" = {
          text-color = mkLiteral "#ffffff";
          placeholder = "Search...";
          placeholder-color = mkLiteral "#666666";
        };

        "prompt" = {
          text-color = mkLiteral "#ffffff";
          padding = mkLiteral "0 10px 0 0";
        };

        "listview" = {
          background-color = mkLiteral "transparent";
          lines = 10;
          spacing = mkLiteral "5px";
        };

        "element" = {
          padding = mkLiteral "8px";
          border-radius = mkLiteral "8px";
          background-color = mkLiteral "transparent";
        };

        "element-text" = {
          text-color = mkLiteral "#ffffff"; # Force white text
          vertical-align = mkLiteral "0.5";
        };

        # The selection bar: Pure White background, Black text
        "element selected" = {
          background-color = mkLiteral "#ffffff";
        };

        "element selected element-text" = {
          text-color = mkLiteral "#000000"; # Flip to black when selected
        };

        "element-icon" = {
          size = mkLiteral "24px";
          padding = mkLiteral "0 10px 0 0";
        };
      };
  };
}
