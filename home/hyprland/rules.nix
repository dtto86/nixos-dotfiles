{
  # windowrule = [
  #   # "float,^(kittyFloating)$"
  #   # "float,class:^(kittyFloating)$"
  #   # "suppressevent maximize,class:.*"
  # ];

  # windowrulev2 = [
  #   "float,class:^(kittyFloating)$"
  #   "suppressevent maximize,class:.*"
  #   "noinitialfocus,class:^$,title:^$"
  # ];
  window_rule = [
    {
      name = "float-wezterm-floating";
      match.class = "^(weztermFloating)$";
      float = true;
    }
    {
      name = "suppress-maximize";
      match.class = ".*";
      suppress_event = "maximize";
    }
    {
      name = "no-initial-focus";
      match = {
        class = "^$";
        title = "^$";
      };
      no_focus = true;
    }
  ];
}
