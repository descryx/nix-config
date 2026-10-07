{
  config,
  local,
  ...
}:
{
  imports = [ ./skills.nix ];

  xdg.configFile."opencode/tui.json".text = builtins.toJSON {
    "$schema" = "https://opencode.ai/tui.json";
    attention = {
      enabled = true;
      notifications = true;
      sound = true;
      volume = 0.4;
    };
    plugin = [
      [
        "@leohenon/opencode-vim-plugin"
        {
          enabled = true;
          vim_initial_mode = "insert";
        }
      ]
    ];
  };

  programs.opencode = {
    enable = true;
    settings = {
      plugin = [
        [
          "@leohenon/opencode-vim-plugin"
          {
            enabled = true;
            vim_initial_mode = "normal";
          }
        ]
      ];
      agent.plan.permission = {
        edit = "deny";
        webfetch = "ask";
        bash = {
          "*" = "ask";

          # read-only inspection
          "git status*" = "allow";
          "git diff*" = "allow";
          "git log*" = "allow";
          "git show*" = "allow";
          "git branch --list*" = "allow";
          "git branch -a*" = "allow";
          "ls*" = "allow";
          "pwd" = "allow";
          "which *" = "allow";
          "nix flake show*" = "allow";

          # re-assert secret protection (must stay LAST)
          "*ssh*" = "deny";
          "*.ssh*" = "deny";
          "*.env*" = "deny";
        };
      };
      permission = {
        "*" = "ask";
        read = {
          "*" = "allow";
          "~/.ssh/**" = "deny";
          "**/id_*" = "deny";
          "*.env" = "deny";
          "*.env.*" = "deny";
          "*.env.example" = "allow";
        };
        grep = "allow";
        glob = "allow";
        list = "allow";
        websearch = "allow";
        webfetch = "ask";
        task = "allow";
        skill = "allow";
        doom_loop = "ask";
        lsp = "allow";
        question = "allow";
        edit = {
          "*" = "ask";
          "src/**" = "allow";
          "include/**" = "allow";
          "tests/**" = "allow";
          "CMakeLists.txt" = "ask"; # build config
          "flake.lock" = "deny"; # should only change via `nix flake update`
          ".git/**" = "deny";
        };
        external_directory = {
          "*" = "ask";
          "~/Projects/**" = "allow";
          "~/.ssh/**" = "deny";
          "~/.config/**" = "ask";
        };
        bash = {
          "*" = "ask";

          # --- allow (read-only / build) ---
          "git status*" = "allow";
          "git diff*" = "allow";
          "git log*" = "allow";
          "git show*" = "allow";
          "git branch --list*" = "allow";
          "git branch -a*" = "allow";
          "git branch -v*" = "allow";
          "git stash list*" = "allow";
          "ls*" = "allow";
          "pwd" = "allow";
          "which *" = "allow";
          "nix flake show*" = "allow";
          "nix flake check*" = "allow";
          "ctest*" = "allow";
          # --- ask ---
          "clang-format*" = "ask";
          "clang-tidy*" = "ask";
          "ninja*" = "ask";
          "cmake*" = "ask";
          "make*" = "ask";
          "nixos-rebuild*" = "ask";
          "curl*" = "ask";
          "wget*" = "ask";

          # --- deny (LAST, so nothing above can override them) ---
          "sudo*" = "deny";
          "rm -rf*" = "deny";
          "git reset --hard*" = "deny";
          "git clean*" = "deny";
          "git push*" = "deny";
          "*ssh*" = "deny"; # broad: also hits files like sshd_config.nix
          "*.ssh*" = "deny";
          "*.env*" = "deny";
        };
      };
    };
    context = ./data/AGENTS.md;
    commands = {
      daydream = ./data/commands/daydream.md;
    };
  };

  home.file = {
    ".config/opencode/themes".source =
      config.lib.file.mkOutOfStoreSymlink "${local.flakeDir}/modules/opencode/config/themes";
    ".config/opencode/skills".source =
      config.lib.file.mkOutOfStoreSymlink "${local.flakeDir}/modules/opencode/config/skills";
  };
}
