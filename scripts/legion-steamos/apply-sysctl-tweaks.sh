#!/bin/bash
# Apply SteamOS performance sysctl tweaks for Legion Go 2.
# Persists across reboots in /etc/sysctl.d/99-legion-perf.conf.
#
# Requires sudo. Toggles steamos-readonly for the write.

set -e

if [ "$EUID" -ne 0 ]; then
    echo "Run with sudo." >&2
    exit 1
fi

echo "=== Disabling rootfs read-only ==="
steamos-readonly disable

echo ""
echo "=== Writing /etc/sysctl.d/99-legion-perf.conf ==="
cat > /etc/sysctl.d/99-legion-perf.conf << 'EOF'
# Legion Go 2 + SteamOS performance tweaks
# Rationale documented in repo docs/06-performance-tweaks.md

# 22 GB RAM + zram swap means we don't need to swap aggressively to disk
vm.swappiness=10

# Keep file cache around longer — fewer SSD reads for repeated game launches
vm.vfs_cache_pressure=50
EOF

echo ""
echo "=== Applying sysctl ==="
sysctl --system | tail -5

echo ""
echo "=== Restoring rootfs read-only ==="
steamos-readonly enable

echo ""
echo "=== Verify ==="
sysctl vm.swappiness vm.vfs_cache_pressure
