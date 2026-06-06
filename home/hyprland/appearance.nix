{
  general = {
    gaps_in = 3;
    gaps_out = 5;

    border_size = 1;

    resize_on_border = true;

    allow_tearing = false;

    layout = "dwindle";

    "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
    "col.inactive_border" = "rgba(595959aa)";
  };

  decoration = {
    rounding = 5;

    active_opacity = 0.95;
    inactive_opacity = 0.6;

    blur = {
      enabled = true;
      size = 3;
      passes = 1;
      vibrancy = 0.1696;
    };
  };
  animations = {
    enabled = true;
    bezier = ["myBezier, 0.05, 0.9, 0.1, 1.05"];

    animation = [
      "windows, 1, 7, myBezier"
      "windowsOut, 1, 7, default, popin 80%"
      "border, 1, 10, default"
      "borderangle, 1, 8, default"
      "fade, 1, 3, default"
      "workspaces, 1, 6, default"
    ];
  };
}

