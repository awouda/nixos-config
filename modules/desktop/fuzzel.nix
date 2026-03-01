{ pkgs, ... }:

{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font:size=12";
        terminal = "${pkgs.alacritty}/bin/alacritty";
        prompt = "'❯ '";
        width = 40;
        horizontal-pad = 20;
        vertical-pad = 10;
        inner-pad = 10;
        line-height = 20;
        fields = "filename,name,generic";
      };

      colors = {
        background = "1a1b26ef"; # Tokyo Night Storm (with slight transparency)
        text = "c0caf5ff";
        match = "7aa2f7ff"; # Blue for matches
        selection = "33467cff"; # Darker blue for selection
        selection-text = "ffffffff";
        border = "7aa2f7ff"; # Blue border
      };

      border = {
        width = 2;
        radius = 12;
      };
    };
  };
}
