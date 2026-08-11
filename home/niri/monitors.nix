{
  # Mirrors home/hyprland/monitors.nix.
  _children = [
    {
      output = {
        _args = [ "eDP-1" ];
        mode = "1920x1200@60";
        position._props = {
          x = 0;
          y = 0;
        };
        scale = 1.0;
      };
    }
    {
      output = {
        _args = [ "HDMI-A-1" ];
        mode = "1920x1080@60";
        position._props = {
          x = 1920;
          y = 0;
        };
        scale = 1.0;
      };
    }
  ];
}
