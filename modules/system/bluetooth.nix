{ _, ... }:

{
  services.blueman.enable = true;

  hardware.bluetooth = {
    enable = true;

    settings = {
      General = {
        ControllerMode = "dual";
        Experimental = true;
      };

      Policy.AutoEnable = "true";
    };
  };
}

