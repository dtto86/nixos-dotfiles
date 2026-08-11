{
  config = {
    general = {
      gaps_in = 3;
      gaps_out = 5;

      border_size = 1;

      resize_on_border = true;

      allow_tearing = false;

      layout = "scrolling";

      col = {
        active_border = {
          colors = [ "rgba(33ccffee)" "rgba(00ff99ee)" ];
          angle = 45;
        };
        inactive_border = "rgba(595959aa)";
      };
    };

    decoration = {
      rounding = 5;

      active_opacity = 1.0;
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
    };
  };

  curve = [
    {
      _args = [
        "myBezier"
        {
          type = "bezier";
          points = [
            [ 0.05 0.9 ]
            [ 0.1 1.05 ]
          ];
        }
      ];
    }
  ];

  animation = [
    {
      leaf = "windows";
      enabled = true;
      speed = 7;
      bezier = "myBezier";
    }
    {
      leaf = "windowsOut";
      enabled = true;
      speed = 7;
      bezier = "default";
      style = "popin 80%";
    }
    {
      leaf = "border";
      enabled = true;
      speed = 10;
      bezier = "default";
    }
    {
      leaf = "borderangle";
      enabled = true;
      speed = 8;
      bezier = "default";
    }
    {
      leaf = "fade";
      enabled = true;
      speed = 3;
      bezier = "default";
    }
    {
      leaf = "workspaces";
      enabled = true;
      speed = 6;
      bezier = "default";
    }
  ];
}
