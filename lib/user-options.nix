# Options that belong to one home-manager user, not to the host.
#
# The user roots (users/<name>/home.nix) import this file. Shared home modules
# read `config.my.dotfiles.live` without needing to know which user they run for.
{ lib, ... }:
{
  options.my.dotfiles.live = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Link dotfiles out of the store so edits in the repo apply immediately.
      Set to false to copy the same config into the store instead. The copy
      does not depend on the repo being readable by this user, which is what a
      second user needs.
    '';
  };
}
