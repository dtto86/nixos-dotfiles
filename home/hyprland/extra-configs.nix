{
  config = {
    misc = {
      force_default_wallpaper = 1;
      disable_hyprland_logo = true;
    };
    binds = {
      workspace_back_and_forth = true;
    };
    debug = {
      disable_logs = false;
    };
    dwindle = {
      preserve_split = true;
    };
    # master = {
    #   new_status = "master";
    # };
    scrolling = {
      # Default (true) auto-stretches a lone column to fill the screen, but
      # doesn't reliably shrink it back to column_width once a second column
      # is opened alongside it -- the column gets stuck oversized. Disable it
      # and use SUPER+F (real fullscreen) when a single window should fill
      # the screen instead.
      fullscreen_on_one_column = false;
    };
  };
}
