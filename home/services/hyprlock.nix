{ pkgs, ... }:

{
  programs.hyprlock = {
    enable = true;

    settings = {
      background = [
        {
          monitor = "eDP-1";
          path = "~/.config/hypr/Wallpapers/pexels-lanophotography-147635.jpg";
          blur_passes = 2;
          brightness = 0.5;
        }
      ];

      general = {
        hide_cursor = false;
        disable_loading_bar = true;
      };

      input-field = [
        {
          monitor = "eDP-1";
          size = "250, 60";
          outline_thickness = 2;
          dots_size = 0.2;
          dots_spacing = 0.35;
          fade_on_empty = true;
          rounding = -1;
          hide_input = false;
          position = "0, -200";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}

