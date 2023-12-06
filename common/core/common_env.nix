{ inputs, outputs, pkgs, ... }: {
  environment = {
    variables = {
      TERMINAL = "${pkgs.alacritty}/bin/alacritty";
      EDITOR = "${pkgs.emacs}/bin/emacsclient -c";
      VISUAL = "$EDITOR";
      GIT_EDITOR = "$EDITOR";
      SUDO_EDITOR = "$EDITOR";
    };
  };
}
