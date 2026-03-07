# Over The Top: WWI – AMP Generic Module Template

AMP CubeCoders Template für den **Over The Top: WWI** Dedicated Server.  
Da kein nativer Linux-Server existiert, wird die Windows-Version über **Wine + Xvfb** ausgeführt.

## Dateien (alle ins Repo-Root, flat, kleingeschrieben)

| Datei | Beschreibung |
|---|---|
| `over-the-top-wwi.kvp` | Hauptkonfiguration (Executable, Wine, Ports, Console-Regex …) |
| `over-the-top-wwiconfig.json` | Settings-Manifest (AMP UI Felder) |
| `over-the-top-wwimetaconfig.json` | Verknüpft Settings mit Config-Dateien |
| `over-the-top-wwiports.json` | Port-Definitionen |
| `over-the-top-wwiupdates.json` | SteamCMD Update-Stufen inkl. Wine Prefix Init |

## Installation in AMP

In AMP → **Create Instance → Generic Module → Import from GitHub**:
```
https://github.com/DEIN-USER/AMPTemplates
```

## Voraussetzungen (auf dem Host oder im Container)

```bash
sudo apt-get install -y wine wine64 xvfb
```

> Der empfohlene Weg ist die Verwendung des Docker-Images `cubecoders/ampbase:wine-stable`,  
> das AMP automatisch anbietet (ContainerPolicy = RecommendedOnLinux).

## Bekannte Platzhalter

| Platzhalter | Bedeutung |
|---|---|
| `1107551` | Steam App-ID des Dedicated Servers – ggf. anpassen |
| `OTTDedicatedServer.exe` | Executable-Name – ggf. anpassen nach erstem Download |
| `AppReadyRegex` | Console-Pattern für „Server bereit" – ggf. aus Server-Log ermitteln |

## Lizenz

MIT
