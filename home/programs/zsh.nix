{ _, ... }:

{
  programs.zsh = {
    enable = true;

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    initContent = ''
      bindkey '^[[H' beginning-of-line
      bindkey '^[[F' end-of-line
    '';
  };
}

