#!/usr/bin/env bash
#
# Derive the ServiceNow MID Server download URL from a live instance.
#
# There is no static "latest" link. Both the installer and the container recipe live at a
# path built from the instance's MID buildstamp, so the only reliable source is the
# instance itself:
#
#   buildstamp  australia-02-11-2026__patch2-04-17-2026_04-29-2026_2044
#   trailing    _MM-DD-YYYY_HHMM  ->  date path 2026/04/29
#   installer   .../app-signed/mid/2026/04/29/mid.<buildstamp>.linux.x86-64.zip
#   recipe      .../app-signed/mid-linux-container-recipe/2026/04/29/mid-linux-container-recipe.<buildstamp>.linux.x86-64.zip
#
# The same URL is available in the UI under MID Server > Downloads (UI page
# "mid_server_download_ui") if you would rather copy it by hand.

set -euo pipefail

readonly BASE_URL="https://install.service-now.com/glide/distribution/builds/package/app-signed"
readonly PLATFORM="linux.x86-64"

errorExit() {
  echo "ERROR: $1" 1>&2
  exit 1
}

usage() {
  cat <<'USAGE'
Usage: scripts/get_mid_url.sh [options]

Prints the MID Server installer download URL for the configured instance.

Options:
  --recipe             Print the Linux container recipe URL instead of the installer
  --buildstamp         Print only the raw buildstamp
  --check              Verify the URL returns HTTP 200 before printing it
  --env-file FILE      Env file to read credentials from (default: .env)
  --instance URL       Instance URL or hostname (overrides the env file)
  --user NAME          Instance username (overrides the env file)
  --password PASS      Instance password (overrides the env file)
  -h, --help           Show this help

Credentials come from MID_INSTANCE_URL / MID_INSTANCE_USERNAME / MID_INSTANCE_PASSWORD.

Examples:
  scripts/get_mid_url.sh --check
  docker build --platform=linux/amd64 \
    --build-arg MID_INSTALLATION_URL="$(scripts/get_mid_url.sh)" -t midserver .
USAGE
  exit "${1:-1}"
}

# Reads the env file without exporting it into the caller's shell.
loadEnvFile() {
  local file=$1 key=$2
  [ -f "$file" ] || return 0
  sed -n "s/^[[:space:]]*${key}=//p" "$file" | tail -1 | tr -d '"'"'"'\r'
}

main() {
  local recipe=false check=false stampOnly=false
  local envFile=".env" instance="" username="" password=""

  while [ $# -gt 0 ]; do
    case "$1" in
      --recipe)     recipe=true; shift ;;
      --buildstamp) stampOnly=true; shift ;;
      --check)      check=true; shift ;;
      --env-file)   envFile=${2:-}; shift 2 ;;
      --instance)   instance=${2:-}; shift 2 ;;
      --user)       username=${2:-}; shift 2 ;;
      --password)   password=${2:-}; shift 2 ;;
      -h|--help)    usage 0 ;;
      *)            echo "Unknown option: $1" 1>&2; usage ;;
    esac
  done

  [ -n "$instance" ] || instance=$(loadEnvFile "$envFile" MID_INSTANCE_URL)
  [ -n "$username" ] || username=$(loadEnvFile "$envFile" MID_INSTANCE_USERNAME)
  [ -n "$password" ] || password=$(loadEnvFile "$envFile" MID_INSTANCE_PASSWORD)

  if [ -z "$instance" ]; then
    errorExit "No instance. Set MID_INSTANCE_URL in $envFile or pass --instance."
  fi
  if [ -z "$username" ] || [ -z "$password" ]; then
    errorExit "No credentials. Set MID_INSTANCE_USERNAME/MID_INSTANCE_PASSWORD in $envFile."
  fi

  # Accept https://host/, https://host, or a bare host.
  local host=${instance#*://}
  host=${host%%/*}

  local query="nameINmid.buildstamp,mid.version"
  local api="https://${host}/api/now/table/sys_properties?sysparm_query=${query}&sysparm_fields=name,value&sysparm_limit=10"

  # Credentials go in on stdin via --config, never in argv where ps(1) could read them.
  local response
  if ! response=$(printf 'user = "%s:%s"\n' "$username" "$password" \
      | curl -sS -f -m 30 --config - -H "Accept: application/json" "$api" 2>&1); then
    errorExit "Could not query ${host}: ${response}
Check the instance is awake (PDIs hibernate and are reclaimed after 10 idle days) and that the credentials in ${envFile} are valid."
  fi

  # mid.buildstamp is the canonical property, but some releases only populate mid.version.
  local buildstamp
  buildstamp=$(echo "$response" | python3 -c '
import json, sys
rows = {r["name"]: r["value"].strip() for r in json.load(sys.stdin).get("result", [])}
print(rows.get("mid.buildstamp") or rows.get("mid.version") or "")
')

  if [ -z "$buildstamp" ]; then
    errorExit "Neither mid.buildstamp nor mid.version is set on ${host}."
  fi

  if [ "$stampOnly" = true ]; then
    echo "$buildstamp"
    return 0
  fi

  # The build date is the trailing _MM-DD-YYYY_HHMM of the buildstamp.
  local datePath
  datePath=$(echo "$buildstamp" | sed -n 's#.*_\([0-9][0-9]\)-\([0-9][0-9]\)-\([0-9]\{4\}\)_[0-9]\{4\}$#\3/\1/\2#p')
  if [ -z "$datePath" ]; then
    errorExit "Could not parse a build date out of buildstamp: ${buildstamp}"
  fi

  local url
  if [ "$recipe" = true ]; then
    url="${BASE_URL}/mid-linux-container-recipe/${datePath}/mid-linux-container-recipe.${buildstamp}.${PLATFORM}.zip"
  else
    url="${BASE_URL}/mid/${datePath}/mid.${buildstamp}.${PLATFORM}.zip"
  fi

  if [ "$check" = true ]; then
    local status
    status=$(curl -sIL -m 60 -o /dev/null -w '%{http_code}' "$url")
    if [ "$status" != "200" ]; then
      errorExit "Derived URL returned HTTP ${status}, expected 200:
${url}"
    fi
    echo "OK (HTTP 200): ${url}" 1>&2
  fi

  echo "$url"
}

main "$@"
