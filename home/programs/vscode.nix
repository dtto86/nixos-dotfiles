{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        enkia.tokyo-night
        jnoortheen.nix-ide
      ];
      userSettings = {
        "workbench.colorTheme" = "Tokyo Night Moon";
        "editor.fontFamily" = "'JetBrainsMono Nerd Font', 'monospace'";
        "editor.fontSize" = 14;
        "editor.formatOnSave" = true;
        "editor.tabSize" = 2;
        "editor.insertSpaces" = true;
        "files.trimTrailingWhitespace" = true;
        "telemetry.telemetryLevel" = "off";
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "${pkgs.nixd}/bin/nixd";
      };
    };
  };
}
