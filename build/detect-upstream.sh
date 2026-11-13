#!/usr/bin/env bash
# Prints the latest upstream Arch Linux cloud image version on stdout
# (e.g. 20261101.620452), parsed from the arch-boxes directory listing at
#   https://geo.mirror.pkgbuild.com/images/
# Each build lives in v<YYYYMMDD>.<build id>/; the version is that name
# without the leading "v". A directory only counts once it lists both the
# cloudimg qcow2 and its .SHA256 file (a build may be listed before every
# file of it is synced). Runs in the upstream-watch reusable workflow
# (no KVM needed): keep it portable bash + curl + grep + sort only.

set -euo pipefail

URL='https://geo.mirror.pkgbuild.com/images/'
UA='openimages-ci'

listing=$(curl -fsL -A "$UA" "$URL")
if [[ -z "$listing" ]]; then
  echo "::error::could not fetch $URL" >&2
  exit 1
fi

candidates=$(printf '%s\n' "$listing" \
  | grep -oE 'href="v[0-9]{8}\.[0-9]+/"' \
  | sed -E 's#href="v([0-9]{8}\.[0-9]+)/"#\1#' \
  | sort -uV -r \
  | head -n3)

for v in $candidates; do
  files=$(curl -fsL -A "$UA" "${URL}v${v}/" || true)
  img="Arch-Linux-x86_64-cloudimg-${v}.qcow2"
  if grep -qF "\"${img}\"" <<<"$files" && grep -qF "\"${img}.SHA256\"" <<<"$files"; then
    printf '%s\n' "$v"
    exit 0
  fi
done

echo "::error::no complete Arch Linux cloudimg build found in $URL" >&2
exit 1
