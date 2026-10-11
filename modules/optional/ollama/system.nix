{ pkgs, ... }:
{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
    environmentVariables = {
      OLLAMA_KEEP_ALIVE = "1m";
    };
  };

  # The CLI already ships in the service package (cfg.package, set above).
  # Listing `ollama` here too would put a second bin/ollama (cpu build vs the
  # cuda build) in the system profile; system-path's buildEnv ignores collisions,
  # so the two would silently shadow each other.
  environment.systemPackages = with pkgs; [
    oterm
  ];

  systemd.services.ollama.wantedBy = pkgs.lib.mkForce [ ];
}
