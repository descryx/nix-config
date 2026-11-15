{ lib, pkgs, ... }:
{
  # Canon PIXMA TS5050 over USB. The URI and model come from `lpinfo -v` and
  # `lpinfo -m` on the machine; `hardware.printers` recreates the queue on
  # activation, so this survives updates and is not a one-off lpadmin.
  #
  # gutenprint marks the TS5050 driver EXPERIMENTAL. If output is unusable,
  # the fallback is the proprietary cnijfilter2 (TS5000 series PPD).
  hardware.printers = {
    ensurePrinters = [
      {
        name = "Canon_TS5050";
        description = "Canon PIXMA TS5050";
        location = "USB";
        deviceUri = "usb://Canon/TS5000%20series?serial=0770D6&interface=1";
        model = "gutenprint.${lib.versions.majorMinor (lib.getVersion pkgs.gutenprint)}://bjc-PIXMA-TS5050/expert";
        ppdOptions.PageSize = "A4";
      }
    ];
    ensureDefaultPrinter = "Canon_TS5050";
  };
}
