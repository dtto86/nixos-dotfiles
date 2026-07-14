{
  binds = {
    "Mod+Return".action.spawn = "kitty";

    "Mod+R".action.spawn =
      [ "rofi" "-show" "drun" ];

    "Mod+E".action.spawn =
      [ "thunar" ];

    "Mod+B".action.spawn =
      [ "google-chrome-stable" ];

    "Mod+Q".action.close-window = { };

    "Mod+F".action.fullscreen-window = { };
  };
}

