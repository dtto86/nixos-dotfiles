{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Pravin Salgaonkar";
        email = "pravinsalg@gmail.com";
      };
      core.editor = "nvim";
      init.defaultBranch = "main";
      pull.rebase = false;
    };
  };
}

