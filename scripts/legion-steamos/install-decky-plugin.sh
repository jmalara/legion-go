#!/bin/bash
# Install a Decky plugin from a GitHub release zip/tar.gz.
# For plugins not in the official Decky store (e.g., Legion Go 2 Brightness fix).
#
# Usage:
#   install-decky-plugin.sh <release-url> [plugin-name-override]
#
# Example:
#   install-decky-plugin.sh https://github.com/jorgemmsilva/decky-plugin-fix-lego2-brightness-cachyos/releases/download/v1.0.0/legion-go2-brightness.zip

set -e

if [ "$EUID" -ne 0 ]; then
    echo "Run with sudo." >&2
    exit 1
fi

URL="$1"
if [ -z "$URL" ]; then
    echo "Usage: $0 <release-url> [plugin-name-override]" >&2
    exit 1
fi

WORK=$(mktemp -d)
trap "rm -rf $WORK" EXIT

cd "$WORK"
echo "Downloading from $URL ..."
FNAME=$(basename "$URL")
curl -sL -o "$FNAME" "$URL"

case "$FNAME" in
    *.zip) unzip -oq "$FNAME" ;;
    *.tar.gz|*.tgz) tar xzf "$FNAME" ;;
    *) echo "Unknown archive type: $FNAME" >&2; exit 1 ;;
esac

PLUGIN_DIR=$(find . -name plugin.json -exec dirname {} \; | head -1)
if [ -z "$PLUGIN_DIR" ]; then
    echo "No plugin.json found in archive" >&2
    exit 1
fi

NAME="${2:-$(basename "$PLUGIN_DIR")}"
DEST="/home/deck/homebrew/plugins/$NAME"

echo "Installing to $DEST ..."
rm -rf "$DEST"
cp -r "$PLUGIN_DIR" "$DEST"
chown -R root:root "$DEST"

echo ""
echo "Restarting Decky ..."
systemctl restart plugin_loader.service
sleep 3

echo ""
echo "Done. Verify load:"
journalctl -u plugin_loader.service --since "10 seconds ago" --no-pager | grep -E "Loaded|found plugin" | tail -10
