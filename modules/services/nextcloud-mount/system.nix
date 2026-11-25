{ config, lib, ... }:
{
  config = lib.mkIf config.my.nextcloudMount.enable {
    programs.fuse.enable = true;
  };
}
