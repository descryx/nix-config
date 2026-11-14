{ pkgs, ... }:
{
  # The password is not stored here. Set it once with `sudo passwd lena`, and
  # reset it the same way if it is lost. `mutableUsers` is on by default.
  users.users.lena = {
    isNormalUser = true;
    description = "Lena";
    shell = pkgs.zsh;
    # Needed for the Plasma network applet / NetworkManager.
    extraGroups = [ "networkmanager" ];
  };
}
