#!/usr/bin/env bash
# Re-runs terraform apply until the A1 instance exists.
#   "Out of host capacity"  -> retry every INTERVAL s (+ jitter); this is the only error worth hammering
#   429 TooManyRequests     -> exponential backoff 5m..1h, so we never fight Oracle's rate limiter
#   anything else           -> 3 strikes then exit 1 (systemd restarts us after 10m) so a broken config can't spam the API
set -u
cd "$(dirname "$0")"
INTERVAL=${INTERVAL:-60}
backoff=300 strikes=0 n=0
terraform init -input=false -no-color >/dev/null || exit 1
while :; do
  n=$((n + 1))
  out=$(terraform apply -auto-approve -input=false -no-color 2>&1) && {
    echo "JACKPOT after $n attempts. private_ip=$(terraform output -raw private_ip)"
    exit 0
  }
  if grep -q "Out of host capacity" <<<"$out"; then
    strikes=0 backoff=300
    echo "attempt $n: out of capacity"
    sleep $((INTERVAL + RANDOM % 15))
  elif grep -q "TooManyRequests" <<<"$out"; then
    echo "attempt $n: rate limited, backing off ${backoff}s"
    sleep "$backoff"
    backoff=$((backoff * 2 > 3600 ? 3600 : backoff * 2))
  else
    strikes=$((strikes + 1))
    echo "attempt $n: unexpected error (strike $strikes/3)"
    grep -E "^Error" <<<"$out"
    [ "$strikes" -ge 3 ] && exit 1
    sleep 300
  fi
done
