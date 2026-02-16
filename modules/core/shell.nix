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
  home.packages = [ git-fuzzy-pkg ];

  programs.starship = {
    enable = true;
    settings = {
      format = "$directory$git_branch$git_status $time $character";
      time = {
        disabled = false;
        style = "yellow";
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

  programs.bash = {
    enable = true;
    initExtra = ''
        eval "$(starship init bash)"
    
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
    '';
    shellAliases = {
      nrs = " sudo nixos-rebuild switch ";
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
    };
  };
}
