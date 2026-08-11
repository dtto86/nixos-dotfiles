{
  # Mirrors home/hyprland/execs.nix (exec-once).
  _children = [
    { "spawn-at-startup"._args = [ "noctalia" ]; }
    { "spawn-at-startup"._args = [ "hypridle" ]; }
    {
      "spawn-at-startup"._args = [
        "wl-paste"
        "--type"
        "text"
        "--watch"
        "cliphist"
        "store"
      ];
    }
    {
      "spawn-at-startup"._args = [
        "wl-paste"
        "--type"
        "image"
        "--watch"
        "cliphist"
        "store"
      ];
    }
    { "spawn-at-startup"._args = [ "udiskie" ]; }
  ];
}
