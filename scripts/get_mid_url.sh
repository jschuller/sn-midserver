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
  -h, --help           Show this help

Settings come from MID_INSTANCE_URL / MID_INSTANCE_USERNAME / MID_INSTANCE_PASSWORD, all
from one source: the --env-file if given, else the environment if any of them is set
there, else .env. Env-file values are read literally, as docker --env-file reads them
(an optional `export ` and one pair of surrounding quotes are removed). The password is
never accepted as an argument: argv is visible through ps(1) and lands in shell history.

Examples:
  scripts/get_mid_url.sh --check
  docker build --platform=linux/amd64 \
    --build-arg MID_INSTALLATION_URL="$(scripts/get_mid_url.sh)" -t midserver .
USAGE
  exit "${1:-1}"
}

# Reads one value from the env file without exporting it into the caller's shell.
# Values are literal, as docker --env-file reads them; only an optional `export ` and
# one pair of matching surrounding quotes are removed. The last assignment wins.
loadEnvFile() {
  local file=$1 key=$2 value
  [ -f "$file" ] || return 0
  value=$(sed -n "s/^[[:space:]]*\(export[[:space:]]\{1,\}\)\{0,1\}${key}=//p" "$file" | tail -1 | tr -d '\r')
  if [ ${#value} -ge 2 ]; then
    case "$value" in
      \"*\"|\'*\') value=${value:1:${#value}-2} ;;
    esac
  fi
  printf '%s' "$value"
}

# Reads a setting from the chosen source: an env file path, or "" for the environment.
setting() {
  local from=$1 key=$2
  if [ -z "$from" ]; then
    printf '%s' "${!key:-}"
  else
    loadEnvFile "$from" "$key"
  fi
}

# Escapes a value for a double-quoted curl config string.
curlQuote() {
  local value=${1//\\/\\\\}
  printf '%s' "${value//\"/\\\"}"
}

requireValue() {
  if [ $# -lt 2 ] || [ -z "$2" ] || [ "${2#--}" != "$2" ]; then
    errorExit "$1 needs a value."
  fi
}

main() {
  local recipe=false check=false stampOnly=false
  local envFile="" instance="" username="" password from

  while [ $# -gt 0 ]; do
    case "$1" in
      --recipe)     recipe=true; shift ;;
      --buildstamp) stampOnly=true; shift ;;
      --check)      check=true; shift ;;
      --env-file)   requireValue "$@"; envFile=$2; shift 2 ;;
      --instance)   requireValue "$@"; instance=$2; shift 2 ;;
      --user)       requireValue "$@"; username=$2; shift 2 ;;
      --password|--password=*)
        errorExit "--password is not supported: argv is visible through ps(1) and shell history.
Set MID_INSTANCE_PASSWORD in the environment or in the env file instead." ;;
      -h|--help)    usage 0 ;;
      *)            echo "Unknown option: $1" 1>&2; usage ;;
    esac
  done

  # One source for all three settings, so a URL from one place never meets a password
  # from another.
  local sourceName
  if [ -n "$envFile" ]; then
    from=$envFile; sourceName=$envFile
  elif [ -n "${MID_INSTANCE_URL:-}${MID_INSTANCE_USERNAME:-}${MID_INSTANCE_PASSWORD:-}" ]; then
    from=""; sourceName="the environment"
  else
    from=.env; sourceName=.env
  fi

  [ -n "$instance" ] || instance=$(setting "$from" MID_INSTANCE_URL)
  [ -n "$username" ] || username=$(setting "$from" MID_INSTANCE_USERNAME)
  password=$(setting "$from" MID_INSTANCE_PASSWORD)

  if [ -z "$instance" ]; then
    errorExit "No instance. Set MID_INSTANCE_URL in ${sourceName} or pass --instance."
  fi
  if [ -z "$username" ] || [ -z "$password" ]; then
    errorExit "No credentials. Set MID_INSTANCE_USERNAME/MID_INSTANCE_PASSWORD in ${sourceName}."
  fi
  case "$username$password" in
    *$'\n'*|*$'\r'*) errorExit "Credentials must not contain line breaks." ;;
  esac

  # Accept https://host/, https://host, or a bare host.
  local host=${instance#*://}
  host=${host%%/*}

  local query="nameINmid.buildstamp,mid.version"
  local api="https://${host}/api/now/table/sys_properties?sysparm_query=${query}&sysparm_fields=name,value&sysparm_limit=10"

  # Credentials go in on stdin via --config, never in argv where ps(1) could read them.
  local response
  if ! response=$(printf 'user = "%s:%s"\n' "$(curlQuote "$username")" "$(curlQuote "$password")" \
      | curl -sS -f -m 30 --config - -H "Accept: application/json" "$api" 2>&1); then
    errorExit "Could not query ${host}: ${response}
Check the instance is awake (PDIs hibernate and are reclaimed after 10 idle days) and that the credentials in ${sourceName} are valid."
  fi

  # mid.buildstamp is the canonical property, but some releases only populate mid.version.
  local buildstamp
  if ! buildstamp=$(printf '%s' "$response" | python3 -c '
import json, sys
try:
    result = json.load(sys.stdin).get("result") or []
    rows = {r.get("name"): str(r.get("value") or "").strip() for r in result if isinstance(r, dict)}
except (ValueError, TypeError, AttributeError):
    sys.exit(1)
print(rows.get("mid.buildstamp") or rows.get("mid.version") or "")
'); then
    errorExit "${host} did not return the expected JSON. A hibernating PDI or a login page answers with HTML; wake the instance and retry."
  fi

  if [ -z "$buildstamp" ]; then
    errorExit "Neither mid.buildstamp nor mid.version is set on ${host}."
  fi

  # The buildstamp becomes part of a URL and a docker build arg: allow only its known alphabet.
  case "$buildstamp" in
    *[!A-Za-z0-9._-]*) errorExit "Unexpected characters in buildstamp from ${host}: $(printf '%q' "$buildstamp")" ;;
  esac

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
