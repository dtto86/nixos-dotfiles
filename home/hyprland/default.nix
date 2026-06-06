{ config, pkgs, lib, ... }:

let
  monitors = import ./monitors.nix;
  appearance = import ./appearance.nix;
  binds = import ./binds.nix;
  env = import ./env.nix;
  execs = import ./execs.nix;
  input = import ./input.nix;
  rules = import ./rules.nix;
  extraConfigs = import ./extra-configs.nix;
in
{
  wayland.windowManager.hyprland = {
    enable = true;

    settings = lib.mkMerge [
      monitors
      appearance
      binds
      env
      execs
      input
      # rules
      extraConfigs
    ];
  };
}

