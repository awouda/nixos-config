{ pkgs, lib, ... }:

{

  imports =
    [
      ./neovim.nix
      ./sway-home.nix
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

  # Git
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

        if [ -d /etc/nixos/.git ]; then
           CHANGES=$(git -C /etc/nixos status --porcelain)
            if [ -n "$CHANGES" ]; then
            echo -e "\e[33m󱈚 Ops Alert: Uncommitted changes in /etc/nixos\e[0m"
           fi
        fi

       # Java Check
       if ! grep -q "programs.java" /etc/nixos/*.nix; then
          if command -v java >/dev/null; then
              echo -e "\e[31m󰓅 Warning: Java is installed but not declared in Nix config!\e[0m"
          fi
      fi
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

  # Java. Current main version 21
  programs.java = {
    enable = true;
    package = pkgs.temurin-bin-21;
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


