{ pkgs, ... }:

{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  security.polkit.enable = true;

  # hyprlock is wired up via Home Manager, which doesn't set up its PAM stack;
  # without this hypridle/hyprlock log "Pam module /etc/pam.d/hyprlock does not
  # exist! Falling back to /etc/pam.d/su" and auth goes through the wrong stack.
  security.pam.services.hyprlock = { };

  services.libinput.enable = true;

  # Thunar thumbnails: tumbler generates them, gvfs backs the trash/mount
  # machinery Thunar expects, xfconf persists the "show thumbnails" setting.
  services.gvfs.enable = true;
  services.tumbler.enable = true;
  programs.xfconf.enable = true;

  xdg.portal = {
    enable = true;

    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
    ];
  };
}

