{ pkgs, ... }:

{
  programs.zed-editor = {
    enable = true;
    extraPackages = [ pkgs.nixd pkgs.claude-agent-acp ];
    extensions = [ "tokyo-night" "nix" "vue" "dockerfile" "docker-compose" ];
    userSettings = {
      telemetry = {
        metrics = false;
        diagnostics = false;
      };
      vim_mode = true;
      theme = "Tokyo Night Moon";
      buffer_font_family = "JetBrainsMono Nerd Font";
      ui_font_size = 16;
      buffer_font_size = 15;
      format_on_save = "on";
      relative_line_numbers = true;
      hard_tabs = false;
      tab_size = 2;
      project_panel = {
        dock = "left";
      };
      file_scan_exclusions = [
        "**/.git"
        "**/node_modules"
        "**/cdk.out"
      ];
      lsp = {
        nixd = {
          binary = {
            path = "${pkgs.nixd}/bin/nixd";
          };
        };
      };
      agent_servers = {
        "Claude Code" = {
          type = "custom";
          command = "${pkgs.claude-agent-acp}/bin/claude-agent-acp";
          args = [ ];
          env = { };
        };
      };
    };
  };
}
