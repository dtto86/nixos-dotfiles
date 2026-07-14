{ lib, ... }:

let
  monitors = import ./monitors.nix;
  input = import ./input.nix;
  binds = import ./binds.nix;
  startup = import ./startup.nix;
  appearance = import ./appearance.nix;
in
{
  programs.niri = {
    # enable = true;

    settings = lib.mkMerge [
      monitors
      input
      binds
      startup
      appearance
    ];
  };
}

