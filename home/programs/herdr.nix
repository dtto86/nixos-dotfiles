{ ... }:

{
  programs.herdr = {
    enable = true;

    settings = {
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
