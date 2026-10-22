#!/usr/bin/env bash
#
# Lint a Dockerfile with BuildKit's build checks (`docker build --call=check`) without
# building it. No RUN step executes, so this needs neither a ServiceNow instance nor the MID
# installer download; only base-image metadata is resolved from the registry.
#
# The recipe cannot be fully built in CI: the final stage copies the MID installer that the
# first stage downloads from install.service-now.com and signature-verifies.
#
# Findings listed in ACCEPTED below are known and deliberate, and each is accepted once:
# any other finding, a second instance of an accepted one, or a Dockerfile that does not
# parse fails the check.
#
#   scripts/check_dockerfile.sh [DOCKERFILE]    (default: Dockerfile)
#
# Requires docker with buildx 0.15 or newer, and jq.

set -euo pipefail

# The Dockerfile frontend that runs the checks, pinned by digest so the rule set changes
# only when this line does (docker/dockerfile 1.27.1, published 2026-09-30).
readonly FRONTEND="docker/dockerfile:1.27.1@sha256:4edf897a3ffa55b89f906fc8cc78afdb3f1834cc9c7083565e611a8a7d5fe99e"

# "<rule>: <detail>", exactly as the frontend reports them.
readonly ACCEPTED=(
  # LOCAL MOD: the runtime stage is pinned to x86-64 on purpose (ServiceNow KB2675992).
  'FromPlatformFlagConstDisallowed: FROM --platform flag should not use constant value "linux/amd64"'
  # Placeholders in the vendor-signed recipe's ENV block, which asset/init reads. The rule
  # checks variable names, not values: that they stay empty is enforced by Dockerfile changing
  # only on its two FROM lines (compare Dockerfile.unmodified), so these cannot be edited here.
  'SecretsUsedInArgOrEnv: Do not use ARG or ENV instructions for sensitive data (ENV "MID_INSTANCE_PASSWORD")'
  'SecretsUsedInArgOrEnv: Do not use ARG or ENV instructions for sensitive data (ENV "MID_PROXY_PASSWORD")'
)

errorExit() {
  echo "ERROR: $1" 1>&2
  exit 1
}

ROOT=$(cd "$(dirname "$0")/.." && pwd)
readonly ROOT
dockerfile=${1:-$ROOT/Dockerfile}
[ -f "$dockerfile" ] || errorExit "Dockerfile not found: $dockerfile"
command -v docker >/dev/null || errorExit "docker is required"
command -v jq >/dev/null || errorExit "jq is required"

result=$(mktemp)
trap 'rm -f "$result"' EXIT

# Exit status 1 only means "findings"; the JSON result says what happened.
status=0
docker build --quiet --call=check,format=json --build-arg "BUILDKIT_SYNTAX=$FRONTEND" \
  -f "$dockerfile" "$ROOT" >"$result" || status=$?

jq -e 'type == "object"' "$result" >/dev/null 2>&1 \
  || errorExit "docker build --call=check gave no check result (exit $status): it needs buildx 0.15 or newer, or the frontend could not be resolved (see docker's output above)"

build_error=$(jq -r '.buildError.message // empty' "$result")
[ -z "$build_error" ] || errorExit "could not check $dockerfile: $build_error"

findings=$(jq -r '(.warnings // [])[] | "\(.ruleName): \(.detail)"' "$result")
[ "$status" -eq 0 ] || [ -n "$findings" ] \
  || errorExit "docker build --call=check failed (exit $status) without reporting findings"

# Multiset difference: an accepted finding that appears twice leaves one unexpected copy.
unexpected=$(comm -23 <(sort <<<"$findings") <(printf '%s\n' "${ACCEPTED[@]}" | sort))
if [ -n "$unexpected" ]; then
  echo "Unexpected Dockerfile check findings in $dockerfile:" 1>&2
  while IFS= read -r line; do printf '  %s\n' "$line"; done <<<"$unexpected" 1>&2
  exit 1
fi

accepted_seen=0
[ -z "$findings" ] || accepted_seen=$(wc -l <<<"$findings" | tr -d ' ')
echo "Dockerfile checks passed: $accepted_seen accepted finding(s), none unexpected."
