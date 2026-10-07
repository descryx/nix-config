{
  pkgs,
  local,
  ...
}:
{
  users.users.${local.username} = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    packages = with pkgs; [ tree ];
  };
  programs.zsh.enable = true;

  time.timeZone = "Europe/Berlin";

  security.sudo.extraConfig = ''
    Defaults pwfeedback
  '';
}
