#!/usr/bin/env bash
#
# Tests for scripts/get_mid_url.sh. A stub curl on PATH records the --config text it
# receives on stdin and answers with a canned response, so no instance is contacted.
#
#   tests/get_mid_url_test.sh

set -uo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
readonly ROOT
readonly SCRIPT="$ROOT/scripts/get_mid_url.sh"
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

mkdir "$WORK/bin"
cat >"$WORK/bin/curl" <<'STUB'
#!/usr/bin/env bash
for arg in "$@"; do
  if [ "$arg" = "--config" ]; then
    cat >"$STUB_CAPTURE"
    printf '%s\n' "$@" >"$STUB_ARGS"
    cat "$STUB_RESPONSE"
    exit 0
  fi
done
echo 200
STUB
chmod +x "$WORK/bin/curl"

export PATH="$WORK/bin:$PATH"
export STUB_CAPTURE="$WORK/config" STUB_RESPONSE="$WORK/response" STUB_ARGS="$WORK/args"
unset MID_INSTANCE_URL MID_INSTANCE_USERNAME MID_INSTANCE_PASSWORD

readonly STAMP="australia-02-11-2026__patch2-04-17-2026_04-29-2026_2044"
readonly INSTALLER="https://install.service-now.com/glide/distribution/builds/package/app-signed/mid/2026/04/29/mid.${STAMP}.linux.x86-64.zip"
readonly RECIPE="https://install.service-now.com/glide/distribution/builds/package/app-signed/mid-linux-container-recipe/2026/04/29/mid-linux-container-recipe.${STAMP}.linux.x86-64.zip"

failures=0
out="" status=0

respond() {
  printf '%s' "$1" >"$STUB_RESPONSE"
}

run() {
  rm -f "$STUB_CAPTURE"
  out=$(cd "$WORK" && "$SCRIPT" "$@" 2>&1)
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
printed() { [ "$out" = "$1" ]; }
curlNotCalled() { [ ! -e "$STUB_CAPTURE" ]; }
sentConfig() { [ "$(cat "$STUB_CAPTURE")" = "$1" ]; }
queried() { grep -q "^https://$1/api/now/table/sys_properties" "$STUB_ARGS"; }

writeEnv() {
  printf '%s\n' "$@" >"$WORK/.env"
}

respond "{\"result\":[{\"name\":\"mid.buildstamp\",\"value\":\"${STAMP}\"}]}"
writeEnv 'MID_INSTANCE_URL=https://example.service-now.com/' 'MID_INSTANCE_USERNAME=mid.server' 'MID_INSTANCE_PASSWORD=plain'

run
check "installer URL from the env file" succeeded
check "installer URL value" printed "$INSTALLER"
check "credentials reach curl on stdin" sentConfig 'user = "mid.server:plain"'

run --recipe
check "recipe URL" printed "$RECIPE"

run --buildstamp
check "raw buildstamp" printed "$STAMP"

run --password secret
check "--password is refused" failedWith "--password is not supported"
check "--password never reaches curl" curlNotCalled

run --password=secret
check "--password=VALUE is refused" failedWith "--password is not supported"

run --instance
check "missing option value" failedWith "--instance needs a value"

run --instance --check
check "option value that is another flag" failedWith "--instance needs a value"

writeEnv 'export MID_INSTANCE_URL="https://example.service-now.com"' \
  "MID_INSTANCE_USERNAME='mid.server'" \
  'MID_INSTANCE_PASSWORD="a b#c"' \
  'MID_INSTANCE_PASSWORD_OLD=ignored'
run
check "export lines and surrounding quotes" succeeded
check "only the surrounding quotes are removed" sentConfig 'user = "mid.server:a b#c"'

writeEnv 'MID_INSTANCE_URL=example.service-now.com' 'MID_INSTANCE_USERNAME=mid.server' \
  'MID_INSTANCE_PASSWORD=p"w\x'"'"'y'
run
check "quotes and backslashes are escaped for curl" sentConfig 'user = "mid.server:p\"w\\x'"'"'y"'

writeEnv 'MID_INSTANCE_URL=example.service-now.com' 'MID_INSTANCE_USERNAME=mid.server' 'MID_INSTANCE_PASSWORD=pw # note'
run
check "values are literal, as docker --env-file reads them" sentConfig 'user = "mid.server:pw # note"'

writeEnv 'MID_INSTANCE_URL=file.service-now.com' 'MID_INSTANCE_USERNAME=file-user' 'MID_INSTANCE_PASSWORD=file-pw'
MID_INSTANCE_URL=env.service-now.com MID_INSTANCE_USERNAME=env-user MID_INSTANCE_PASSWORD=env-pw run
check "the environment is used when it has the settings" sentConfig 'user = "env-user:env-pw"'
check "the environment's instance is queried" queried env.service-now.com

cp "$WORK/.env" "$WORK/other.env"
MID_INSTANCE_URL=env.service-now.com MID_INSTANCE_PASSWORD=env-pw run --env-file other.env
check "an explicit --env-file wins over the environment" sentConfig 'user = "file-user:file-pw"'
check "the env file's instance is queried" queried file.service-now.com

MID_INSTANCE_URL=env.service-now.com run
check "settings are never mixed across sources" failedWith "Set MID_INSTANCE_USERNAME/MID_INSTANCE_PASSWORD in the environment"
check "a partial environment never reaches curl" curlNotCalled

MID_INSTANCE_URL=x MID_INSTANCE_USERNAME=u MID_INSTANCE_PASSWORD=$'two\nlines' run
check "line breaks in credentials are refused" failedWith "must not contain line breaks"
check "line breaks never reach curl" curlNotCalled

respond '<html><body>Instance hibernating</body></html>'
run
check "non-JSON response gives a clear error" failedWith "did not return the expected JSON"

respond "{\"result\":[{\"name\":\"mid.buildstamp\",\"value\":null},{\"name\":\"mid.version\",\"value\":\"${STAMP}\"}]}"
run --buildstamp
check "null buildstamp falls back to mid.version" printed "$STAMP"

respond '{"result":[{"name":"mid.buildstamp","value":"x -O /etc/passwd_04-29-2026_2044"}]}'
run
check "buildstamp outside its alphabet is refused" failedWith "Unexpected characters in buildstamp"

respond '{"result":[]}'
run
check "missing buildstamp" failedWith "Neither mid.buildstamp nor mid.version"

respond '{"result":null}'
run
check "null result" failedWith "Neither mid.buildstamp nor mid.version"

respond '["unexpected"]'
run
check "JSON of the wrong shape gives a clear error" failedWith "did not return the expected JSON"

if [ "$failures" -ne 0 ]; then
  echo "$failures test(s) failed"
  exit 1
fi
echo "all tests passed"
