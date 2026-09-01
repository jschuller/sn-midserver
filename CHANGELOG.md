# Changelog

All notable changes to this project are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Changed
- **MID Server bumped from Xanadu Patch 4a (Jan 2025) to Australia Patch 2 (Apr 2026)**,
  four release families forward. Vendor recipe (`Dockerfile.unmodified`, `asset/`,
  `META-INF/`) refreshed from ServiceNow's Australia Linux container recipe.
- Runtime base image `almalinux:9.2` → `almalinux:9.8`. 9.2 is an EOL point release, so
  every build was replaying years of `dnf update --security` deltas under emulation.
- Builder base image `eclipse-temurin:8-jdk-alpine` → `eclipse-temurin:21-jdk-alpine`,
  switched to `--platform=$BUILDPLATFORM`. That stage only downloads, signature-verifies
  and unzips the installer, so it is architecture-independent and now builds natively on
  Apple Silicon instead of under emulation. (Temurin 8's Alpine image is amd64-only, which
  is what previously forced emulation there.)
- `.gitignore`: `*.env` was silently untracking `mid.env`, a vendor artifact. Added a
  `!mid.env` negation.

### Added
- `scripts/get_mid_url.sh` — derives the MID installer or container-recipe download URL
  from a live instance. There is no static "latest" link: the URL is built from the
  instance's MID buildstamp, so this reads `mid.buildstamp` (falling back to `mid.version`,
  which is what the Australia family actually populates) and composes the path.
  Credentials are passed to `curl` on stdin rather than argv.
- `docs/servicenow-australia/` — official ServiceNow docs for the pinned release
  (Containerized MID Server, Installing the MID Server).
- `.mcp.json.example` — wires up the `mcp-servicenow` MCP server using `${MID_INSTANCE_*}`
  expansion so one `.env` drives both it and the container. `.mcp.json` itself is gitignored.
- `README.md`: Versions table, Apple Silicon / Rosetta rationale, and an
  "Updating to a newer MID release" runbook. Hero image is now actually referenced.
- `CLAUDE.md`: version pin locations, bump procedure, and gotchas (vendor-signed files,
  the `jarsigner` string-match gate, `asset/init` sentinels and exit codes).

### Notes
- The runtime image stays pinned to `linux/amd64`. The MID Server ships x86-64 binaries
  only ([KB2675992](https://support.servicenow.com/kb?id=kb_article_view&sysparm_article=KB2675992)),
  so it runs under Rosetta on Apple Silicon.
- ServiceNow's own Australia recipe still ships `almalinux:9.2` and JDK 8; the base image
  bumps here are deliberately ahead of the vendor. `asset/` is byte-identical between the
  Xanadu and Australia recipes.
- Verified against a live PDI on Australia Patch 2: clean `--no-cache` build, signature
  verified under JDK 21, container healthy, MID Server registered with `status=Up` and
  matching version, ECC queue processing.
