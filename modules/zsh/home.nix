{ local, ... }:
{
  programs = {
    zsh = {
      enable = true;
      syntaxHighlighting.enable = true;
      autosuggestion.enable = true;

      history = {
        size = 10000;
        save = 10000;
        path = "$HOME/.zsh_history";
        share = true;
        ignoreAllDups = true;
      };

      initContent = ''
        if [ -n "$IN_NIX_SHELL" ]; then
          PS1='%F{#ff66cc}nix-shell%f %~ > '
        else
          PS1='%~ > '
        fi
            bindkey -v
            bindkey '^?' backward-delete-char
            export KEYTIMEOUT=1

            function zle-keymap-select-cursor() {
                case $KEYMAP in
                vicmd) print -n "\e[2 q" ;;
                main|viins) print -n "\e[6 q" ;;
                esac
            }

            function zle-line-init-cursor() {
                print -n "\e[6 q"
            }

            autoload -Uz add-zle-hook-widget
            add-zle-hook-widget zle-keymap-select zle-keymap-select-cursor
            add-zle-hook-widget zle-line-init zle-line-init-cursor

            commitConvention() {
                # keep in sync with the "### Commit messages" heading in docs/COMMANDS.md
                awk '/^### Commit messages/{f=1} f && (/^## / || /^---/){exit} f' \
                ${local.flakeDir}/docs/COMMANDS.md | glow -
         }
      '';

      localVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
        SUDO_EDITOR = "nvim";
      };

      shellAliases = {
        nix-shell = "nix-shell --command zsh";
        ll = "ls -la";
        ls = "ls --color=auto";
        md = "glow";
        wkeys = "wshowkeys -b #00000000 -f #ffffff -s #ff0000 -F 'cascadiacode 12' -t 500 -a bottom -a right -l 600 & disown";
        slupi = "while slurp -b 00000000 -c e67e22bb -s e67e2222  -w 2; do true; done";

        sc-start = "systemctl start";
        sc-stop = "systemctl stop";
        sc-restart = "systemctl restart";
        sc-status = "systemctl status";
        sc-failed = "systemctl --failed";
        sc-log = "journalctl -u";
        sc-logf = "journalctl -fu";

        fetch = "fastfetch --config ~/.config/fastfetch/comp.jsonc";
        fetchnix = "fastfetch --config ~/.config/fastfetch/nix-comp.jsonc";
        fetchnixred = "fastfetch --config ~/.config/fastfetch/nix-red.jsonc";
        fetchnixmon = "fastfetch --config ~/.config/fastfetch/nix-mon.jsonc";
        fetchnixblue = "fastfetch --config ~/.config/fastfetch/nix-blue.jsonc";
        fetchred = "fastfetch --config ~/.config/fastfetch/red.jsonc";
        fetchmon = "fastfetch --config ~/.config/fastfetch/mon.jsonc";
        fetchmin = "fastfetch --config ~/.config/fastfetch/mini.jsonc";
      };
    };
  };
}
