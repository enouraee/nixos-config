# modules/home/git.nix
# Git configuration
# IMPORTANT: Update userName and userEmail with your own info!
{ ... }:
{
  programs.git = {
    enable = true;

    # TODO: Set your identity!
    userName = "Your Name";           # <-- CHANGE THIS
    userEmail = "you@example.com";    # <-- CHANGE THIS

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;

      # Better diffs
      diff.algorithm = "histogram";

      # Credentials (use system keyring)
      credential.helper = "store";
    };

    # Useful aliases
    aliases = {
      st = "status";
      co = "checkout";
      br = "branch";
      ci = "commit";
      lg = "log --oneline --graph --decorate -10";
      last = "log -1 HEAD";
      unstage = "reset HEAD --";
    };
  };
}
