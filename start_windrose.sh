#!/bin/bash
set -e

# self-locating: works in a container (/AMP/...) AND on bare metal
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GAME_DIR="$SCRIPT_DIR/4129620"
WINE_PREFIX_DIR="$SCRIPT_DIR/.wine"
EXE_NAME="Aloft.exe"

export WINEPREFIX="$WINE_PREFIX_DIR"
export WINEARCH="win64"
export WINEDEBUG="-all,fixme-all"
export USER="${GAME_USER:-${USER:-amp}}"
export USERNAME="$USER"

while [[ "$#" -gt 0 ]]; do
    case $1 in
        *) shift ;;
    esac
done

shutdown_handler() { /usr/bin/wineserver -k; pkill -f "Xvfb :99" || true; sleep 3; exit 0; }
trap shutdown_handler SIGINT SIGTERM

[ ! -d "$WINEPREFIX" ] && wineboot -u

if ! pgrep -x "Xvfb" > /dev/null; then
    Xvfb :99 -screen 0 1024x768x16 -nolisten tcp &
    sleep 2
fi
export DISPLAY=:99

cd "$GAME_DIR" || { echo "Game dir not found"; exit 1; }

# ====== GAME-SPECIFIC LAUNCH LOGIC HERE (world create/load, config gen, etc.) ======
wine "$EXE_NAME" "$@"
