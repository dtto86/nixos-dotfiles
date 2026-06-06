{ _, ... }:

{
  programs.starship = {
    enable = true;

    settings = {
      add_newline = false;

      format = "$directory$git_branch$git_status$nix_shell$character";

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };

      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
      };

      git_branch = {
        symbol = " ";
      };

      nix_shell = {
        symbol = " ";
      };

      package.disabled = true;

      git_status.disabled = false;
      cmd_duration.min_time = 500;
      hostname.disabled = true;
      username.disabled = true;
    };
  };
}

