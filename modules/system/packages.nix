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
    # mount.ntfs helper for udisks2/udiskie: the in-kernel ntfs3 driver only
    # registers under module alias "fs-ntfs3", but blkid reports NTFS
    # filesystems as type "ntfs", so udisks2's mount -t ntfs can't autoload
    # it without this fallback helper.
    ntfs3g
  ];
}

