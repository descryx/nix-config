{ lib, ... }:
{
  options.opt.tmux.enable = lib.mkEnableOption "tmux";
}
