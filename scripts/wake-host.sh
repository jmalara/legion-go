#!/bin/bash
# Wake the Windows host via Wake-on-LAN magic packet.
#
# Works on macOS and Linux (uses python3, no external WoL tools needed).
# Run from anywhere on the LAN.
#
# Usage:
#   wake-host.sh                    # uses defaults below
#   wake-host.sh <MAC>              # override MAC
#   wake-host.sh <MAC> <broadcast>  # override broadcast IP

set -e

# Defaults — Jerem's host
HOST_MAC="${1:-50-EB-F6-CE-2B-EB}"
BROADCAST="${2:-192.168.1.255}"
PORT=9

# Normalize MAC (allow : or - separators)
MAC_HEX=$(echo "$HOST_MAC" | tr -d ':-' | tr 'a-f' 'A-F')

if [ ${#MAC_HEX} -ne 12 ]; then
    echo "Invalid MAC: $HOST_MAC" >&2
    exit 1
fi

echo "Sending WoL magic packet:"
echo "  MAC:       $HOST_MAC"
echo "  Broadcast: $BROADCAST:$PORT"

python3 - <<PYEOF
import socket, sys

mac = "$MAC_HEX"
mac_bytes = bytes.fromhex(mac)

# Magic packet: 6 bytes of 0xFF + MAC repeated 16 times
packet = b'\xff' * 6 + mac_bytes * 16

s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
s.sendto(packet, ("$BROADCAST", $PORT))
s.close()

print(f"Sent {len(packet)} bytes to $BROADCAST:$PORT")
PYEOF

echo ""
echo "Host should be online in 30-60 sec. Test with:"
echo "  ping $BROADCAST"
echo "  or"
echo "  ssh <user>@<host-ip>"
