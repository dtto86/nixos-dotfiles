{ pkgs, ... }:

{
  programs.rofi = {
    enable = true;

    # package = pkgs.rofi;

    font = "JetBrains Mono NL 12";
    theme = ../../config/rofi/simple-tokyonight.rasi;
  };
}

