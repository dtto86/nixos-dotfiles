{ pkgs, ... }:

{
  # The XF86AudioMicMute keybind already toggles wpctl mute directly (see
  # home/hyprland/binds.nix and config/niri/binds.kdl), and the LED is kept
  # in sync by modules/system/micmute-led.nix. A handler here on the same
  # ACPI button event would race with that keybind and double-toggle mute.
  services.acpid.enable = true;
}

