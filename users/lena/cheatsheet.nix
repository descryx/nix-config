{
  config,
  pkgs,
  lib,
  ...
}:
let
  # Content lives here as data, not as hand-written HTML: add or change a row
  # in the lists below and the page is regenerated on the next rebuild.
  sections = [
    {
      title = "Im Browser (Zen)";
      rows = [
        {
          keys = "Strg + P";
          what = "Drucken (auch diesen Spickzettel)";
        }
        {
          keys = "Strg + '+'";
          what = "Groser machen (zoom)";
        }
        {
          keys = "Strg + '-'";
          what = "Kleiner machen (zoom)";
        }
        {
          keys = "Strg + 0";
          what = "Normal machen (zoom)";
        }
        {
          keys = "Strg + T";
          what = "Neuer Tab";
        }
        {
          keys = "Strg + W";
          what = "Tab schließen";
        }
        {
          keys = "Strg + Shift + T";
          what = "Geschlossenen Tab wieder öffnen";
        }
        {
          keys = "Strg + F";
          what = "Text auf der seite suchen";
        }
        {
          keys = "F5";
          what = "Seite neu laden";
        }
        {
          keys = "Alt + <-";
          what = "Eine seite zuruck";
        }
        {
          keys = "Alt + ->";
          what = "Eine seite nach vorne";
        }
      ];
    }
    {
      title = "Allgemein";
      rows = [
        {
          keys = "Strg + A";
          what = "Alles auswählen";
        }
        {
          keys = "Strg + Z";
          what = "Rückgängig machen (Fehler passiert)";
        }
        {
          keys = "Strg + Shift + Z";
          what = "Rückgang Rückgängig machen";
        }
        {
          keys = "Strg + S";
          what = "Speichern";
        }
        {
          keys = "Strg + P";
          what = "Drucken";
        }

      ];
    }
    {
      title = "KDE Plasma (Desktop)";
      rows = [
        {
          keys = "Super + W";
          what = "Fenster Uberblick";
        }
        {
          keys = "Alt + F4";
          what = "Fenster schließen";
        }
        {
          keys = "Super + Pfeil";
          what = "Fenster an den Rand (halber Bildschirm)";
        }
        {
          keys = "Super + L";
          what = "Bildschirm sperren";
        }
        {
          keys = "Druck";
          what = "Bildschirmfoto aufnehmen (screenshot von region)";
        }
        {
          keys = "Shift + Druck";
          what = "Ganzen Bildschirm aufnehmen(screenshot)";
        }
        {
          keys = "Super + Shift + Druck";
          what = "Bereich auswählen und aufnehmen(screen video)";
        }
      ];
    }
    {
      title = "Dateienmanager (Thunar)";
      rows = [
        {
          keys = "Strg + L";
          what = "Pfad eingeben";
        }
        {
          keys = "F2";
          what = "Umbenennen";
        }
        {
          keys = "Entf";
          what = "In den Papierkorb";
        }
        {
          keys = "Shift + Entf";
          what = "Endgültig löschen";
        }
        {
          keys = "Strg + Shift + N";
          what = "Neuer Ordner";
        }
        {
          keys = "Strg + T";
          what = "Neuer Tab";
        }
        {
          keys = "Alt + ←";
          what = "Zurück";
        }
      ];
    }
    {
      title = "LibreOffice";
      rows = [
        {
          keys = "Strg + S";
          what = "Speichern";
        }
        {
          keys = "Strg + Shift + S";
          what = "Speichern unter";
        }
        {
          keys = "Strg + Z";
          what = "Rückgängig";
        }
        {
          keys = "Strg + C / V / X";
          what = "Kopieren / Einfügen / Ausschneiden";
        }
        {
          keys = "Strg + F";
          what = "Suchen";
        }
        {
          keys = "Strg + Enter";
          what = "Seitenumbruch (Writer)";
        }
      ];
    }
  ];

  renderRow = row: ''
    <tr><td class="keys"><kbd>${row.keys}</kbd></td><td>${row.what}</td></tr>
  '';

  renderSection = section: ''
    <section>
      <h2>${section.title}</h2>
      <table><tbody>
    ${lib.concatMapStrings renderRow section.rows}
      </tbody></table>
    </section>
  '';

  # The PDF is the artefact that gets installed, so this stylesheet is a print
  # stylesheet only: no shadows, no media-width query (WeasyPrint ignores those
  # and warns). It is dark for on-screen reading in Okular; printing it costs a
  # lot of toner, so ask for a light variant if the sheet is to be printed.
  page = ''
    <!doctype html>
    <html lang="de">
    <head>
    <meta charset="utf-8">
    <title>Spickzettel</title>
    <style>
    @page { size: A4 portrait; margin: 12mm; background: #000000; }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      background: #000000;
      color: #ffffff;
      font-family: "DejaVu Sans", sans-serif;
      font-size: 10.5pt;
      line-height: 1.4;
    }
    h1 { margin: 0 0 2pt; font-size: 19pt; }
    .sub { margin: 0 0 7pt; color: #a0a8b0; font-size: 11pt; }
    .note {
      margin: 0 0 9pt;
      padding: 5pt 8pt;
      background: #10202b;
      border-left: 3pt solid #3daee9;
      border-radius: 3pt;
    }
    .note p { margin: 2pt 0; }
    .grid { columns: 2; column-gap: 7mm; }
    section {
      break-inside: avoid;
      page-break-inside: avoid;
      margin: 0 0 6mm;
    }
    h2 {
      margin: 0 0 4pt;
      padding-bottom: 2pt;
      font-size: 12.5pt;
      border-bottom: 1.5pt solid #3daee9;
    }
    table { width: 100%; border-collapse: collapse; }
    td { padding: 1.5pt 0; vertical-align: top; }
    td.keys { width: 37%; padding-right: 6pt; white-space: nowrap; }
    kbd {
      display: inline-block;
      padding: 0.5pt 4pt;
      background: #1e2329;
      border: 0.75pt solid #566270;
      border-bottom-width: 1.5pt;
      border-radius: 3pt;
      font-family: inherit;
      font-size: 9.5pt;
      font-weight: 600;
      color: #ffffff;
    }
    </style>
    </head>
    <body>
    <h1>Spickzettel</h1>
    <p class="sub">Tastenkürzel für den Alltag am Laptop</p>
    <div class="note">
    <p><strong>Wichtig:</strong> Die Taste <kbd>Ctrl</kbd> heißt auf dieser Tastatur <kbd>Strg</kbd>.
    <kbd>Super</kbd> ist die Windows-Taste, <kbd>Shift</kbd> ist Shift.</p>
    <p>Diesen Zettel ausdrucken: <kbd>Strg</kbd> + <kbd>P</kbd>.</p>
    <p>Tipp: Etwas versehentlich gelöscht? <kbd>Strg</kbd> + <kbd>Z</kbd>.
    Tab aus Versehen geschlossen? <kbd>Strg</kbd> + <kbd>Shift</kbd> + <kbd>T</kbd>.
    Fenster weg? <kbd>Alt</kbd> + <kbd>Tab</kbd>.</p>
    </div>
    <div class="grid">
    ${lib.concatMapStrings renderSection sections}
    </div>
    </body>
    </html>
  '';

  # WeasyPrint runs at build time only; nothing of it lands in lena's profile.
  # DejaVu is the only font the stylesheet asks for, so the sandbox needs just
  # that one font directory.
  pdf =
    pkgs.runCommand "spickzettel.pdf"
      {
        nativeBuildInputs = [ pkgs.python3Packages.weasyprint ];
        FONTCONFIG_FILE = pkgs.makeFontsConf {
          fontDirectories = [ pkgs.dejavu_fonts ];
        };
        SOURCE_DATE_EPOCH = "1";
      }
      ''
        export HOME=$TMPDIR
        weasyprint ${pkgs.writeText "spickzettel.html" page} "$out"
      '';
in
{
  # Store copy like the rest of lena's config: the PDF is generated from this
  # file, so edit the lists above and rebuild, never the installed PDF.
  home.file.".local/share/spickzettel/spickzettel.pdf".source = pdf;

  # "Super" is what the sheet calls the key; KDE's shortcut syntax and Qt's
  # parser only know it as "Meta". Meta+F1 would have been the obvious choice,
  # but lena's captured kwin config already binds it to "Switch to Desktop 1".
  # Plasma only picks the shortcut up on the next login.
  programs.plasma.hotkeys.commands.spickzettel = {
    name = "Spickzettel";
    comment = "Spickzettel mit Tastenkürzeln öffnen";
    key = "Meta+H";
    command = "okular --unique ${config.home.homeDirectory}/.local/share/spickzettel/spickzettel.pdf";
  };
}
