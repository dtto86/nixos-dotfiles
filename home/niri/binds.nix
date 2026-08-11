{
  # Mirrors home/hyprland/binds.nix. `Mod` is niri's alias for Super (on a
  # TTY session), matching hyprland's $mainMod.
  #
  # Note: niri does not auto-fill this section with its own defaults once
  # it's set, so only what's listed here is bound.
  binds = {
    "Mod+Return".spawn = [ "kitty" ];
    "Mod+Shift+Return".spawn = [ "kitty" "--class" "kittyFloating" ];

    "Mod+Q"."close-window" = { };
    "Mod+F"."fullscreen-window" = { };
    "Mod+Shift+E".quit = { };

    "Mod+B".spawn = [ "google-chrome-stable" ];
    "Mod+R".spawn = [ "rofi" "-show" "drun" ];
    "Mod+N".spawn = [ "obsidian" ];
    "Mod+E".spawn = [ "thunar" ];

    "Mod+Shift+L".spawn = [ "loginctl" "lock-session" ];

    "Mod+V"."spawn-sh" = "cliphist list | rofi -dmenu | cliphist decode | wl-copy";

    "Mod+W"."toggle-window-floating" = { };

    # hyprshot talks to hyprctl and won't work under niri; niri's own
    # screenshot actions are the equivalent (window vs. interactive select).
    "Print"."screenshot-window" = { };
    "XF86SelectiveScreenshot".screenshot = { };

    "Mod+H"."focus-column-left" = { };
    "Mod+L"."focus-column-right" = { };
    "Mod+K"."focus-window-up" = { };
    "Mod+J"."focus-window-down" = { };

    "Mod+1"."focus-workspace" = 1;
    "Mod+2"."focus-workspace" = 2;
    "Mod+3"."focus-workspace" = 3;
    "Mod+4"."focus-workspace" = 4;
    "Mod+5"."focus-workspace" = 5;
    "Mod+6"."focus-workspace" = 6;
    "Mod+7"."focus-workspace" = 7;
    "Mod+8"."focus-workspace" = 8;
    "Mod+9"."focus-workspace" = 9;
    "Mod+0"."focus-workspace" = 10;

    "Mod+Shift+1"."move-window-to-workspace" = 1;
    "Mod+Shift+2"."move-window-to-workspace" = 2;
    "Mod+Shift+3"."move-window-to-workspace" = 3;
    "Mod+Shift+4"."move-window-to-workspace" = 4;
    "Mod+Shift+5"."move-window-to-workspace" = 5;
    "Mod+Shift+6"."move-window-to-workspace" = 6;
    "Mod+Shift+7"."move-window-to-workspace" = 7;
    "Mod+Shift+8"."move-window-to-workspace" = 8;
    "Mod+Shift+9"."move-window-to-workspace" = 9;
    "Mod+Shift+0"."move-window-to-workspace" = 10;

    # Hyprland's special:magic scratch workspace has no direct niri
    # equivalent (named workspaces don't toggle show/hide the same way).

    "Mod+WheelScrollDown" = {
      _props."cooldown-ms" = 150;
      "focus-workspace-down" = { };
    };
    "Mod+WheelScrollUp" = {
      _props."cooldown-ms" = 150;
      "focus-workspace-up" = { };
    };

    "XF86AudioRaiseVolume" = {
      _props."allow-when-locked" = true;
      spawn = [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+" ];
    };
    "XF86AudioLowerVolume" = {
      _props."allow-when-locked" = true;
      spawn = [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-" ];
    };
    "XF86AudioMute" = {
      _props."allow-when-locked" = true;
      spawn = [ "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle" ];
    };
    "XF86AudioMicMute" = {
      _props."allow-when-locked" = true;
      spawn = [ "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle" ];
    };
    "XF86MonBrightnessUp" = {
      _props."allow-when-locked" = true;
      spawn = [ "brightnessctl" "s" "10%+" ];
    };
    "XF86MonBrightnessDown" = {
      _props."allow-when-locked" = true;
      spawn = [ "brightnessctl" "s" "10%-" ];
    };
    "XF86AudioNext" = {
      _props."allow-when-locked" = true;
      spawn = [ "playerctl" "next" ];
    };
    "XF86AudioPause" = {
      _props."allow-when-locked" = true;
      spawn = [ "playerctl" "play-pause" ];
    };

    # Mod+drag move / Mod+right-drag resize are niri's built-in mouse
    # gestures, equivalent to hyprland's bindm entries; no explicit bind
    # needed unless overriding them.
  };
}
