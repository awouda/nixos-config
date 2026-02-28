{ pkgs, lib, config, ... }:

let
  git-fuzzy-pkg = pkgs.stdenv.mkDerivation {
    pname = "git-fuzzy";
    version = "94994df";

    src = pkgs.fetchFromGitHub {
      owner = "bigH";
      repo = "git-fuzzy";
      rev = "94994df792eb16638aea9a9726eac321bb6da2ca";
      sha256 = "sha256-T2jbMMNckTLN7ejH+Fl2T4wAALGExiE3+DohZjxa1y4=";
    };

    nativeBuildInputs = [ pkgs.makeWrapper ];

    installPhase = ''
      mkdir -p $out/bin $out/share/git-fuzzy
      cp -r * $out/share/git-fuzzy/
      
      # We wrap the binary so it always has access to bc, git, and fzf
      makeWrapper $out/share/git-fuzzy/bin/git-fuzzy $out/bin/git-fuzzy \
        --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.bc pkgs.git pkgs.fzf pkgs.coreutils ]}
    '';
  };
in
{

  imports = [
    ./neovim.nix
  ];

  programs.helix = {
    enable = true;
    settings = {
      theme = "terminal";
      editor = {
        line-number = "relative";
        cursor-shape = {
          insert = "bar";
          normal = "block";
        };
      };
    };
  };


  home.packages = [ git-fuzzy-pkg ];

  programs.starship = {
    enable = true;
    settings = {
      # Tokyo Night Palette
      palette = "tokyo_night";
      palettes.tokyo_night = {
        blue = "#7aa2f7";
        magenta = "#bb9af7";
        cyan = "#7dcfff";
        green = "#9ece6a";
        red = "#f7768e";
        yellow = "#e0af68";
      };

      # Prompt Layout
      format = "$directory$git_branch$git_status$character";
      right_format = "$time";

      directory = {
        style = "bold blue";
        truncate_to_repo = true;
      };

      git_branch = {
        symbol = " ";
        style = "bold magenta";
      };

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };

      time = {
        disabled = false;
        time_format = "%R"; # HH:MM
        style = "bold yellow";
      };
    };
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = false;
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
    flags = [ "--disable-up-arrow" ];
  };

  programs.git = {
    enable = true;
    settings = {
      push.autoSetupRemote = true;
      pull.rebase = true;
    };
  };


  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    # This ensures direnv reads the silent format from its own config
    config = {
      global.log_format = "";
    };
  };

  programs.bash = {
    enable = true;
    initExtra = ''
      # Initialize ble.sh early (Syntax highlighting and autocompletion)
      [[ $- == *i* ]] && source ${pkgs.blesh}/share/blesh/ble.sh --noattach

      bleopt term_true_colors=1 

      export COLORTERM=truecolor
      export TERM=xterm-256color

      eval "$(starship init bash)"

      # Set the silence variable immediately
      export DIRENV_LOG_FORMAT=""

      # Cat and copy to Wayland clipboard
      ccat() {
        cat "$@" | wl-copy
        echo "Copied to clipboard!"
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

      if [ -e "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
       . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
      fi

      # this must be before ble activation
      eval "$(zoxide init bash)"

      # ACTIVATE Ble.sh
      [[ $- == *i* ]] && ble-attach
    '';
    shellAliases = {
      nconf = " vi /etc/nixos/configuration.nix ";
      hconf = " vi /etc/nixos/home.nix ";
      gco = " git checkout ";
      gcb = " git checkout -b ";
      gcam = " git commit -am ";
      ggpush = " git push origin HEAD ";
      ggpull = " git pull origin HEAD ";
      chrome = "google-chrome-stable --high-dpi-support=1 --force-device-scale-factor=0.8";
      open = "xdg-open";
      cat = "bat -p ";
      gfs = "git fuzzy status";
      gfl = "fshow";
      sp = " wl-paste > screenshot_$(date +%F_%T).png ";

      # FAST SWITCH: Use this for 90% of changes (shell, aliases, scripts)
      # It adds all files to git automatically so you don't hit the "file not found" error.
      nrs = "git add . && sudo nixos-rebuild switch --flake .";

      # SYSTEM UPDATE: Use this when you want a new kernel or newer package versions.
      nru = "nix flake update && git add . && sudo nixos-rebuild switch --flake .";

      # TEST SWITCH: Just like nrs, but doesn't add a boot entry (good for testing rices).
      nrt = "git add . && sudo nixos-rebuild test --flake .";
    };
  };
}
