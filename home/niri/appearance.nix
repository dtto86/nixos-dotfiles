{
  # Mirrors home/hyprland/appearance.nix. niri draws one always-visible
  # "border" (like hyprland's border) rather than a focus-ring that only
  # shows on the active window, so the focus ring is disabled in favor of it.
  layout = {
    gaps = 5;

    "focus-ring".off = { };

    border = {
      width = 1;
      "active-gradient"._props = {
        from = "#33ccffee";
        to = "#00ff99ee";
        angle = 45;
      };
      "inactive-color" = "#595959aa";
    };
  };

  "prefer-no-csd" = { };

  # niri's compositor-wide blur (26.04+); rounding lives in rules.nix as a
  # window-rule (geometry-corner-radius + clip-to-geometry), since niri has
  # no global "rounding" setting.
  blur."passes" = 1;

  animations = {
    "window-open" = {
      "duration-ms" = 150;
      curve._args = [ "cubic-bezier" 0.05 0.9 0.1 1.05 ];
    };
    "window-close" = {
      "duration-ms" = 150;
      curve._args = [ "ease-out-quad" ];
    };
  };
}
