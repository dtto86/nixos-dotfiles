{ lib, ... }:
let
  mainMod = "SUPER";
  # Set programs that you use
  terminal = "kitty";
  fileManager = "thunar";
  menu = "rofi -show drun";
  browser = "google-chrome-stable";
  note = "obsidian";

  inline = lib.generators.mkLuaInline;
  exec = cmd: inline "hl.dsp.exec_cmd(${builtins.toJSON cmd})";

  mkBind = trigger: dispatcher: { _args = [ trigger dispatcher ]; };
  mkBindF = trigger: dispatcher: flags: { _args = [ trigger dispatcher flags ]; };
in
{
  bind = [
    (mkBind "${mainMod} + RETURN" (exec terminal))
    (mkBind "${mainMod} + SHIFT + RETURN" (exec "${terminal} --class kittyFloating"))
    (mkBind "${mainMod} + Q" (inline "hl.dsp.window.close()"))
    (mkBind "${mainMod} + F" (inline "hl.dsp.window.fullscreen({ mode = \"fullscreen\", action = \"toggle\" })"))
    # withUWSM is enabled system-wide; the wiki recommends `uwsm stop` over the
    # `exit` dispatcher so the session shuts down in the correct order.
    (mkBind "${mainMod} + M" (exec "uwsm stop"))
    # Opens the same session/power panel as clicking the "session" bar widget.
    (mkBind "${mainMod} + ESCAPE" (exec "noctalia msg panel-toggle session"))
    (mkBind "${mainMod} + B" (exec browser))
    (mkBind "${mainMod} + R" (exec menu))
    (mkBind "${mainMod} + SHIFT + L" (exec "loginctl lock-session"))
    (mkBind "${mainMod} + W" (inline "hl.dsp.window.float({ action = \"toggle\" })"))
    (mkBind "${mainMod} + E" (exec fileManager))
    (mkBind "${mainMod} + V" (exec "cliphist list | rofi -dmenu | cliphist decode | wl-copy"))
    (mkBind "PRINT" (exec "hyprshot -m window -o ~/screenshots"))
    (mkBind "XF86SelectiveScreenshot" (exec "hyprshot -m region -o ~/screenshots"))
    (mkBind "${mainMod} + N" (exec note))

    (mkBind "${mainMod} + H" (inline "hl.dsp.focus({ direction = \"left\" })"))
    (mkBind "${mainMod} + L" (inline "hl.dsp.focus({ direction = \"right\" })"))
    (mkBind "${mainMod} + K" (inline "hl.dsp.focus({ direction = \"up\" })"))
    (mkBind "${mainMod} + J" (inline "hl.dsp.focus({ direction = \"down\" })"))

    (mkBind "${mainMod} + 1" (inline "hl.dsp.focus({ workspace = 1 })"))
    (mkBind "${mainMod} + 2" (inline "hl.dsp.focus({ workspace = 2 })"))
    (mkBind "${mainMod} + 3" (inline "hl.dsp.focus({ workspace = 3 })"))
    (mkBind "${mainMod} + 4" (inline "hl.dsp.focus({ workspace = 4 })"))
    (mkBind "${mainMod} + 5" (inline "hl.dsp.focus({ workspace = 5 })"))
    (mkBind "${mainMod} + 6" (inline "hl.dsp.focus({ workspace = 6 })"))
    (mkBind "${mainMod} + 7" (inline "hl.dsp.focus({ workspace = 7 })"))
    (mkBind "${mainMod} + 8" (inline "hl.dsp.focus({ workspace = 8 })"))
    (mkBind "${mainMod} + 9" (inline "hl.dsp.focus({ workspace = 9 })"))
    (mkBind "${mainMod} + 0" (inline "hl.dsp.focus({ workspace = 10 })"))

    (mkBind "${mainMod} + SHIFT + 1" (inline "hl.dsp.window.move({ workspace = 1 })"))
    (mkBind "${mainMod} + SHIFT + 2" (inline "hl.dsp.window.move({ workspace = 2 })"))
    (mkBind "${mainMod} + SHIFT + 3" (inline "hl.dsp.window.move({ workspace = 3 })"))
    (mkBind "${mainMod} + SHIFT + 4" (inline "hl.dsp.window.move({ workspace = 4 })"))
    (mkBind "${mainMod} + SHIFT + 5" (inline "hl.dsp.window.move({ workspace = 5 })"))
    (mkBind "${mainMod} + SHIFT + 6" (inline "hl.dsp.window.move({ workspace = 6 })"))
    (mkBind "${mainMod} + SHIFT + 7" (inline "hl.dsp.window.move({ workspace = 7 })"))
    (mkBind "${mainMod} + SHIFT + 8" (inline "hl.dsp.window.move({ workspace = 8 })"))
    (mkBind "${mainMod} + SHIFT + 9" (inline "hl.dsp.window.move({ workspace = 9 })"))
    (mkBind "${mainMod} + SHIFT + 0" (inline "hl.dsp.window.move({ workspace = 10 })"))

    (mkBind "${mainMod} + S" (inline "hl.dsp.workspace.toggle_special(\"magic\")"))
    (mkBind "${mainMod} + SHIFT + S" (inline "hl.dsp.window.move({ workspace = \"special:magic\" })"))

    (mkBind "${mainMod} + mouse_down" (inline "hl.dsp.focus({ workspace = \"e+1\" })"))
    (mkBind "${mainMod} + mouse_up" (inline "hl.dsp.focus({ workspace = \"e-1\" })"))

    (mkBindF "XF86AudioRaiseVolume" (exec "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+") { locked = true; repeating = true; })
    (mkBindF "XF86AudioLowerVolume" (exec "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-") { locked = true; repeating = true; })
    (mkBindF "XF86AudioMute" (exec "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle") { locked = true; repeating = true; })
    (mkBindF "XF86AudioMicMute" (exec "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle") { locked = true; repeating = true; })
    (mkBindF "XF86MonBrightnessUp" (exec "brightnessctl s 10%+") { locked = true; repeating = true; })
    (mkBindF "XF86MonBrightnessDown" (exec "brightnessctl s 10%-") { locked = true; repeating = true; })

    (mkBindF "XF86AudioNext" (exec "playerctl next") { locked = true; })
    (mkBindF "XF86AudioPause" (exec "playerctl play-pause") { locked = true; })

    (mkBindF "${mainMod} + mouse:272" (inline "hl.dsp.window.drag()") { mouse = true; })
    (mkBindF "${mainMod} + mouse:273" (inline "hl.dsp.window.resize()") { mouse = true; })

    # scrolling layout: move/swap columns, cycle column width, promote a
    # window into its own column.
    (mkBind "${mainMod} + COMMA" (inline "hl.dsp.layout(\"move -col\")"))
    (mkBind "${mainMod} + PERIOD" (inline "hl.dsp.layout(\"move +col\")"))
    (mkBind "${mainMod} + SHIFT + COMMA" (inline "hl.dsp.layout(\"swapcol l\")"))
    (mkBind "${mainMod} + SHIFT + PERIOD" (inline "hl.dsp.layout(\"swapcol r\")"))
    (mkBind "${mainMod} + MINUS" (inline "hl.dsp.layout(\"colresize -conf\")"))
    (mkBind "${mainMod} + EQUAL" (inline "hl.dsp.layout(\"colresize +conf\")"))
    (mkBind "${mainMod} + P" (inline "hl.dsp.layout(\"promote\")"))

    # scrolling layout: snap the active column into view, or expand it into
    # remaining free space.
    (mkBind "${mainMod} + HOME" (inline "hl.dsp.layout(\"fit tobeg\")"))
    (mkBind "${mainMod} + END" (inline "hl.dsp.layout(\"fit toend\")"))
    (mkBind "${mainMod} + CTRL + F" (inline "hl.dsp.layout(\"fit_into_view\")"))
    (mkBind "${mainMod} + SHIFT + F" (inline "hl.dsp.layout(\"fit expand\")"))

    # scrolling layout: move windows in/out of shared columns. Brackets
    # mirror the direction: [ pulls the previous column's window in,
    # ] pushes the current window out to its own column.
    (mkBind "${mainMod} + BRACKETLEFT" (inline "hl.dsp.layout(\"consume\")"))
    (mkBind "${mainMod} + BRACKETRIGHT" (inline "hl.dsp.layout(\"expel\")"))
    (mkBind "${mainMod} + SHIFT + BRACKETLEFT" (inline "hl.dsp.layout(\"consume_or_expel prev\")"))
    (mkBind "${mainMod} + SHIFT + BRACKETRIGHT" (inline "hl.dsp.layout(\"consume_or_expel next\")"))
  ];
}
