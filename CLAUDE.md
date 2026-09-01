# ServiceNow MID Server Docker - Agent Guide

## Build Commands
- Build image: `docker build --platform=linux/amd64 -t midserver .`
- Build against your instance's current release:
  `docker build --platform=linux/amd64 --build-arg MID_INSTALLATION_URL="$(scripts/get_mid_url.sh)" -t midserver .`
- Run container: `docker run -d --name servicenow-mid --platform=linux/amd64 --env-file .env midserver`
- View logs: `docker logs -f servicenow-mid`
- Health: `docker inspect --format '{{.State.Health.Status}}' servicenow-mid`

`--env-file .env` is required. Without it `asset/init` exits 2 before the MID Server starts.

## Version Pins

Currently tracking the **Australia** family (Patch 2). All pins live in `Dockerfile`:

| What | Line | Value |
|---|---|---|
| Builder base image | 11 | `eclipse-temurin:21-jdk-alpine` (`$BUILDPLATFORM`) |
| MID installer URL | 18 | `australia-02-11-2026__patch2-04-17-2026_04-29-2026_2044` |
| Runtime base image | 63 | `almalinux:9.8` (`linux/amd64`) |
| EPEL release | 67 | `epel-release-latest-9` — floats within EL9, leave alone |

Line numbers are for the current recipe; re-derive them after a recipe refresh.

## Version Bump Procedure

1. `scripts/get_mid_url.sh --buildstamp` — read the instance's current MID buildstamp.
2. `scripts/get_mid_url.sh --recipe` — download and unpack that release's vendor recipe zip.
3. Replace `Dockerfile.unmodified`, `asset/*` and `META-INF/*` from the unpacked recipe.
4. Re-derive `Dockerfile` from the new `Dockerfile.unmodified` by re-applying the two
   `LOCAL MOD` `FROM` lines. Take the vendor's installer URL unless ours is newer.
5. `diff -u Dockerfile.unmodified Dockerfile` — must show **exactly two hunks**, both `FROM`
   lines. Any other hunk is drift.
6. Rebuild, then run the verification checks below.

### Verification checks

```bash
# signature verified with the current builder JDK
docker build --platform=linux/amd64 --progress=plain -t midserver . 2>&1 | grep "Successfully verified digital signature"

# OOTB config.xml sentinels still match asset/init's expectations
docker run --rm --platform=linux/amd64 --entrypoint sh midserver -c \
  'grep -oE "YOUR_INSTANCE\.service-now\.com/?|YOUR_MIDSERVER_NAME_GOES_HERE|YOUR_INSTANCE_USER_NAME_HERE|YOUR_INSTANCE_PASSWORD_HERE" agent/config.xml | sort -u'

# mandatory-parameter validation still fires (MID_SERVER_NAME omitted -> exit 2)
docker run --rm --platform=linux/amd64 -e MID_INSTANCE_URL=https://example.invalid \
  -e MID_INSTANCE_USERNAME=x -e MID_INSTANCE_PASSWORD=y midserver; echo "exit=$?"
```

## Gotchas

- **`Dockerfile.unmodified`, `asset/*`, `mid.env`, `mid-secrets.properties` and the EULA are
  ServiceNow-signed vendor content** (covered by `META-INF/MANIFEST.MF`). Never hand-edit
  them — replace them wholesale from a fresh recipe zip. Only `Dockerfile` carries local
  changes, and only on its two `FROM` lines.
- **Do not add files to `asset/`.** `Dockerfile` does `COPY asset/*`, so anything there is
  baked into the build context and the image. Local tooling goes in `scripts/`.
- **The runtime image is x86-64 only** ([KB2675992](https://support.servicenow.com/kb?id=kb_article_view&sysparm_article=KB2675992))
  and must keep `--platform=linux/amd64`; on Apple Silicon it runs under Rosetta. The builder
  stage never executes MID binaries, so it is architecture-independent and uses `$BUILDPLATFORM`.
- **Staying on EL9 is deliberate.** AlmaLinux 10 raises the x86-64 baseline to x86-64-v3
  (AVX2), which is a poor fit for emulation, and ServiceNow does not document RHEL 10 support.
- **`asset/validate_signature.sh` gates on a string match, not an exit code** (it looks for
  `jar verified.` in `jarsigner -verify -strict` output). A builder JDK bump can flip that to
  `jar verified, with signer errors` and fail the build. JDK 21 was verified working against
  the Australia Patch 2 zip. If it ever breaks, fall back to `eclipse-temurin:8-jdk-alpine`
  with `--platform=linux/amd64` — never by disabling `MID_SIGNATURE_VERIFICATION`.
- **`asset/init` hardcodes the OOTB `config.xml` placeholders.** If a release changes them,
  mandatory-parameter validation silently stops working. Both checks above cover this.
- `asset/init` exit codes: `0` normal shutdown, `1` download failure, `2` missing config
  parameter, `3` mutual-auth setup failure.
- **The pinned installer is only a bootstrap.** Once validated, the MID Server auto-upgrades
  to the instance's build. Keep it within a family or two of the instance regardless.

## ServiceNow Tooling

- `.mcp.json.example` wires up the `mcp-servicenow` server using `${MID_INSTANCE_*}`
  expansion, so one `.env` drives both it and the container. Copy it to `.mcp.json`
  (gitignored), point `command` at your checkout (here: `~/construction-mcp/mcp-servicenow`),
  and launch with `set -a; source .env; set +a; claude`.
  Useful tools: `get_system_properties` (buildstamp), `list_records` (check `ecc_agent`).
- The `sn-docs-harvester` skill refreshes `docs/servicenow-australia/`. Australia platform
  map: `8K~WUyyBmjUR0pLPxM8yeA`; subtrees `N~VhlzBMB0_33wUwBI_LtQ` (Containerized MID Server)
  and `PI3uSdVpplthtCwaKGDSBg` (Installing the MID Server).

## Code Style Guidelines
- Indentation: 2 spaces
- Naming: camelCase for functions, lowercase with underscores for files
- Error handling: Use proper exit codes and error messages
- Logging: Use consistent logging functions
- Comments: Add descriptive comments for complex operations
- Shell scripts: Follow conventional Bash scripting practices
- Parameter validation: Validate all input parameters
- Documentation: Update README.md for significant changes

## Repository Structure
- `Dockerfile`: build config — vendor recipe plus two `LOCAL MOD` lines
- `Dockerfile.unmodified`: vendor recipe, byte-identical to what ServiceNow signs
- `asset/`: vendor scripts; `asset/init` is the entrypoint and container initialization
- `scripts/get_mid_url.sh`: derives installer/recipe URLs from a live instance
- `docs/servicenow-australia/`: harvested official docs for the pinned release
- `META-INF/`: vendor jar signature (gitignored — a download artifact)
- `.env` (gitignored) vs `.env.template` (committed) vs `mid.env` (vendor sample)

Please maintain existing patterns when modifying code.
