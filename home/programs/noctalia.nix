{ pkgs, inputs, flakePath, ... }:

{
  imports = [
    inputs.noctalia-shell.homeModules.default
  ];

  # Declarative overlay for noctalia v5's ~/.config/noctalia/config.toml.
  # GUI-driven state (bar widget positions, desktop widgets, last-used
  # wallpaper per monitor, etc.) lives in ~/.local/state/noctalia and is not
  # managed here — only the stable preferences below are.
  programs.noctalia = {
    enable = true;
    package = inputs.noctalia-shell.packages.${pkgs.stdenv.hostPlatform.system}.default;
    settings = {
      shell = {
        font_family = "JetBrainsMono NF";
        lang = "en";
        settings_show_advanced = true;
        app_icon_colorize = true;
        app_icon_color = "primary";

        panel = {
          transparency_mode = "glass";
          control_center_placement = "centered";
          session_placement = "centered";
          wallpaper_placement = "centered";
        };
      };

      theme = {
        mode = "dark";
        source = "community";
        builtin = "Noctalia";
        community_palette = "Tokyo Night Moon";
        wallpaper_scheme = "muted";
      };

      wallpaper = {
        directory = "${flakePath}/config/hypr/Wallpapers";
        transition_on_startup = true;

        automation.enabled = false;
      };

      bar.default = {
        start = [ "launcher" "workspaces" "active_window" ];
        end = [
          "media"
          "tray"
          "clipboard"
          "cpu"
          "ram"
          "temp"
          "network"
          "bluetooth"
          "volume"
          "brightness"
          "battery"
          "control-center"
          "notifications"
          "session"
        ];
        margin_edge = 0;
        margin_ends = 0;
        padding = 5;
        radius = 0;
      };

      widget.media.hide_when_no_media = true;
    };
  };
}
