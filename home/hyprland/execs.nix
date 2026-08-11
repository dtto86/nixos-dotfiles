{ lib, ... }:
let
  commands = [
    "noctalia"
    "hypridle"
    "wl-paste --type text --watch cliphist store"
    "wl-paste --type image --watch cliphist store"
    "udiskie"
  ];

  body = lib.concatMapStrings (cmd: "  hl.exec_cmd(${builtins.toJSON cmd})\n") commands;
in
{
  on = [
    {
      _args = [
        "hyprland.start"
        (lib.generators.mkLuaInline "function()\n${body}end")
      ];
    }
  ];
}
