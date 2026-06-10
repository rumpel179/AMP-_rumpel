# Aloft Dedicated Server — AMP Configuration Template

An **unofficial** configuration template for deploying and managing an
[Aloft](https://store.steampowered.com/app/1660080/Aloft/) Dedicated Server inside
[CubeCoders AMP](https://cubecoders.com/AMP).

Aloft ships only a **Windows** server build, so this template runs `Aloft.exe` under
**Wine** with a virtual display (Xvfb). A wrapper script (`start_aloft.sh`) handles world
creation, loading, graceful shutdown, and join-code reporting.

> ⚠️ A Steam account that **owns Aloft** is required for installation — the server build
> is not available via anonymous Steam login.

---

## Runs with **or** without a container

The template works in both deployment modes — **you do not need Docker or Podman to run it**:

| Mode | What you need |
|------|----------------|
| **Containerized** (Docker / Podman) | Nothing extra — the `cubecoders/ampbase:wine` image already provides Wine, Xvfb and the required libraries. |
| **Bare metal** (no container) | Wine, Xvfb and a few libraries installed on the host (see below). |

The wrapper script is **self-locating**: it derives all of its paths from where it actually
lives, so the same file works whether AMP mounts the instance at `/AMP/...` inside a
container or runs it directly from the host data directory.

---

## Requirements

- **CubeCoders AMP** `2.4.6.6` or newer
- A **Steam account that owns Aloft** (App ID `1660080`)
- **Linux** host (x86_64)

### Additional requirements for bare-metal (non-container) deployments

When you run the instance **without** a container, the host must provide Wine and Xvfb.
On Debian/Ubuntu:

```bash
sudo dpkg --add-architecture i386
sudo apt update
sudo apt install -y wine64 wine32 winbind xvfb cabextract
```

Verify both binaries are on the `PATH`:

```bash
which wine Xvfb
```

(For containerized deployments you can skip this — the Wine base image already includes everything.)

---

## Installation

1. In AMP, go to **Configuration → Instance Deployment → Add a Configuration Repository**
   and add this repository in the form `user/repo:branch`, e.g.
   `rumpel179/AMP-_rumpel:main`. Click **Fetch**, then refresh your browser.
2. Create a new instance using the **Aloft** configuration.
   - To run **without** a container, make sure the Docker/container option is **off** when
     creating the instance. (`Meta.DockerRequired` is `False`, so this is allowed.)
   - To run **with** a container, leave it on — both work.
3. Open the instance, enter your Steam credentials, and run **Update**. This downloads the
   server via SteamCMD and installs the wrapper script.
4. Adjust the settings (server name, map, island count, player count, etc.) and press **Start**.

On first start the wrapper generates a new world; subsequent starts simply load it.

---

## Connecting

Once the server is up, the console prints the in-game **join / room code**, for example:

```
=========================================================
   [ALOFT JOIN CODE]: Server Ready : 134832
=========================================================
```

Share that code with your players so they can join from inside the game.

> The console may also show `Player joined: Server` on startup — that is the server
> reporting itself as ready, not an actual player.

---

## Configurable settings

Exposed in the AMP UI:

- **Server Name** (no spaces)
- **Map Name** (no spaces)
- **Number of Islands** (250–500)
- **Creative Mode** (survival / creative)
- **Server Visibility** (public server browser on/off)
- **Server Port** (0 = automatic)
- **Admin Steam IDs** (comma-separated)
- **Player Count**

### Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `7777` | TCP + UDP | Main game traffic |
| `27038` | TCP + UDP | Query |

---

## Managing files

After setup and the first run, you can upload your own worlds under:

```
Data06/Saves/
```

---

## Troubleshooting

### `mkdir: cannot create directory '/AMP': Permission denied`
The instance is running an **outdated wrapper script** that still has hard-coded `/AMP/...`
paths, which can't be created on a bare-metal host. Make sure `aloftupdates.json` fetches the
corrected `start_aloft.sh` from this repository and that its `OverwriteExistingFiles` is set to
`true`, then run **Update** again. To verify the script actually in use is correct:

```bash
grep -n 'GAME_DIR=' /home/amp/.ampdata/instances/<Instance>/aloft/start_aloft.sh
```

It should read `GAME_DIR="$SCRIPT_DIR/1660080"` — **not** `/AMP/...`.

### The ASCII banner repeats over and over in the console
AMP is restarting the process because it crashes on startup. Look at the **first error after
the banner** — that line is the real cause (most often the `/AMP` path issue above, or a missing
Wine/Xvfb on a bare-metal host).

### `wine: command not found` or `Xvfb: not found` (bare metal)
Wine and/or Xvfb are not installed on the host. Install them (see **Requirements**) and confirm
with `which wine Xvfb`.

### SteamCMD can't download the server
The Aloft server build requires a Steam account that **owns the game** — anonymous login does not
work. Enter valid Steam credentials on the instance and run **Update** again.

### An uploaded world doesn't show up
Worlds live under `Data06/Saves/w_<MapName>/`, and the **Map Name** in the AMP settings must match
the folder name (without the `w_` prefix). If a world still isn't picked up, check the real path
inside the Wine prefix at `.wine/drive_c/users/.../Aloft/Data06/Saves/`.

---

## Credits

- Template authors: **Tyqo & Rumpel**
- This is a community template and is **not** affiliated with or endorsed by
  Astrolabe Interactive.
