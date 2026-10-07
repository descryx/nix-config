{ pkgs, ... }:
{
  home.packages = [ pkgs.tmux ];

  programs.tmux = {
    enable = true;
    terminal = "tmux-256color"; # what tmux tells apps the terminal is
    escapeTime = 0; # kills the Esc-key lag in nvim
    baseIndex = 1; # windows/panes start at 1, not 0 (matches your keyboard)
    mouse = true;
    keyMode = "vi";
    historyLimit = 10000;

    extraConfig = ''
      set -ag terminal-overrides ",xterm-ghostty:RGB"
      set -g focus-events on
      set -g renumber-windows on

      unbind C-b
      set -g prefix C-a
      bind C-a send-prefix
      bind r source-file ~/.config/tmux/tmux.conf \; display "config reloaded"
      bind | split-window -h
      bind - split-window -v
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi y send -X copy-pipe-and-cancel "wl-copy"

      # transparent bar, white text, window list only
      set -g status-style "bg=default,fg=white"
      set -g status-left ""
      set -g status-right ""
      set -g window-status-format "#I:#W"
      set -g window-status-current-format "#[bold]#I:#W"
      set -g status-justify left
      set -g status-position top
    '';

    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
    ];
  };
}
