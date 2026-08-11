{ pkgs, ... }:

let
  font = "JetBrainsMono Nerd Font";

  # Tokyo Night Moon palette, matching noctalia's community_palette.
  bgDark = "30, 32, 48";
  fg = "200, 211, 245";
  green = "195, 232, 141";
  blue = "130, 170, 255";
  red = "255, 117, 127";
  comment = "99, 109, 166";
in
{
  programs.hyprlock = {
    enable = true;

    settings = {
      background = [
        {
          monitor = "eDP-1";
          path = "~/.config/hypr/Wallpapers/pexels-lanophotography-147635.jpg";
          blur_passes = 3;
          blur_size = 4;
          contrast = 0.9;
          brightness = 0.35;
          vibrancy = 0.15;
        }
      ];

      general = {
        hide_cursor = false;
        disable_loading_bar = true;
        grace = 0;
      };

      input-field = [
        {
          monitor = "eDP-1";
          size = "300, 55";
          outline_thickness = 2;
          rounding = 0;
          dots_size = 0.2;
          dots_spacing = 0.35;
          fade_on_empty = true;
          hide_input = false;
          font_family = font;
          outer_color = "rgb(${green})";
          inner_color = "rgba(${bgDark}, 0.6)";
          font_color = "rgb(${fg})";
          check_color = "rgb(${blue})";
          fail_color = "rgb(${red})";
          fail_text = "<span foreground='#ff757f'>bash: unlock: permission denied</span>";
          placeholder_text = "<span foreground='#636da6'>\$ sudo unlock</span>";
          position = "0, -160";
          halign = "center";
          valign = "center";
        }
      ];

      label = [
        # user@host prompt, fetched dynamically, above the input field
        {
          monitor = "eDP-1";
          text = "cmd[update:3600000] echo \"<span foreground='#c3e88d'>$(whoami)</span><span foreground='#636da6'>@</span><span foreground='#82aaff'>$(uname -n)</span><span foreground='#c8d3f5'>:~$</span>\"";
          font_family = font;
          font_size = 20;
          color = "rgb(${fg})";
          position = "0, -100";
          halign = "center";
          valign = "center";
        }

        # big terminal-style clock
        {
          monitor = "eDP-1";
          text = "cmd[update:1000] date +'%H:%M:%S'";
          font_family = font;
          font_size = 100;
          color = "rgb(${fg})";
          position = "0, 60";
          halign = "center";
          valign = "center";
        }

        # date, styled like a shell comment
        {
          monitor = "eDP-1";
          text = "cmd[update:60000] date +'# %A, %d %B %Y'";
          font_family = font;
          font_size = 20;
          color = "rgb(${comment})";
          position = "0, -30";
          halign = "center";
          valign = "center";
        }

        # footer: kernel + uptime, like a neofetch status line
        {
          monitor = "eDP-1";
          text = "cmd[update:5000] echo \"$(uname -sr) · $(uptime -p)\"";
          font_family = font;
          font_size = 14;
          color = "rgb(${comment})";
          position = "0, 40";
          halign = "center";
          valign = "bottom";
        }
      ];
    };
  };
}
