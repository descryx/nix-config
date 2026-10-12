{
  osConfig,
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkIf osConfig.my.gaming.enable {
    home.packages = with pkgs; [
      gamescope
      gamemode # gamemoderun CLI — enables CPU/GPU auto-tuning for games
      mangohud # in-game performance overlay (mangohud %command%)
      vulkan-tools # vulkaninfo, vkcube — verify Vulkan is working
      prismlauncher
    ];
  };
}
