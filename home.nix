{ pkgs, lib, ... }:

{
  home.username = "alex";
  home.homeDirectory = "/home/alex";
  home.stateVersion = "25.11";

  # fonts configuration
  fonts.fontconfig.enable = true;

  # program specific configuration

  programs.google-chrome = {
    enable = true;
  };

  programs.starship.enable = true;

  # Atuin
  programs.atuin = {
    enable = true;
    enableBashIntegration = true; # Links it to your shell
    # Add this to ensure it hooks into the shell correctly
    flags = [ "--disable-up-arrow" ];
  };


  programs.git = {
    enable = true;
    extraConfig = {
      # This helps with the "pushing new branches" 
      push.autoSetupRemote = true;
      # Standardize on rebase for pulls to keep history clean
      pull.rebase = true;
    };
  };

  # Bash config
  programs.bash = {
    enable = true;
    initExtra = ''
      gfl() {
            git log --graph --color=always \
                --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
            fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
                --bind "ctrl-m:execute:
                          (grep -o '[a-f0-9]\{7\}' | head -1 |
                          xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                          {}
          FZF-EOF"
          }
    '';
    shellAliases = {
      nrs = " sudo nixos-rebuild switch ";
      # added sudo chown -R alex:users /etc/nixos
      # so we can use git without sudo in /etc/nixos
      nconf = " vi /etc/nixos/configuration.nix ";
      hconf = " vi /etc/nixos/home.nix ";
      gco = " git checkout ";
      gcb = " git checkout -b ";
      gfs = " git status -sb ";
      gcam = " git commit -am ";
      ggpush = " git push origin HEAD ";
      ggpull = " git pull origin HEAD ";
    };
  };


  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
    withPython3 = true;
    # this is the extra old 'vimrc' config 
    extraConfig = ''
      set clipboard+=unnamedplus
      set number
      set relativenumber

      " Remap S to yank to system clipboard [cite: 2026-02-12]
      nnoremap S "+y
      vnoremap S "+y

      " JSON Formatting shortcut (requires jq) [cite: 2026-02-12]
      " This pipes the whole file through jq and puts it back
      command! FormatJSON %!${pkgs.jq}/bin/jq .

      autocmd BufWritePost *.nix silent! !${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt %
    '';
  };


  programs.alacritty.settings = {
    font.normal.family = "JetBrainsMono Nerd Font Mono"; # Match the fc-list Mono variant [cite: 2026-02-12]
    font.size = 14;
    selection.save_to_clipboard = true;
    window.opacity = 0.95;
  };
  # Services config

  services.swayidle = {
    enable = true;
    timeouts = [
      { timeout = 300; command = "${pkgs.swaylock}/bin/swaylock -f -c 000000"; } # 5 min lock [cite: 2026-02-12]
      {
        timeout = 600;
        command = "${pkgs.sway}/bin/swaymsg 'output * power off'"; # 10 min off [cite: 2026-02-12]
        resumeCommand = "${pkgs.sway}/bin/swaymsg 'output * power on'";
      }
    ];
    events = [
      { event = "before-sleep"; command = "${pkgs.swaylock}/bin/swaylock -f -c 000000"; }
    ];
  };

  programs.swaylock.enable = true;


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
        "${modifier}+Control+h" = "exec cliphist list | rofi -dmenu | cliphist decode | wl-copy";
        # In your wayland.windowManager.sway.config.keybindings

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
        { command = "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator"; }
        { command = "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store"; }
        { command = "${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist store"; }
      ];
    };
  };

  # Add here packages which we want
  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only # Good to have for extra icons 
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
    azure-cli
    yq
    jq
    httpie
    wget
    curl
    tv
    kubectl
    kubectx
    kubelogin
    wtype
    cliphist
    guvcview
  ];
}


