{
  config,
  pkgs,
  lib,
  ...
}:
let
  rev = "1d7418b8abfa543744ae029e63a482aee03f9022";
  ua = pkgs.fetchFromGitHub {
    owner = "Egonex-AI";
    repo = "Understand-Anything";
    inherit rev;
    hash = "sha256-Q4y7IfdLeYBx4DTflB3/T7XIigAMasaCcgw6dZZ/tTc=";
  };

  dest = "${config.home.homeDirectory}/.local/share/understand-anything";

  skills = [
    "understand"
    "understand-dashboard"
    "understand-chat"
    "understand-explain"
    "understand-diff"
    "understand-onboard"
  ];

  # Upstream ships these as command-shaped skills (argument-hint + `$ARGUMENTS`)
  # even though Claude exposes them as skills. Generate opencode commands whose
  # bodies are the SKILL.md contents so `$ARGUMENTS` is substituted natively.
  stripFrontmatter =
    text:
    let
      afterOpen = builtins.substring 4 (builtins.stringLength text) text;
      parts = builtins.split "\n---\n" afterOpen;
      render = x: if builtins.isList x then "\n---\n" else x;
      dropFirstTwo = l: builtins.tail (builtins.tail l);
    in
    builtins.concatStringsSep "" (map render (dropFirstTwo parts));

  commandMeta = {
    understand = "Analyze a codebase into an understand-anything knowledge graph";
    understand-dashboard = "Launch the interactive dashboard for an existing knowledge graph";
    understand-chat = "Ask questions about a codebase using its knowledge graph";
    understand-explain = "Deep-dive explanation of a file, function, or module";
    understand-diff = "Analyze git diffs or pull requests against the knowledge graph";
    understand-onboard = "Generate an onboarding guide from the knowledge graph";
  };

  mkCommand = name: ''
    ---
    description: ${commandMeta.${name}}
    agent: build
    ---
    ${stripFrontmatter (builtins.readFile "${ua}/understand-anything-plugin/skills/${name}/SKILL.md")}
  '';

  opencodeCommands = builtins.listToAttrs (
    map (name: {
      inherit name;
      value = mkCommand name;
    }) skills
  );
in
{
  programs.opencode.commands = opencodeCommands;

  home = {
    packages = [
      pkgs.nodejs
      pkgs.pnpm
    ];

    # Copy the pinned source to a writable place whenever the pinned rev changes
    activation.understandAnything = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      dest="${dest}"
      if [ "$(cat "$dest/.rev" 2>/dev/null)" != "${rev}" ]; then
        rm -rf "$dest"
        mkdir -p "$dest"
        cp -r ${ua}/. "$dest"/
        chmod -R u+w "$dest"
        echo "${rev}" > "$dest/.rev"
      fi
    '';

    # Skills link to the writable copy, not the store
    file = lib.listToAttrs (
      map (name: {
        name = ".agents/skills/${name}";
        value.source = config.lib.file.mkOutOfStoreSymlink "${dest}/understand-anything-plugin/skills/${name}";
      }) skills
    );
  };

}
