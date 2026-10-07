{ pkgs, inputs, ... }:
{
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    gcc_latest
    llvmPackages_latest.libcxx
    gnumake
    nixd
    nixfmt
    statix
    parted
    smartmontools
    brightnessctl
    nix-output-monitor
    xdg-utils
    deadnix
  ];

  programs = {
    wshowkeys = {
      enable = true;
      package = inputs.wshowkeys.packages.${pkgs.stdenv.hostPlatform.system}.default;
    };
    nix-index.enable = true;
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc
        zlib
        glibc
      ];

    };
  };
}
