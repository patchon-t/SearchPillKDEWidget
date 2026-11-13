#!/usr/bin/env bash
# Install or upgrade the Search Pill plasmoid and restart plasmashell.
# Usage: ./install.sh [--no-restart]
set -euo pipefail

ID="com.techbypatch.searchpill"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESTART=1

for arg in "$@"; do
    case "$arg" in
        --no-restart) RESTART=0 ;;
        -h|--help) echo "Usage: $0 [--no-restart]"; exit 0 ;;
        *) echo "Unknown option: $arg" >&2; exit 1 ;;
    esac
done

command -v kpackagetool6 >/dev/null || { echo "kpackagetool6 not found (install Plasma 6 / KF6)" >&2; exit 1; }

if kpackagetool6 -t Plasma/Applet --show "$ID" >/dev/null 2>&1; then
    echo "Upgrading $ID..."
    kpackagetool6 -t Plasma/Applet --upgrade "$DIR"
else
    echo "Installing $ID..."
    kpackagetool6 -t Plasma/Applet --install "$DIR"
fi

if [ "$RESTART" -eq 0 ]; then
    echo "Done (plasmashell not restarted)."
    exit 0
fi

echo "Restarting plasmashell..."
if systemctl --user is-active --quiet plasma-plasmashell.service 2>/dev/null; then
    systemctl --user restart plasma-plasmashell.service
elif command -v kquitapp6 >/dev/null && command -v kstart >/dev/null; then
    kquitapp6 plasmashell || true
    kstart plasmashell >/dev/null 2>&1 || (plasmashell --replace >/dev/null 2>&1 &)
else
    (plasmashell --replace >/dev/null 2>&1 &)
fi
echo "Done."
