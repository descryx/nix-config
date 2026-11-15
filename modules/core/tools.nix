{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  # Present on every host, including the laptop.
  environment.systemPackages =
    with pkgs;
    [
      vim
      git
      curl
      parted
      smartmontools
      brightnessctl
      nix-output-monitor
      xdg-utils
    ]
    ++ lib.optionals config.my.dev.enable (
      with pkgs;
      [
        # Compilers and editor tooling: ~1.3 GiB, only useful where development
        # happens. `my.dev.enable` gates the home dev module too, so the switch
        # now means the same thing on both sides.
        gcc_latest
        llvmPackages_latest.libcxx
        gnumake
        nixd
        nixfmt
        statix
        deadnix
      ]
    );

  programs = {
    wshowkeys = {
      enable = config.my.dev.enable;
      package = inputs.wshowkeys.packages.${pkgs.stdenv.hostPlatform.system}.default;
    };

    nix-index.enable = config.my.dev.enable;

    # Stays on every host: foreign binaries (AppImages) are not a development
    # feature, and lena may run one.
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
