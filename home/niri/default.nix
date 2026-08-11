{ lib, ... }:

let
  monitors = import ./monitors.nix;
  input = import ./input.nix;
  binds = import ./binds.nix;
  startup = import ./startup.nix;
  appearance = import ./appearance.nix;
  rules = import ./rules.nix;
  env = import ./env.nix;
in
{
  # Home Manager's niri module lives under `wayland.windowManager.niri`
  # (mirrors `wayland.windowManager.hyprland`), not `programs.niri`.
  wayland.windowManager.niri = {
    # enable = true;

    settings = lib.mkMerge [
      monitors
      input
      binds
      startup
      appearance
      rules
      env
    ];
  };
}
