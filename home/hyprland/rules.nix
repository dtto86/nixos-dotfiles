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
      name = "float-kitty-floating";
      match.class = "^(kittyFloating)$";
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
