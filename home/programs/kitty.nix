{ pkgs, ... }:

{
  programs.kitty = {
    enable = true;

    settings = {
      confirm_os_window_close = 0;
      enable_audio_bell = false;
      fontFamily = "JetBrainsMonoNL Nerd Font";
      fontSize = 12.5;
      boldFont = "auto";
      italicFont = "auto";
      boldItalicFont = "auto";
    };
  };
}

