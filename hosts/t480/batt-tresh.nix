{ pkgs, lib, ... }:

{
  systemd.services.battery-charge-threshold = {
    description = "Set battery charge thresholds (laptop only)";
    after = [ "multi-user.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      # Only run the script if at least one battery exists
      ExecStart =
        let
          script = pkgs.writeShellScript "set-battery-thresholds" ''
            set -euo pipefail

            # Common battery names on Linux
            for bat in BAT0 BAT1; do
              path="/sys/class/power_supply/$bat"
              if [ -d "$path" ] && [ -w "$path/charge_control_end_threshold" ]; then
                # Stop charging at 80 %
                echo 80 > "$path/charge_control_end_threshold"
                # Optional: start charging again only below 75 %
                # (uncomment if your hardware supports it)
                if [ -w "$path/charge_control_start_threshold" ]; then
                echo 75 > "$path/charge_control_start_threshold"
                fi
                echo "Set thresholds for $bat"
              fi
            done
          '';
        in
        "${script}";
    };
  };
}
