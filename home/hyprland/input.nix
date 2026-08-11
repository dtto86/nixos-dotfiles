{
  config = {
    input = {
      kb_layout = "us";

      follow_mouse = 1;

      sensitivity = 0;

      mouse_refocus = false;

      touchpad = {
        natural_scroll = true;
        scroll_factor = 0.3;
      };
    };
  };

  gesture = [
    {
      fingers = 3;
      direction = "horizontal";
      action = "workspace";
    }
  ];
}
