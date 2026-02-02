# modules/home/zsh.nix
# Zsh shell with Oh-My-Zsh
{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Oh-My-Zsh configuration
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "sudo"           # Press Esc twice to add sudo
        "history"
        "dirhistory"     # Alt+Left/Right for directory history
        "colored-man-pages"
        "command-not-found"
        "extract"        # `extract` command for any archive
      ];
      theme = "robbyrussell";  # Clean default theme (or use "agnoster", "powerlevel10k", etc.)
    };

    # Initialize completion system
    initExtra = ''
      # Case-insensitive completion
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

      # Colored completion
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}

      # Menu selection
      zstyle ':completion:*' menu select

      # Better history search
      bindkey '^[[A' history-substring-search-up 2>/dev/null || true
      bindkey '^[[B' history-substring-search-down 2>/dev/null || true

      # Edit command in $EDITOR with Ctrl+E
      autoload -Uz edit-command-line
      zle -N edit-command-line
      bindkey '^e' edit-command-line
    '';

    # Aliases
    shellAliases = {
      # Listing
      ls = "ls --color=auto";
      ll = "ls -la";
      la = "ls -a";

      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      # Safety
      rm = "rm -i";
      cp = "cp -i";
      mv = "mv -i";

      # NixOS
      rebuild = "sudo nixos-rebuild switch --flake .#$(hostname)";
      update = "nix flake update";
      garbage = "sudo nix-collect-garbage -d";

      # Git shortcuts (beyond oh-my-zsh)
      gs = "git status";
      gd = "git diff";
      gp = "git push";
      gl = "git log --oneline -10";
    };

    # History configuration
    history = {
      size = 10000;
      save = 10000;
      ignoreDups = true;
      ignoreSpace = true;
      extended = true;
    };
  };

  # Zsh-related packages
  home.packages = with pkgs; [
    zsh-history-substring-search
  ];
}
