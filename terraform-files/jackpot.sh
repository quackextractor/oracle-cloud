#!/bin/sh
# Re-runs terraform apply until the A1 instance exists. POSIX sh: runs inside the alpine terraform image.
#   "Out of host capacity"  -> retry every INTERVAL s (+ jitter); this is the only error worth hammering
#   429 TooManyRequests     -> exponential backoff 5m..1h, so we never fight Oracle's rate limiter
#   anything else           -> 3 strikes, wait 10m, exit 1 (docker restarts us) so a broken config can't spam the API
set -u
cd "$(dirname "$0")"
INTERVAL=${INTERVAL:-60}
backoff=300 strikes=0 n=0
terraform init -input=false -no-color >/dev/null || exit 1
while :; do
  n=$((n + 1))
  if out=$(terraform apply -auto-approve -input=false -no-color 2>&1); then
    echo "JACKPOT after $n attempts. private_ip=$(terraform output -raw private_ip)"
    exit 0
  fi
  if printf '%s' "$out" | grep -q "Out of host capacity"; then
    strikes=0 backoff=300
    echo "attempt $n: out of capacity"
    sleep $((INTERVAL + $(od -An -N1 -tu1 /dev/urandom) % 15))
  elif printf '%s' "$out" | grep -q "TooManyRequests"; then
    echo "attempt $n: rate limited, backing off ${backoff}s"
    sleep "$backoff"
    backoff=$((backoff * 2 > 3600 ? 3600 : backoff * 2))
  else
    strikes=$((strikes + 1))
    echo "attempt $n: unexpected error (strike $strikes/3)"
    printf '%s\n' "$out" | grep -E "^Error"
    [ "$strikes" -ge 3 ] && sleep 600 && exit 1
    sleep 300
  fi
done
