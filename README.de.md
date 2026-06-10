# Aloft Dedicated Server — AMP-Konfigurationsvorlage

Eine **inoffizielle** Konfigurationsvorlage zum Bereitstellen und Verwalten eines
[Aloft](https://store.steampowered.com/app/1660080/Aloft/)-Dedicated-Servers in
[CubeCoders AMP](https://cubecoders.com/AMP).

Aloft liefert nur einen **Windows**-Server-Build, daher führt diese Vorlage `Aloft.exe`
unter **Wine** mit einem virtuellen Display (Xvfb) aus. Ein Wrapper-Script
(`start_aloft.sh`) übernimmt Welterstellung, Laden, sauberes Herunterfahren und die Ausgabe
des Join-Codes.

> ⚠️ Für die Installation wird ein Steam-Konto benötigt, das **Aloft besitzt** — der
> Server-Build steht nicht über anonymen Steam-Login zur Verfügung.

---

## Läuft **mit oder ohne** Container

Die Vorlage funktioniert in beiden Betriebsarten — **du brauchst weder Docker noch Podman**:

| Modus | Was du brauchst |
|-------|------------------|
| **Containerisiert** (Docker / Podman) | Nichts zusätzlich — das Image `cubecoders/ampbase:wine` bringt Wine, Xvfb und die nötigen Bibliotheken bereits mit. |
| **Bare Metal** (ohne Container) | Wine, Xvfb und ein paar Bibliotheken auf dem Host (siehe unten). |

Das Wrapper-Script ist **selbstlokalisierend**: Es leitet alle Pfade davon ab, wo es
tatsächlich liegt. Dieselbe Datei funktioniert also sowohl, wenn AMP die Instanz im Container
unter `/AMP/...` einhängt, als auch, wenn sie direkt aus dem Host-Datenverzeichnis läuft.

---

## Voraussetzungen

- **CubeCoders AMP** `2.4.6.6` oder neuer
- Ein **Steam-Konto, das Aloft besitzt** (App-ID `1660080`)
- **Linux**-Host (x86_64)

### Zusätzliche Voraussetzungen für Bare-Metal-Betrieb (ohne Container)

Wenn die Instanz **ohne** Container läuft, muss der Host Wine und Xvfb bereitstellen.
Unter Debian/Ubuntu:

```bash
sudo dpkg --add-architecture i386
sudo apt update
sudo apt install -y wine64 wine32 winbind xvfb cabextract
```

Prüfe, dass beide Binaries im `PATH` liegen:

```bash
which wine Xvfb
```

(Für den Container-Betrieb kannst du das überspringen — das Wine-Basis-Image enthält bereits alles.)

---

## Installation

1. In AMP zu **Configuration → Instance Deployment → Add a Configuration Repository** gehen
   und dieses Repository im Format `user/repo:branch` hinzufügen, z. B.
   `rumpel179/AMP-_rumpel:main`. **Fetch** klicken, danach den Browser neu laden.
2. Eine neue Instanz mit der **Aloft**-Konfiguration erstellen.
   - Für den Betrieb **ohne** Container die Docker-/Container-Option beim Erstellen
     **deaktivieren**. (`Meta.DockerRequired` ist `False`, das ist also erlaubt.)
   - Für den Betrieb **mit** Container die Option aktiviert lassen — beides funktioniert.
3. Die Instanz öffnen, Steam-Zugangsdaten eingeben und **Update** ausführen. Damit wird der
   Server per SteamCMD heruntergeladen und das Wrapper-Script installiert.
4. Einstellungen anpassen (Servername, Map, Inselanzahl, Spielerzahl usw.) und **Start** drücken.

Beim ersten Start erzeugt das Wrapper-Script eine neue Welt; bei späteren Starts wird sie nur geladen.

---

## Verbinden

Sobald der Server läuft, gibt die Konsole den **Join-/Room-Code** für das Spiel aus, z. B.:

```
=========================================================
   [ALOFT JOIN CODE]: Server Ready : 134832
=========================================================
```

Gib diesen Code an deine Mitspieler weiter, damit sie aus dem Spiel heraus beitreten können.

> Die Konsole zeigt beim Start eventuell auch `Player joined: Server` — das ist der Server,
> der sich selbst als bereit meldet, **kein** echter Spieler.

---

## Einstellbare Optionen

In der AMP-Oberfläche verfügbar:

- **Server Name** (keine Leerzeichen)
- **Map Name** (keine Leerzeichen)
- **Number of Islands** (250–500)
- **Creative Mode** (Survival / Kreativ)
- **Server Visibility** (öffentliche Serverliste an/aus)
- **Server Port** (0 = automatisch)
- **Admin Steam IDs** (kommagetrennt)
- **Player Count**

### Ports

| Port | Protokoll | Zweck |
|------|-----------|-------|
| `7777` | TCP + UDP | Haupt-Spielverkehr |
| `27038` | TCP + UDP | Query |

---

## Dateien verwalten

Nach der Einrichtung und dem ersten Start kannst du eigene Welten hochladen unter:

```
Data06/Saves/
```

---

## Fehlersuche

### `mkdir: cannot create directory '/AMP': Permission denied`
Die Instanz führt ein **veraltetes Wrapper-Script** aus, das noch fest verdrahtete
`/AMP/...`-Pfade hat — die lassen sich auf einem Bare-Metal-Host nicht anlegen. Stelle sicher,
dass `aloftupdates.json` das korrigierte `start_aloft.sh` aus diesem Repository lädt und dass
dort `OverwriteExistingFiles` auf `true` steht, und führe dann erneut **Update** aus. Zum
Prüfen, ob das tatsächlich verwendete Script korrekt ist:

```bash
grep -n 'GAME_DIR=' /home/amp/.ampdata/instances/<Instanz>/aloft/start_aloft.sh
```

Dort sollte `GAME_DIR="$SCRIPT_DIR/1660080"` stehen — **nicht** `/AMP/...`.

### Der ASCII-Banner wiederholt sich endlos in der Konsole
AMP startet den Prozess immer wieder neu, weil er beim Start abstürzt. Schau dir den **ersten
Fehler nach dem Banner** an — diese Zeile ist die eigentliche Ursache (meist das `/AMP`-Pfad-
Problem von oben oder fehlendes Wine/Xvfb auf einem Bare-Metal-Host).

### `wine: command not found` oder `Xvfb: not found` (Bare Metal)
Wine und/oder Xvfb sind auf dem Host nicht installiert. Installiere sie (siehe
**Voraussetzungen**) und bestätige mit `which wine Xvfb`.

### SteamCMD kann den Server nicht herunterladen
Der Aloft-Server-Build benötigt ein Steam-Konto, das **das Spiel besitzt** — anonymer Login
funktioniert nicht. Gib gültige Steam-Zugangsdaten in der Instanz ein und führe **Update**
erneut aus.

### Eine hochgeladene Welt taucht nicht auf
Welten liegen unter `Data06/Saves/w_<MapName>/`, und der **Map Name** in den AMP-Einstellungen
muss dem Ordnernamen entsprechen (ohne das Präfix `w_`). Wird eine Welt trotzdem nicht erkannt,
prüfe den echten Pfad im Wine-Prefix unter `.wine/drive_c/users/.../Aloft/Data06/Saves/`.

---

## Credits

- Vorlagen-Autoren: **Tyqo & Rumpel**
- Dies ist eine Community-Vorlage und steht in **keiner** Verbindung zu Astrolabe Interactive
  und wird von ihnen nicht unterstützt.
