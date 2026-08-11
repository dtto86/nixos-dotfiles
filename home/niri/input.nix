{
  # Mirrors home/hyprland/input.nix.
  input = {
    keyboard.xkb.layout = "us";

    # Hyprland's follow_mouse = 1.
    "focus-follows-mouse" = { };

    # Hyprland's binds.workspace_back_and_forth.
    "workspace-auto-back-and-forth" = { };

    touchpad = {
      "natural-scroll" = { };
      "scroll-factor" = 0.3;
    };

    # Hyprland's sensitivity = 0 (neutral pointer acceleration).
    mouse."accel-speed" = 0.0;

    # Hyprland's 3-finger horizontal swipe to switch workspaces has no
    # configurable equivalent in niri: touchpad workspace gestures are
    # built in (4-finger swipe) and not adjustable.
  };
}
