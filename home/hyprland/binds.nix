{
  "$mainMod" = "SUPER";
  # Set programs that you use
  "$terminal" = "kitty";
  "$fileManager" = "thunar";
  "$menu" = "rofi -show drun";
  "$browser" = "google-chrome-stable";
  "$note" = "obsidian";

  bind = [
    "$mainMod, RETURN, exec, $terminal"
    "$mainMod SHIFT, RETURN, exec, $terminal --class kittyFloating"
    "$mainMod, Q, killactive"
    "$mainMod, F, fullscreen"
    "$mainMod, M, exit"
    "$mainMod, B, exec, $browser"
    "$mainMod, R, exec, $menu"
    "$mainMod SHIFT, L, exec, loginctl lock-session"
    "$mainMod, W, togglefloating"
    "$mainMod, E, exec, $fileManager"
    "$mainMod, V, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy"
    ", PRINT, exec, hyprshot -m window"
    ", XF86SelectiveScreenshot, exec, hyprshot -m region"
    "$mainMod, N, exec, $note"
    "$mainMod, H, movefocus, l"
    "$mainMod, L, movefocus, r"
    "$mainMod, K, movefocus, u"
    "$mainMod, J, movefocus, d"
    "$mainMod, 1, workspace, 1"
    "$mainMod, 2, workspace, 2"
    "$mainMod, 3, workspace, 3"
    "$mainMod, 4, workspace, 4"
    "$mainMod, 5, workspace, 5"
    "$mainMod, 6, workspace, 6"
    "$mainMod, 7, workspace, 7"
    "$mainMod, 8, workspace, 8"
    "$mainMod, 9, workspace, 9"
    "$mainMod, 0, workspace, 10"
    "$mainMod SHIFT, 1, movetoworkspace, 1"
    "$mainMod SHIFT, 2, movetoworkspace, 2"
    "$mainMod SHIFT, 3, movetoworkspace, 3"
    "$mainMod SHIFT, 4, movetoworkspace, 4"
    "$mainMod SHIFT, 5, movetoworkspace, 5"
    "$mainMod SHIFT, 6, movetoworkspace, 6"
    "$mainMod SHIFT, 7, movetoworkspace, 7"
    "$mainMod SHIFT, 8, movetoworkspace, 8"
    "$mainMod SHIFT, 9, movetoworkspace, 9"
    "$mainMod SHIFT, 0, movetoworkspace, 10"
    "$mainMod, S, togglespecialworkspace, magic"
    "$mainMod SHIFT, S, movetoworkspace, special:magic"
    "$mainMod, mouse_down, workspace, e+1"
    "$mainMod, mouse_up, workspace, e-1"
  ];

  bindel = [
      ",XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
      ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ",XF86MonBrightnessUp, exec, brightnessctl s 10%+"
      ",XF86MonBrightnessDown, exec, brightnessctl s 10%-"
    ];

  bindl = [
    ", XF86AudioNext, exec, playerctl next"
    ", XF86AudioPause, exec, playerctl play-pause"
  ];

  bindm = [
    "$mainMod, mouse:272, movewindow"
    "$mainMod, mouse:273, resizewindow"
  ];
}

