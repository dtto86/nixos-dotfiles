{
  # Mirrors home/hyprland/rules.nix and the rounding/blur/opacity settings
  # from home/hyprland/appearance.nix (niri expresses these as window rules
  # rather than global decoration options).
  _children = [
    # Hyprland's decoration.rounding = 5 and decoration.blur.enabled = true.
    {
      "window-rule" = {
        "geometry-corner-radius" = 5;
        "clip-to-geometry" = true;
        "background-effect"."blur" = true;
      };
    }

    # Hyprland's decoration.active_opacity / inactive_opacity.
    {
      "window-rule" = {
        match._props."is-active" = true;
        opacity = 1.0;
      };
    }
    {
      "window-rule" = {
        match._props."is-active" = false;
        opacity = 0.6;
      };
    }

    # Hyprland's windowrule float,class:^(kittyFloating)$.
    {
      "window-rule" = {
        match._props."app-id" = "^kittyFloating$";
        "open-floating" = true;
      };
    }
  ];
}
