{
  # Mirrors home/hyprland/env.nix.
  environment = {
    "QT_QPA_PLATFORM" = "wayland";
    "QT_QPA_PLATFORMTHEME" = "qt6ct";
  };

  # niri's cursor block sets XCURSOR_THEME/XCURSOR_SIZE itself and applies
  # them to niri's own rendering, standing in for hyprland's
  # XCURSOR_SIZE/HYPRCURSOR_SIZE/HYPRCURSOR_THEME env vars.
  cursor = {
    "xcursor-theme" = "Nordzy-Cursors";
    "xcursor-size" = 24;
  };

  # Mirrors hyprshot's output directory (~/screenshots, created by
  # home/default.nix's home.file."screenshots/.keep").
  "screenshot-path" = "~/screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";
}
