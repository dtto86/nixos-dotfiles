{ ... }:

{
  programs.herdr = {
    enable = true;

    settings = {
      # herdr tries to write this into config.toml after first-run onboarding,
      # which fails because Home Manager makes that file a read-only store symlink.
      onboarding = false;

      keys = {
        # Mirror the tmux prefix set in ./tmux.nix (M-f).
        prefix = "alt+f";

        # Mirror tmux's split-window bindings: `|` for a side-by-side split,
        # `-` for a stacked split. split_horizontal already defaults to
        # "prefix+minus", so only split_vertical needs remapping.
        split_vertical = "prefix+|";
      };
    };
  };
}
