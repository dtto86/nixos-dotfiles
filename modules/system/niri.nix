{ pkgs, ... }:

{
  programs.niri.enable = true;

  security.polkit.enable = true;

  services.libinput.enable = true;

  xdg.portal = {
    enable = true;

    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };
}

