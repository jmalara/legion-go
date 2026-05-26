#!/bin/bash
# Pre-configure MoonDeck UI preferences on the Legion.
# Does NOT add a host entry — that requires interactive PIN pairing in Game Mode.
# Run as the deck user. No sudo needed (writes to ~/.config/).

set -e

SETTINGS=~/.config/moondeck/settings.json

if [ ! -f "$SETTINGS" ]; then
    echo "MoonDeck settings file not found. Open Decky and MoonDeck plugin at least once first." >&2
    exit 1
fi

BACKUP="$SETTINGS.bak-$(date +%Y%m%d%H%M%S)"
cp "$SETTINGS" "$BACKUP"
echo "Backed up to $BACKUP"

python3 - "$SETTINGS" <<'PYEOF'
import json, sys
path = sys.argv[1]
with open(path) as f:
    s = json.load(f)

# UI only — no host info (host needs PIN exchange)
s["enableMoondeckShortcuts"] = True
s["enableMoondeckButtonPrompt"] = True
s.setdefault("gameSession", {})["autoApplyAppId"] = True
s["gameSession"]["resumeAfterSuspend"] = True

s.setdefault("buttonPosition", {})["horizontalAlignment"] = "bottom"
s["buttonPosition"]["verticalAlignment"] = "right"

s.setdefault("buttonStyle", {})["showFocusRing"] = True
s["buttonStyle"]["theme"] = "Clean"

with open(path, "w") as f:
    json.dump(s, f, indent=4)

print("Updated. Diff-relevant fields:")
for k in ("enableMoondeckShortcuts", "enableMoondeckButtonPrompt", "gameSession", "buttonPosition", "buttonStyle"):
    print(f"  {k}: {s.get(k)}")
PYEOF

echo ""
echo "Restart Decky to pick up changes:"
echo "  sudo systemctl restart plugin_loader.service"
