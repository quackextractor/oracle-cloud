#!/bin/sh
# Usage: ./status.sh [ssh-host]   (default: server)
# Prints a summary of the jackpot retry loop, read from oracle-cloud/jackpot.log on the server.
HOST=${1:-server}
ssh "$HOST" sh -s <<'REMOTE'
C=oracle-cloud-jackpot-1
F=oracle-cloud/jackpot.log
docker inspect "$C" >/dev/null 2>&1 || { echo "No jackpot container on this host."; exit 1; }
[ -f "$F" ] || { echo "No $F yet. The loop writes it after its first attempt."; exit 1; }
row() { printf '%-18s %s\n' "$1" "$2"; }
row "Container"       "$(docker ps -a --filter name=$C --format '{{.Status}}')"
row "Host up since"   "$(uptime -s)"
row "Log since (UTC)" "$(head -1 $F | cut -c1-16 | tr T ' ')"
row "Attempts"        "$(grep -c ' attempt ' $F)"
row "Out of capacity" "$(grep -c 'out of capacity' $F)"
row "Rate limited"    "$(grep -c 'rate limited' $F)"
row "Other errors"    "$(grep -c 'unexpected error' $F)"
row "Last line"       "$(tail -1 $F)"
echo
grep JACKPOT $F || echo "No instance yet."
REMOTE
