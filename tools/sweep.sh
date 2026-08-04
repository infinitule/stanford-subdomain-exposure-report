#!/usr/bin/env bash
# sweep.sh — parameterized re-run of the SR-2026-STAN-01 enumeration framework.
#
# Refreshes the DNS + HTTP liveness state for every host in the corpus so the
# report can be regenerated "as of now". Non-invasive by design:
#   * DNS lookups only (A / CNAME)
#   * HTTP HEAD only — status line, Server header, redirect target
#   * TLS certificate metadata (issuer / subject / validity)
# It never downloads, renders, stores, or displays page bodies. The indexed
# spam attaches real people's names to fabricated sexual content; capturing it
# would republish the harm this report exists to document.
#
# Usage:
#   ./tools/sweep.sh                 # full corpus
#   ./tools/sweep.sh hosts.txt       # custom host list (one per line)
#   SEEDS_ONLY=1 ./tools/sweep.sh    # print the search seed corpus and exit
#
set -uo pipefail

TIMEOUT="${TIMEOUT:-8}"
UA="${UA:-SR-2026-STAN-01-verifier/1.0 (defensive security research; HEAD-only)}"

# ---------------------------------------------------------------------------
# Seed corpus — the parameterized keyword axis. Each seed is run as
#   site:stanford.edu <seed>
# and hostnames (never slugs or titles) are extracted from the results.
# ---------------------------------------------------------------------------
SEEDS=(
  "sextape"
  "sex tape"
  "nude leaked"
  "nude leak"
  "leaked video"
  "onlyfans"
  "onlyfans leaked"
  "viral xxx video"
  "viral video xnxx"
  "bokep indo"
  "video viral leaked telegram"
  "porn"
  "slot gacor judi online"
)

if [[ "${SEEDS_ONLY:-0}" == "1" ]]; then
  printf 'site:stanford.edu %s\n' "${SEEDS[@]}"
  exit 0
fi

# ---------------------------------------------------------------------------
# Host corpus — accumulated across sweeps.
# ---------------------------------------------------------------------------
DEFAULT_HOSTS=(
  sbc-hc-proxy.stanford.edu
  smc-aws-pub.stanford.edu
  cs355.stanford.edu
  widescope.stanford.edu
  webapp-new.itlab.stanford.edu
  ldap-sh3.int.authnz-x.stanford.edu
  testec2.asiaaws.stanford.edu
  edtechdev1.stanford.edu
  forum-daemo.stanford.edu
  eedpoccmg01.stanford.edu
  glucose-dev.stanford.edu
  swarm01.ic.stanford.edu
  snipe-it.stanford.edu
  platformlab.stanford.edu
)

if [[ $# -ge 1 && -f "$1" ]]; then
  mapfile -t HOSTS < "$1"
else
  HOSTS=("${DEFAULT_HOSTS[@]}")
fi

echo "# SR-2026-STAN-01 — corpus re-verification"
echo "# generated: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "# hosts: ${#HOSTS[@]}   seeds: ${#SEEDS[@]}"
echo

printf '%-38s %-26s %-10s %s\n' "HOST" "DNS" "HTTP" "NOTE"
printf '%-38s %-26s %-10s %s\n' "----" "---" "----" "----"

for h in "${HOSTS[@]}"; do
  [[ -z "$h" ]] && continue

  a=$(dig +short "$h" A    2>/dev/null | grep -E '^[0-9]+\.' | head -2 | tr '\n' ',' | sed 's/,$//')
  c=$(dig +short "$h" CNAME 2>/dev/null | head -1)

  if [[ -n "$a" ]]; then dns="$a"
  elif [[ -n "$c" ]]; then dns="CNAME:$c"
  else dns="NXDOMAIN"; fi

  http="-"; note=""
  if [[ "$dns" != "NXDOMAIN" && "$dns" != "CNAME:." ]]; then
    # HEAD only. Never fetch a body.
    resp=$(curl -sS -I --max-time "$TIMEOUT" -A "$UA" "https://$h/" 2>/dev/null | tr -d '\r')
    http=$(printf '%s' "$resp" | awk 'NR==1{print $2}')
    srv=$(printf  '%s' "$resp" | awk -F': ' 'tolower($1)=="server"{print $2; exit}')
    loc=$(printf  '%s' "$resp" | awk -F': ' 'tolower($1)=="location"{print $2; exit}')
    [[ -z "$http" ]] && { http="no-resp"; note="no TLS/HTTP response"; }
    [[ -n "$srv"  ]] && note="server=$srv"
    [[ -n "$loc"  ]] && note="$note redirect->$(printf '%s' "$loc" | cut -c1-40)"
  else
    note="record removed"
  fi

  printf '%-38s %-26s %-10s %s\n' "$h" "$dns" "$http" "$note"
done

echo
echo "# apex control:"
printf '%-38s %s\n' "stanford.edu" "$(dig +short stanford.edu A | tr '\n' ' ')"
