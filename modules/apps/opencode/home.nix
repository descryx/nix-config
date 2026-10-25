{
  config,
  local,
  osConfig,
  lib,
  ...
}:
let
  # v2 permissions are an ORDERED list and the LAST matching rule wins.
  # Broad rules first, specific exceptions after, denies at the very end.
  rule = effect: action: resource: { inherit effect action resource; };
  allow = rule "allow";
  ask = rule "ask";
  deny = rule "deny";

  readOnlyShell = [
    (allow "shell" "git status*")
    (allow "shell" "git diff*")
    (allow "shell" "git log*")
    (allow "shell" "git show*")
    (allow "shell" "git branch --list*")
    (allow "shell" "git branch -a*")
    (allow "shell" "ls*")
    (allow "shell" "pwd")
    (allow "shell" "which *")
    (allow "shell" "nix flake show*")
  ];

  # Re-asserted last in every shell ruleset so nothing above can override them.
  shellSecretDenies = [
    (deny "shell" "*ssh*")
    (deny "shell" "*.ssh*")
    (deny "shell" "*.env*")
  ];
in
{
  imports = [ ./skills.nix ];

  config = lib.mkIf osConfig.my.opencode.enable {
    # v2 reads TUI settings and TUI plugins from cli.json (not tui.json).
    #
    # force = true: opencode saves TUI settings by writing cli.json.tmp and
    # renaming it over cli.json, which replaces the symlink home-manager placed
    # there with a regular file. Without force, the next activation sees a
    # foreign file, tries to back it up, finds the previous cli.json.bak and
    # aborts. With force the path is skipped by the collision check, the file
    # opencode wrote is moved to cli.json.bak and ours is relinked. Consequence:
    # a TUI toggle lasts until the next switch. Change settings here instead.
    xdg.configFile."opencode/cli.json" = {
      force = true;
      text = builtins.toJSON {
        "$schema" = "https://opencode.ai/v2/cli.json";
        theme = {
          name = "myTheme";
          mode = "system";
        };
        plugins = [ "@leohenon/opencode-vim-plugin@0.2.0-beta.2" ]; # pinned, no floating @beta
        attention = {
          enabled = true;
          notifications = true;
          sound = true;
          volume = 0.4;
        };
        diffs = {
          wrap = "word";
          view = "auto";
        };
        session = {
          sidebar = "auto";
          scrollbar = false;
          thinking = "hide";
        };
        tabs.layout = "horizontal";
        prompt.image_preview = true;
        animations = true;
      };
    };

    programs.opencode = {
      enable = true;
      settings = {
        permissions = [
          (ask "*" "*")
        ] # default for anything not listed
        ++ [
          (allow "read" "*")
          (allow "grep" "*")
          (allow "glob" "*")
          (allow "list" "*")
          (allow "lsp" "*")
          (allow "websearch" "*")
          (allow "skill" "*")
          (allow "question" "*")
          (allow "subagent" "*")
        ]
        ++ [
          # edits
          (ask "edit" "*")
          (allow "edit" "src/**")
          (allow "edit" "include/**")
          (allow "edit" "tests/**")
          (ask "edit" "CMakeLists.txt") # build config
        ]
        ++ [
          # outside the project
          (ask "external_directory" "*")
          (allow "external_directory" "~/Projects/**")
          (ask "external_directory" "~/.config/**")
        ]
        ++ readOnlyShell
        ++ [
          (allow "shell" "git branch -v*")
          (allow "shell" "git stash list*")
          (allow "shell" "nix flake check*")
          (allow "shell" "ctest*")
          (ask "shell" "clang-format*")
          (ask "shell" "clang-tidy*")
          (ask "shell" "ninja*")
          (ask "shell" "cmake*")
          (ask "shell" "make*")
          (ask "shell" "nixos-rebuild*")
          (ask "shell" "curl*")
          (ask "shell" "wget*")
        ]
        ++ [
          # hard denies, LAST
          (deny "read" "~/.ssh/**")
          (deny "read" "**/id_*")
          (deny "read" "*.env")
          (deny "read" "*.env.*")
          (allow "read" "*.env.example") # exception to the two denies above
          (deny "edit" "flake.lock") # only via `nix flake update`
          (deny "edit" ".git/**")
          (deny "external_directory" "~/.ssh/**")
          (deny "shell" "sudo*")
          (deny "shell" "rm -rf*")
          (deny "shell" "git reset --hard*")
          (deny "shell" "git clean*")
          (deny "shell" "git push*")
        ]
        ++ shellSecretDenies;

        # Appended AFTER the global rules above, so these refine them.
        agents.plan.permissions = [
          (deny "edit" "*")
          (ask "webfetch" "*")
          (ask "shell" "*")
        ]
        ++ readOnlyShell
        ++ shellSecretDenies;
      };

      context = ./data/AGENTS.md;
      commands.daydream = ./data/commands/daydream.md;
      agents.teacher = ./data/teacher.md;
    };

    home.file = {
      ".config/opencode/themes".source =
        config.lib.file.mkOutOfStoreSymlink "${local.flakeDir}/modules/apps/opencode/config/themes";
      ".config/opencode/skills".source =
        config.lib.file.mkOutOfStoreSymlink "${local.flakeDir}/modules/apps/opencode/config/skills";
    };
  };
}
