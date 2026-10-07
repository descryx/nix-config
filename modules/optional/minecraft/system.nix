{ pkgs, lib, ... }: {
  services.minecraft-server = {
    enable = true;
    eula = true;
    openFirewall = true; # Opens the port the server is running on (by default 25565 but in this case 43000)
    declarative = true;
    whitelist = {
      "desxlate_e" = "yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy";
      # username2 = "yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy";
    };
    serverProperties = {
      server-port = 43000;
      difficulty = 2;
      gamemode = 1;
      max-players = 5;
      motd = "blahblahblahblaulsjdflajldj";
      white-list = false;
      view-distance = 12;
      simulation-distance = 8;
      allow-cheats = true;
      online-mode = false;
    };
    package = pkgs.minecraftServers.vanilla-26-2;
    jvmOpts = "-Xms2048M -Xmx2048M -XX:+UseZGC -XX:+UseCompactObjectHeaders";

  };

  systemd.services.minecraft-server.preStart = lib.mkAfter ''
    cat <<EOF > /var/lib/minecraft/ops.json
    [
      {
        "uuid": "yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy",
        "name": "desxlate_e",
        "level": 4,
        "bypassesPlayerLimit": false
      }
    ]
    EOF
  '';
  systemd.services.minecraft-server.wantedBy = pkgs.lib.mkForce [ ];
}
