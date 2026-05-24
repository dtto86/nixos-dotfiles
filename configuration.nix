{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot = {
    kernelModules = [ "thinkpad_acpi" ];
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 3;
      };
      efi = {
        canTouchEfiVariables = true;
      };
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };

  networking = {
    hostName = "my-pc";
    networkmanager = {
      enable = true;
    };
  };

  time.timeZone = "Asia/Kolkata";

  users.users.pravin = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
  };

  services = {
    xserver = {
      enable = true;
    };
    displayManager = {
      gdm = {
        enable = true;
      };
    };
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
      };
      pulse = {
        enable = true;
      };
    };
    btrfs = {
      autoScrub = {
        enable = true;
        interval = "weekly";
        fileSystems = [ "/" ];
      };
    };
    blueman = {
      enable = true;
    };
    power-profiles-daemon = {
      enable = true;
    };
    upower = {
      enable = true;
    };
    libinput = {
      enable = true;
    };
    acpid = {
      enable = true;
      handlers.micmute = {
        event = "button/micmute.*";
        action = ''
          export XDG_RUNTIME_DIR=/run/user/1000
          # ${pkgs.swayosd}/bin/swayosd-client --input-volume mute-toggle
          ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

          # runuser -u pravin -- env XDG_RUNTIME_DIR=/run/user/1000 WAYLAND_DISPLAY=wayland-1 ${pkgs.swayosd}/bin/swayosd-client --input-volume mute-toggle
          ${pkgs.systemd}/bin/runuser -u pravin -- \
            ${pkgs.systemd}/bin/systemd-run --user \
            ${pkgs.swayosd}/bin/swayosd-client --input-volume mute-toggle

          STATE=$(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -o MUTED)

          if [ "$STATE" = "MUTED" ]; then
            # ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 0
            echo 0 > /sys/class/leds/platform::micmute/brightness
          else
            # ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 1
            echo 1 > /sys/class/leds/platform::micmute/brightness
          fi

        '';
      };
    };
  };

  programs = {
    hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };
    zsh = {
      enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    git curl wget kdePackages.polkit-kde-agent-1 pulseaudio pamixer blueman gcc neovim
  ];

  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "hyprland";
    XDG_SESSION_TYPE = "wayland";
  };

  security.polkit.enable = true;

  hardware.bluetooth = {
    enable = true;
    settings = {
      General = {
        ControllerMode = "dual";
        Experimental = true;
      };
      Policy = {
        AutoEnable = "true";
      };
    };
  };

  hardware.enableAllFirmware = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
 
  system.stateVersion = "25.11";
}

