{ config, lib, ... }:
{
  # Trash and remote folders (sftp/smb/webdav) need the GVfs services. The
  # package alone does not start them.
  config = lib.mkIf config.my.luciole.enable {
    services.gvfs.enable = true;
  };
}
