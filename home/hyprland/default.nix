{ config, pkgs, lib, ... }:

let
  monitors = import ./monitors.nix;
  appearance = import ./appearance.nix;
  binds = import ./binds.nix { inherit lib; };
  env = import ./env.nix;
  execs = import ./execs.nix { inherit lib; };
  input = import ./input.nix;
  rules = import ./rules.nix;
  extraConfigs = import ./extra-configs.nix;
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    # Hyprland >=0.55 deprecated hyprlang (hyprland.conf) in favor of Lua
    # (hyprland.lua); hyprlang support is slated for removal after 1-2
    # releases. home-manager's `settings` schema renders differently for
    # each backend (flat key/value pairs vs `hl.<name>(...)` calls), which
    # is why the *.nix files under this directory look structurally
    # different from a typical hyprlang-era Home Manager config.
    configType = "lua";

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

