{ pkgs, ... }:
{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
    environmentVariables = {
      OLLAMA_KEEP_ALIVE = "1m";
    };
  };

  environment.systemPackages = with pkgs; [
    ollama # The CLI tool
    oterm
  ];

  systemd.services.ollama.wantedBy = pkgs.lib.mkForce [ ];
}
