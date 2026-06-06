{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;

    prefix = "M-f";

    terminal = "\${TERM}";

    baseIndex = 1;

    keyMode = "emacs";

    mouse = true;

    historyLimit = 10000;

    aggressiveResize = false;

    escapeTime = 10;

    shell = "${pkgs.zsh}/bin/zsh";

    plugins = with pkgs.tmuxPlugins; [
      sensible

      {
        plugin = minimal-tmux-status;
        extraConfig = ''
          set -g @minimal-tmux-status "top"
        '';
      }

      # tpm
    ];

    extraConfig = ''
      # Pane indexing
      setw -g pane-base-index 1

      # Clipboard
      set -g set-clipboard on

      # Renumber windows
      set -g renumber-windows on

      # Focus events
      set -g focus-events off

      # Pane splitting
      unbind-key -T prefix %
      unbind-key -T prefix '"'

      bind-key | split-window -h
      bind-key - split-window -v

      # Vim-style pane navigation
      bind -r h select-pane -L
      bind -r j select-pane -D
      bind -r k select-pane -U
      bind -r l select-pane -R

      # Active pane border
      set -g pane-active-border-style "fg=brightblack,bg=default"

      # TPM bootstrap
      # run '~/.config/tmux/plugins/tpm/tpm'
    '';
  };
}

