{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    jq
    gcc
    pamixer
    blueman
    neovim
    grim
    slurp
    wl-clipboard
    playerctl
    networkmanagerapplet
  ];
}

