#!/usr/bin/env bash
#
# Tests for scripts/check_dockerfile.sh. A stub docker on PATH records its arguments and
# answers with a canned check result and exit status, so no Docker daemon is needed.
#
#   tests/check_dockerfile_test.sh

set -uo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
readonly ROOT
readonly SCRIPT="$ROOT/scripts/check_dockerfile.sh"
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

mkdir "$WORK/bin"
cat >"$WORK/bin/docker" <<'STUB'
#!/usr/bin/env bash
printf '%s\n' "$@" >"$STUB_ARGS"
cat "$STUB_RESPONSE"
exit "$(cat "$STUB_STATUS")"
STUB
chmod +x "$WORK/bin/docker"

export PATH="$WORK/bin:$PATH"
export STUB_RESPONSE="$WORK/response" STUB_STATUS="$WORK/status" STUB_ARGS="$WORK/args"

readonly PLATFORM_FINDING='{"ruleName":"FromPlatformFlagConstDisallowed","detail":"FROM --platform flag should not use constant value \"linux/amd64\""}'
readonly PASSWORD_FINDING='{"ruleName":"SecretsUsedInArgOrEnv","detail":"Do not use ARG or ENV instructions for sensitive data (ENV \"MID_INSTANCE_PASSWORD\")"}'
readonly PROXY_FINDING='{"ruleName":"SecretsUsedInArgOrEnv","detail":"Do not use ARG or ENV instructions for sensitive data (ENV \"MID_PROXY_PASSWORD\")"}'

failures=0
out="" status=0

respond() {
  printf '%s' "$1" >"$STUB_RESPONSE"
  printf '%s' "$2" >"$STUB_STATUS"
}

run() {
  out=$("$SCRIPT" "$@" 2>&1)
  status=$?
}

check() {
  local name=$1; shift
  if "$@"; then
    echo "ok   $name"
  else
    echo "FAIL $name"
    echo "     status=$status output: $out"
    failures=$((failures + 1))
  fi
}

succeeded() { [ "$status" -eq 0 ]; }
failedWith() { [ "$status" -ne 0 ] && [[ "$out" == *"$1"* ]]; }
passedArg() { grep -qxF -- "$1" "$STUB_ARGS"; }

respond "{\"warnings\":[$PLATFORM_FINDING,$PASSWORD_FINDING,$PROXY_FINDING]}" 1
run
check "the known findings are accepted" succeeded
check "checks run without building" passedArg "--call=check,format=json"
check "the frontend is pinned by digest" grep -qE '^BUILDKIT_SYNTAX=docker/dockerfile:[0-9.]+@sha256:[0-9a-f]{64}$' "$STUB_ARGS"
check "the repo Dockerfile is checked by default" passedArg "$ROOT/Dockerfile"

respond '{"warnings":null}' 0
run
check "no findings" succeeded

respond "{\"warnings\":[$PLATFORM_FINDING,{\"ruleName\":\"SecretsUsedInArgOrEnv\",\"detail\":\"Do not use ARG or ENV instructions for sensitive data (ARG \\\"MID_TOKEN\\\")\"}]}" 1
run
check "a new finding fails" failedWith 'Unexpected Dockerfile check findings'
check "the new finding is named" failedWith 'MID_TOKEN'

respond "{\"warnings\":[$PLATFORM_FINDING,$PLATFORM_FINDING,$PASSWORD_FINDING,$PROXY_FINDING]}" 1
run
check "a second instance of an accepted finding fails" failedWith 'Unexpected Dockerfile check findings'

respond "{\"warnings\":[$PLATFORM_FINDING,$PASSWORD_FINDING,$PASSWORD_FINDING,$PROXY_FINDING]}" 1
run
check "a repeated password finding fails" failedWith 'MID_INSTANCE_PASSWORD'

respond '{"warnings":null,"buildError":{"message":"dockerfile parse error on line 1"}}' 1
run
check "a Dockerfile that cannot be checked fails" failedWith "dockerfile parse error on line 1"

respond 'unknown flag: --call' 1
run
check "a docker without --call fails" failedWith "gave no check result"

respond '{"warnings":null}' 1
run
check "a failed check with no findings fails" failedWith "without reporting findings"

run "$WORK/no-such-Dockerfile"
check "a missing Dockerfile fails" failedWith "Dockerfile not found"

if [ "$failures" -ne 0 ]; then
  echo "$failures test(s) failed"
  exit 1
fi
echo "all tests passed"
