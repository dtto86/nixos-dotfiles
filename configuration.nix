{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot = {
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

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
 
  system.stateVersion = "25.11";
}

