{ pkgs, lib, ... }:

{

  imports =
    [
      ./neovim.nix
    ];

  home.username = "alex";
  home.homeDirectory = "/home/alex";
  home.stateVersion = "25.11";

  # fonts configuration
  fonts.fontconfig.enable = true;

  fonts.fontconfig.defaultFonts = {
    serif = [ "JetBrainsMono Nerd Font" ];
    sansSerif = [ "JetBrainsMono Nerd Font" ];
    monospace = [ "JetBrainsMono Nerd Font" ];
  };

  # Set the GTK theme and font
  gtk = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font"; # 
      size = 11;
    };
    theme = {
      name = "Adwaita-dark"; # 
      package = pkgs.gnome-themes-extra;
    };
  };

  #home.file.".local/share/applications/google-chrome.desktop".text = ''
  #[Desktop Entry]
  #Version=1.0
  #Name=Google Chrome (Scaled)
  #Exec=google-chrome-stable --high-dpi-support=1 --force-device-scale-factor=0.8 %U
  #Terminal=false
  #Icon=google-chrome
  #Type=Application
  #Categories=Network;WebBrowser;
  #MimeType=text/html;text/xml;application/xhtml+xml;application/xml;
  #'';


  # program specific configuration

  programs.chromium = {
    enable = true;
    package = pkgs.google-chrome.override {
      commandLineArgs = [
        "--ozone-platform-hint=auto"
        "--force-device-scale-factor=0.8" # Since you like the 2x scale
      ];
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      # Main layout: just call the module names
      format = "$directory$git_branch$git_status $time $character";

      time = {
        disabled = false;
        style = "yellow";
        # We put the brackets and the style variable here
        format = "[$time]($style)";
      };
    };
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };

  # Atuin
  programs.atuin = {
    enable = true;
    enableBashIntegration = true; # Links it to your shell
    # Add this to ensure it hooks into the shell correctly
    flags = [ "--disable-up-arrow" ];
  };

  programs.git = {
    enable = true;
    settings = {
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
      eval "$(starship init bash)"

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
      chrome = "google-chrome-stable --high-dpi-support=1 --force-device-scale-factor=0.8";
      google-chrome-stable = "google-chrome-stable --high-dpi-support=1 --force-device-scale-factor=0.8";
    };
  };


  programs.alacritty = {
    enable = true;
    settings = {
      font =
        {
          normal = {
            family = "JetBrainsMono Nerd Font";
            style = "Regular";
          };
        };
      font.size = 11;
      selection.save_to_clipboard = true;
      window.opacity = 0.95;
    };
  };
  # Services config

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
    '';
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
    bat
    silver-searcher
    zoxide
  ];
}


