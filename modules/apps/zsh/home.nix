{
  local,
  osConfig,
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkIf osConfig.my.zsh.enable {
    # wl-clipboard is the notch the shell's vi yank/put binds to. It is not a
    # dev tool: keep it here so the binds survive my.dev being switched off.
    home.packages = with pkgs; [
      wl-clipboard
      zsh-system-clipboard
    ];

    programs = {
      zsh = {
        enable = true;
        syntaxHighlighting.enable = true;
        autosuggestion = {
          enable = true;
          strategy = [
            "history"
            "completion"
          ];
        };

        history = {
          size = 10000;
          save = 10000;
          path = "$HOME/.zsh_history";
          share = true;
          ignoreDups = true;
          ignoreAllDups = false;
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

              # vi yank/put -> Wayland clipboard. Sourced by hand (not via
              # programs.zsh.plugins) so it lands after `bindkey -v`: plugins are
              # sourced at priority 900, this initContent runs at 1000.
              # DISPLAY is set by Xwayland, and xclip/xsel are not installed, so
              # the plugin's autodetect would refuse wl-copy without this force.
              export ZSH_SYSTEM_CLIPBOARD_USE_WL_CLIPBOARD=1
              source ${pkgs.zsh-system-clipboard}/share/zsh/zsh-system-clipboard/zsh-system-clipboard.zsh

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
                  # Render the "## Commit messages" section of docs/COMMANDS.md.
                  # ${local.flakeDir} is the repo path substituted by Nix; keep the
                  # awk marker below in sync with that heading text.
                  awk '
                      /^## Commit messages/ { in_section = 1; print; next }   # start at the heading
                      in_section && /^## / { exit }                           # stop at the next section
                      in_section                                              # default action prints the line
                  ' ${local.flakeDir}/docs/COMMANDS.md | glow -
           }

            # --- repo navigation helpers (des* prefix avoids clashing with common
            # commands like `map` / `mod`) ---
            _desmod_pick() {
                  fd . "${local.flakeDir}/modules" --type d --max-depth 2 \
                      | fzf --height 50% --reverse --preview 'tree -C -L 2 {}'
              }
              desmod()  { local d=$(_desmod_pick); [ -n "$d" ] && cd "$d"; }
              desmodv() { local d=$(_desmod_pick); [ -n "$d" ] && nvim "$d"; }
              desmody() { local d=$(_desmod_pick); [ -n "$d" ] && yazi "$d"; }

            # Custom next-word strategy
            _zsh_autosuggest_strategy_history_word() {
                _zsh_autosuggest_strategy_history "$1"
                [[ -z "$suggestion" ]] && return

                local suffix="''${suggestion#$1}"

                if [[ "$suffix" =~ ^([[:space:]]*[^[:space:]]+) ]]; then
                suggestion="$1''${match[1]}"
                else
                unset suggestion
                fi
            }

            # Use the custom strategy (this overrides the Nix option)
            ZSH_AUTOSUGGEST_STRATEGY=(history_word completion)
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
  };
}
