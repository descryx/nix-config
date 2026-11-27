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
          keys = "Strg + +";
          what = "Hineinzoomen";
        }
        {
          keys = "Strg + -";
          what = "Herauszoomen";
        }
        {
          keys = "Strg + 0";
          what = "Zoom zurücksetzen";
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
          keys = "Strg + Umschalt + T";
          what = "Geschlossenen Tab wieder öffnen";
        }
        {
          keys = "Strg + L";
          what = "Adresszeile auswählen";
        }
        {
          keys = "Strg + F";
          what = "Auf der Seite suchen";
        }
        {
          keys = "F5";
          what = "Seite neu laden";
        }
        {
          keys = "Strg + D";
          what = "Lesezeichen speichern";
        }
        {
          keys = "Strg + Umschalt + P";
          what = "Privates Fenster";
        }
        {
          keys = "Alt + ←";
          what = "Zurück zur letzten Seite";
        }
      ];
    }
    {
      title = "Allgemein";
      rows = [
        {
          keys = "Strg + C";
          what = "Kopieren";
        }
        {
          keys = "Strg + X";
          what = "Ausschneiden";
        }
        {
          keys = "Strg + V";
          what = "Einfügen";
        }
        {
          keys = "Strg + Umschalt + V";
          what = "Einfügen ohne Formatierung";
        }
        {
          keys = "Strg + A";
          what = "Alles auswählen";
        }
        {
          keys = "Strg + Z";
          what = "Rückgängig (Fehler passiert)";
        }
        {
          keys = "Strg + Y";
          what = "Wiederherstellen";
        }
        {
          keys = "Strg + S";
          what = "Speichern";
        }
        {
          keys = "Umschalt + Pfeil";
          what = "Text markieren";
        }
        {
          keys = "Entf";
          what = "Löschen";
        }
        {
          keys = "Esc";
          what = "Abbrechen / Fenster schließen";
        }
      ];
    }
    {
      title = "KDE Plasma (Desktop)";
      rows = [
        {
          keys = "Meta";
          what = "Startmenü und Suche";
        }
        {
          keys = "Alt + Leertaste";
          what = "Suche (KRunner)";
        }
        {
          keys = "Alt + Tab";
          what = "Zwischen Fenstern wechseln";
        }
        {
          keys = "Alt + F4";
          what = "Fenster schließen";
        }
        {
          keys = "Meta + Pfeil";
          what = "Fenster an den Rand (halber Bildschirm)";
        }
        {
          keys = "Meta + L";
          what = "Bildschirm sperren";
        }
        {
          keys = "Druck";
          what = "Bildschirmfoto aufnehmen (Spectacle)";
        }
        {
          keys = "Umschalt + Druck";
          what = "Ganzen Bildschirm aufnehmen";
        }
        {
          keys = "Meta + Druck";
          what = "Aktives Fenster aufnehmen";
        }
        {
          keys = "Meta + Umschalt + Druck";
          what = "Bereich auswählen und aufnehmen";
        }
      ];
    }
    {
      title = "Dateien (Thunar)";
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
          keys = "Umschalt + Entf";
          what = "Endgültig löschen";
        }
        {
          keys = "Strg + H";
          what = "Versteckte Dateien anzeigen";
        }
        {
          keys = "Strg + Umschalt + N";
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
          keys = "Strg + Umschalt + S";
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

  page = ''
    <!doctype html>
    <html lang="de">
    <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Spickzettel</title>
    <style>
    :root { color-scheme: light; }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      padding: 24px;
      background: #f4f5f7;
      color: #1d1d1f;
      font-family: "Noto Sans", "DejaVu Sans", sans-serif;
      font-size: 16px;
      line-height: 1.45;
    }
    main {
      max-width: 1100px;
      margin: 0 auto;
      padding: 28px 32px 32px;
      background: #fff;
      border-radius: 10px;
      box-shadow: 0 2px 12px rgba(0, 0, 0, .08);
    }
    h1 { margin: 0 0 2px; font-size: 2rem; }
    .sub { margin: 0 0 18px; color: #555; }
    .note {
      margin: 0 0 22px;
      padding: 10px 14px;
      background: #eaf6fd;
      border-left: 4px solid #3daee9;
      border-radius: 6px;
    }
    .note p { margin: 4px 0; }
    .grid { columns: 2; column-gap: 32px; }
    section {
      break-inside: avoid;
      page-break-inside: avoid;
      margin: 0 0 18px;
    }
    h2 {
      margin: 0 0 8px;
      padding-bottom: 4px;
      font-size: 1.15rem;
      border-bottom: 2px solid #3daee9;
    }
    table { width: 100%; border-collapse: collapse; }
    td { padding: 3px 0; vertical-align: top; }
    td.keys { width: 42%; padding-right: 10px; white-space: nowrap; }
    kbd {
      display: inline-block;
      padding: 1px 6px;
      background: #eef1f5;
      border: 1px solid #cfd6df;
      border-bottom-width: 2px;
      border-radius: 5px;
      font-family: inherit;
      font-size: .92em;
      font-weight: 600;
    }
    .tip { margin: 6px 0 0; padding-top: 12px; border-top: 1px solid #dde1e6; color: #333; }
    @media print {
      @page { size: A4 portrait; margin: 12mm; }
      body { padding: 0; background: #fff; font-size: 11.5pt; }
      main { max-width: none; padding: 0; border-radius: 0; box-shadow: none; }
      .grid { columns: 2; column-gap: 10mm; }
      section { margin-bottom: 6mm; }
      h1 { font-size: 20pt; }
      h2 { font-size: 12.5pt; }
      .note { background: #fff; border: 1px solid #888; }
    }
    @media (max-width: 700px) {
      .grid { columns: 1; }
    }
    </style>
    </head>
    <body>
    <main>
    <h1>Spickzettel</h1>
    <p class="sub">Tastenkürzel für den Alltag am Laptop</p>
    <div class="note">
    <p><strong>Wichtig:</strong> Die Taste <kbd>Ctrl</kbd> heißt auf dieser Tastatur <kbd>Strg</kbd>.
    <kbd>Meta</kbd> ist die Windows-Taste, <kbd>Umschalt</kbd> ist Shift.</p>
    <p>Diesen Zettel ausdrucken: <kbd>Strg</kbd> + <kbd>P</kbd>.</p>
    </div>
    <div class="grid">
    ${lib.concatMapStrings renderSection sections}
    </div>
    <p class="tip">Tipp: Etwas versehentlich gelöscht? <kbd>Strg</kbd> + <kbd>Z</kbd>.
    Tab aus Versehen geschlossen? <kbd>Strg</kbd> + <kbd>Umschalt</kbd> + <kbd>T</kbd>.
    Fenster weg? <kbd>Alt</kbd> + <kbd>Tab</kbd>.</p>
    </main>
    </body>
    </html>
  '';
in
{
  # xdg-open is what the hotkey launches; home-manager does not put it on PATH
  # by itself (checked in the 26.05 xdg modules).
  home.packages = [ pkgs.xdg-utils ];

  # Store copy like the rest of lena's config: the page is generated from this
  # file, so edit the lists above, never the installed HTML.
  home.file.".local/share/spickzettel/spickzettel.html".text = page;

  # Meta+H opens the sheet. Meta+F1 would have been the obvious choice, but
  # lena's captured kwin config already binds it to "Switch to Desktop 1".
  # Plasma only picks the shortcut up on the next login.
  programs.plasma.hotkeys.commands.spickzettel = {
    name = "Spickzettel";
    comment = "Spickzettel mit Tastenkürzeln öffnen";
    key = "Meta+H";
    command = "xdg-open ${config.home.homeDirectory}/.local/share/spickzettel/spickzettel.html";
  };
}
