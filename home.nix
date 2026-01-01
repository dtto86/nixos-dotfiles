{ config, pkgs, flakePath, ... }:

{
  home = {
    username = "pravin";
    homeDirectory = "/home/pravin";
    stateVersion = "25.11";
    file = {
      ".config/hypr".source = ./config/hypr;
      ".config/waybar".source = ./config/waybar;
      ".config/kitty".source = ./config/kitty;
    };
  };

  home.packages = with pkgs; [
    google-chrome
    obsidian
    mako
    wl-clipboard
    brightnessctl
    playerctl
    hypridle
    hyprlock
    thunar
    rofi
    swayosd
    swww
    udiskie
    gnome-keyring
    nordzy-cursor-theme
    hyprshot
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    font-awesome
    libnotify
    swayidle
    swaylock
    wlogout
    cliphist
    ripgrep
    fd
    starship
    alsa-utils
    bluez
    bluez-tools
    docker
    fwupd
    fzf
    gnome-calculator
    hyprland-qtutils
    hyprutils
    hyprsunset
    thunar-volman
    trash-cli
    zip
    unzip
    onlyoffice-desktopeditors
    vlc
    tree-sitter
    luajitPackages.luarocks
    luajitPackages.magick
    nodejs_24
    upower
    power-profiles-daemon
    fastfetch
    statix
  ];

  home.activation.dotfilesSetup =
    config.lib.dag.entryBefore [ "writeBoundary" ] ''
      set -e

      DOTFILES="${flakePath}"
      CONFIG_DIR="$DOTFILES/config"
      NVIM_SRC="$CONFIG_DIR/nvim"
      NVIM_DST="$HOME/.config/nvim"
      BACKUP_DIR="$HOME/.config/nvim.backup-$(date +%Y%m%d-%H%M%S)"
      TMUX_SRC="$CONFIG_DIR/tmux"
      TPM_SRC="$TMUX_SRC/plugins/tpm"
      TMUX_DST="$HOME/.config/tmux"
      TMUX_BACKUP_DIR="$HOME/.config/tmux.backup-$(date +%Y%m%d-%H%M%S)"

      echo "[HM] Using dotfiles at: $DOTFILES"

      # if [ ! -d "$CONFIG_DIR" ]; then
      #   echo "[HM] config/ not found, cloning repo…"
      #   mkdir -p "$CONFIG_DIR"
      #   ${pkgs.git}/bin/git clone https://github.com/dtto86/dotfiles.git "$CONFIG_DIR"
      # fi

      if [ -e "$NVIM_DST" ] && [ ! -L "$NVIM_DST" ]; then
        echo "[HM] Backing up existing ~/.config/nvim → $BACKUP_DIR"
        mv "$NVIM_DST" "$BACKUP_DIR"
      fi

      if [ ! -L "$NVIM_DST" ]; then
        mkdir -p "$HOME/.config"
        ln -s "$NVIM_SRC" "$NVIM_DST"
      fi
      if [ ! -e "$TPM_SRC" ] || ( [ -d "$TPM_SRC" ] && [ ! -L "$TPM_SRC" ] && [ -z "$(ls -A "$TPM_SRC")" ] ); then
        echo "[HM] cloning tmux plugin manager…"
        ${pkgs.git}/bin/git clone https://github.com/tmux-plugins/tpm.git "$TPM_SRC"
      fi
      if [ -e "$TMUX_DST" ] && [ ! -L "$TMUX_DST" ]; then
        echo "[HM] Backing up existing ~/.config/tmux → $TMUX_BACKUP_DIR"
        mv "$TMUX_DST" "$TMUX_BACKUP_DIR"
      fi
      if [ ! -L "$TMUX_DST" ]; then
        mkdir -p "$HOME/.config"
        ln -s "$TMUX_SRC" "$TMUX_DST"
      fi
    '';

  programs =  {
    kitty = {
      enable = true;
      # settings = {
      #   fontSize = 12.5;
      #   fontFamily = "JetBrains Mono Nerd Font";
      #   boldFont = "auto";
      #   italicFont = "auto";
      #   boldItalicFont = "auto";
      #   confirm_os_window_close = 0;
      # };
    };
    neovim = {
      enable = true;
      defaultEditor = true;
    };
    git = {
      enable = true;
      settings = {
        user = {
          name = "Pravin Salgaonkar";
          email = "pravinsalg@gmail.com";
        };
        core.editor = "nvim";
        init.defaultBranch = "main";
        pull.rebase = false;
      };
    };
    waybar = {
      enable = true;
    };
    tmux = {
      enable = true;
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
     "$mod" = "SUPER";
     bind = [
       "$mod, RETURN, exec, kitty"
        "$mod, Q, killactive"
     ];
    };
  };

  services = {
    mako = {
      enable = true;
      package = pkgs.mako;
    };
  };

  systemd.user.services.powerprofile-manager = {
    Unit = {
      Description = "Event-driven power profile manager";
      After = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = pkgs.writeShellScript "powerprofile-manager" ''
        LOCK="$HOME/.local/state/powerprofile.lock"
        LOW=40
        HIGH=60
        prev=""

        mkdir -p "$(dirname "$LOCK")"

        get_info() {
          upower -i $(upower -e | grep BAT) | awk '
            /state/ {s=$2}
            /percentage/ {p=int($2)}
            END {print s ":" p}
          '
        }

        set_bias() {
          case "$1" in
            performance) echo performance ;;
            balanced)    echo balance_performance ;;
            power-saver) echo power ;;
          esac | tee /sys/devices/system/cpu/cpu*/cpufreq/energy_perf_bias \
               >/dev/null 2>&1 || true
        }

        apply_profile() {
          powerprofilesctl set "$1"
          set_bias "$1"
          pkill -RTMIN+8 waybar 2>/dev/null || true
          logger "PowerProfile → $1"
        }

        decide_auto() {
          IFS=: read state percent <<< "$(get_info)"

          if [ "$state" = "charging" ] || [ "$state" = "fully-charged" ]; then
            echo performance
          elif [ "$percent" -le "$LOW" ]; then
            echo power-saver
          elif [ "$percent" -ge "$HIGH" ]; then
            echo balanced
          else
            echo "$prev"
          fi
        }

        upower --monitor-detail | while read -r _; do
          if [ -f "$LOCK" ]; then
            profile=$(cat "$LOCK")
          else
            profile=$(decide_auto)
          fi

          if [ -n "$profile" ] && [ "$profile" != "$prev" ]; then
            apply_profile "$profile"
            prev="$profile"
          fi
        done
      '';

      Restart = "always";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}

