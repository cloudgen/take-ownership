# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [2.0.0] - 2026-08-26

### Changed

- **Domain replace:** product is **take-ownership**. Ship unit `src/take-ownership`. `APP_NAME=take-ownership`, `VERSION=2.0.0`.
- Live work is **`action --path <folder> --ownership <user:group>`** (recursive chown, no symlink follow). `backup` / `restore` are unknown commands.
- Sudoers/JSON grant names **only** `${GLOBAL_BIN}/take-ownership` with `action --path <exact-folder> --ownership *` plus a `--json` twin. Generate/print/submit **fail closed** unless the global binary exists. **`--allow-test-local` is gone** (USER_BIN in sudoers is a security leak).
- Main menu has three work rows: `action`, `remove-project-sudoers`, `submit-sudoer-request` (Exit 9).
- Domain prefix `to_` (retired `fb_`).

### Removed

- Folder archive backup/restore, retention, `/var/backup` deposit.

## [1.11.0] - 2026-08-23

### Added

- **`menu` / `main` numbered work list.** On a real terminal, `folder-backup menu` (or `main`) prints four operational rows plus **9. Exit** (`backup` / `restore` / `remove-project-sudoers` / `submit-sudoer-request`). Labels are `verb: explain`. Off-TTY, `menu` is help (JSON help with `--json`); `--quiet` does not swallow that help. Empty argv stays help. Self-managed, `version`/`about`, and test-purpose grant-emit verbs stay off the list. Law: **requirement-shell-cli-default-interaction** (Gap closed) · CLI-interface **1.6.0**. Suite **TP-CLI-13..16**.

## [1.10.0] - 2026-08-23

### Changed

- **Sudoers emit matches `backup <folder>`.** `print-sudoers` / JSON grant now use sudoers `*` (one extra operand): text `… folder-backup backup *` and `restore *` (plus `--json` argv lines); JSON `args: ["backup", "*"]` / `["restore", "*"]`. Verb-only exact-argv is withdrawn (INC-20260823-001). Law: three-layer **1.11.0** AC-25 · sudoer-json **1.3.0**. Suite **TP-FOLDER-BACKUP-26 / 26b**.
- Host fragment is still admin-installed. Type 0 does not write `/etc`. Deposit internals may still use `sudo -n mkdir`/`cp` when not already root.

## [1.9.0] - 2026-08-17

### Added

- Law **`requirement-operator-readable-error`**: blocking errors must be understandable (what happened / next step). Suite **TP-FOLDER-BACKUP-25 / 25b / 25c**. Portable: **`LM-OPERATOR-READABLE-ERROR`** · **`SK-OPERATOR-READABLE-ERROR`** · **`CL-OPERATOR-READABLE-ERROR`**.
- **`generate-sudoer-request [path]`** writes a local JSON sudoer file (compact; `backup` and `restore`) and verifies it. Default: `~/.config/folder-backup/sudoer-request-<user>.json`. Does not write `/etc` or inbound. When `sudoer-cli` is present, `json-to-sudoers` must still list both verbs. Next step is `submit-sudoer-request <path>`.
- Suite **TP-FOLDER-BACKUP-24 / 24b / 24c / 24d**. Law: three-layer **1.10.0** AC-23/24 · domain **1.6.1** · CLI **1.3.1** · sudoer-json **1.2.0**. Incident **INC-20260817-002**.

### Changed

- **`submit-sudoer-request` default handoff is compact JSON** (same grant as pretty `print-sudoers` dual) so sibling convert keeps both verbs. Inbound fail-closed copy names the missing grant, the request id, and `generate-sudoer-request`.
- **Independent generate (sacred):** any sudoer generate is a Type 0 subcommand that writes a dest tests and review can read without sudo. Submit temp / inbound / `/etc` are not that dest.

## [1.8.2] - 2026-08-17

### Added

- **`submit-sudoer-request` defaults to `update`** when this user’s host fragment exists under `/etc/sudoers.d/folder-backup-<user>` (or legacy `folder-backup`). Otherwise **add**. `--update` / `--add` override. Other users’ fragments do not count. `about --json` reports `host_sudoers_present`.
- Suite **TP-FOLDER-BACKUP-23 / 23b** (`SUDOERS_D_DIR` isolate). Law: three-layer **1.8.0** AC-22.

## [1.8.1] - 2026-08-17

### Added

- Submit **inbound fidelity** (AC-9 / three-layer AC-21): when the queued request file is readable, `submit-sudoer-request` **fails closed** if sibling re-encode dropped `backup` or `restore`. Purpose text is not completeness.
- Suite **TP-FOLDER-BACKUP-22e / 22f**: pretty emit through real `sudoer-cli` keeps both verbs; stub inbound body is read (not only file count).
- Law: `requirement-sudoer-json-file` **1.1.0** · three-layer **1.7.0**. Incident **INC-20260817-001**.

## [1.8.0] - 2026-08-15

### Changed

- **Sudoers grant is the project command only.** `print-sudoers` / submit emit `${GLOBAL_BIN}/folder-backup backup` and `restore` (JSON dual written as `<draft>.json`). No `mkdir`/`cp`/`tar`/`rm`/`install`/`chmod` Cmnds — those extra tools increased complexity and weakened security.
- **Warning:** Runtime deposit/restore/retention still call `sudo -n mkdir`/`cp`/`tar`/`rm`. **Do not replace** a working OS-tool host fragment with this grant until `backup`/`restore` re-exec via the project command. Submit **refuses** leftover OS-tool files (AC-7).
- Law: `requirement-sudoer-json-file` **1.0.1** · three-layer **1.6.0** (JSON body deferred) · domain **1.4.1**
- Suite **TP-FOLDER-BACKUP-22 / 22b / 22c**; 01/01c/01d/02 assert the new grant shape.

## [1.7.1] - 2026-08-15

### Changed

- **`submit-sudoer-request`** targets sudoer-cli’s **public inbound** `/var/sudoer-cli/sudoer-request` (mode 3773). Sibling CLI allocates the JSON request. This CLI does **not** write `/etc` and does **not** `mkdir` inbound.
- Detect order: `SUDOER_QUEUE_INBOUND` → `${SUDOER_PUBLIC_ROOT}/sudoer-request` → F4 `…/sudoer-request` → legacy `sudoer-approving` last.
- Help/about name the public inbound; `prompt_*` consume `TTY`; submit scratch uses `util_mktemp`.
- Law: three-layer **1.5.0** (AC-16–19) · domain **1.4.0** · CLI interface **1.1.0**
- Suite **TP-FOLDER-BACKUP-21 / 21b** (public preferred; env override wins; no Type 0 mkdir)

## [1.7.0] - 2026-08-14

### Added

- **Detect sudoer-cli and sudoer-adm** on `about` (human + `--json`): path / absent / inbound writable.
- **`submit-sudoer-request`** (Type 0): queue this product's sudoers fragment into the inbound approval folder via sudoer-cli. Does **not** write `/etc`. Requires sudoer-cli + sudoer-adm + writable `sudoer-approving`. Flags: `--purpose`, `--update`, optional file operand, same `--allow-test-local` gate as `print-sudoers`.
- Law: `requirement-domain-folder-backup` 1.3.0 · `requirement-three-layer-privilege-model` 1.4.0 §2.3.3c
- Suite **TP-FOLDER-BACKUP-19 / 20** · help/about **TP-CLI-04 / 06** fields

### Changed

- Version SSOT **1.7.0**
- `print-sudoers` fragment now starts with `# Purpose:` (shared helper for submit)

## [1.6.1] - 2026-08-13

### Changed

- **Bootstrap origin** is now sibling **cli-template** (Type 0 local-only template). Direction **A → B only**. `selfmanaged` is retired history, not a live hop.
- Ship unit Type 0 body rebuilt from `cli-template`, then domain (`fb_*`) re-extended. Online / Type O remain absent (already absent on A).
- Law: `requirement-bootstrap-chain` **2.0.0**; class / domain / shell notes retargeted.

## [1.6.0] - 2026-08-12

### Added

- **Retention after successful backup** (per project basename under deposit):
  - **`MAX_DAILY_BACKUPS`** default **5** — prune oldest same-day `N` until ≤5
  - **`MAX_TOTAL_BACKUPS`** default **30** — prune oldest (day then `N`) until ≤30
  - Order: daily prune, then total prune
- **Sudoers** allowlisted `rm -f` of deposit `*.tar.gz` for root-owned prune
- Law: `requirement-folder-archive-backup-retention-daily` · `requirement-folder-archive-backup-retention-total` (molds LM-*-RETENTION-*)
- Suite **TP-FOLDER-BACKUP-17 / 17b / 18 / 18b**

### Changed

- Version SSOT **1.6.0**
- Type 0 deposit when `BACKUP_ROOT` notation dir is user-writable (tests / custom roots)
- `about` / help report retention caps; backup JSON includes retention_* fields

## [1.5.0] - 2026-08-12

### Fixed

- **Restore dest gate (INC-20260812-001)** — pure ban on all `/etc/*` blocked legitimate homes such as `/etc/sudo-adm`. Gate is now **whitelist-oriented**:
  - **W-ETC-USER:** allow `/etc/{{username}}` and children for the **invoking** user only
  - **Hard deny:** exact `/etc`, **`/etc/passwd`**, deposit tree, other FHS under-prefixes not on whitelist
  - **W-HOME:** invoking passwd home (and under) still allowed when not already covered

### Changed

- Version SSOT **1.5.0**
- `requirement-folder-archive-backup` **1.2.0** §2.6b.2a (AC-15..18)
- Mold **`LM-FOLDER-ARCHIVE-BACKUP`** **1.2.0** §2.8b
- Suite **TP-FOLDER-BACKUP-16**

## [1.4.4] - 2026-08-09

### Fixed

- **Multi-user project-sudoers-file overwrite** — draft and installed basenames now include the **user suffix** so admin install for user A does not overwrite user B:
  - Draft: `~/.config/folder-backup/sudoers.fragment-<user>` (legacy `sudoers.fragment` still discoverable)
  - Host: `/etc/sudoers.d/folder-backup-<user>` (legacy `/etc/sudoers.d/folder-backup` still probed)
- **`remove-project-sudoers` multi-draft** — lists drafts under config and lets the user choose interactively; non-interactive requires an explicit path. Suite **TP-FOLDER-BACKUP-15b**.

### Changed

- Version SSOT **1.4.4**; three-layer REQ **1.3.0** (AC-14/AC-15); term `project-sudoers-file` portable paths.

## [1.4.3] - 2026-08-09

### Fixed

- **Global/local install mode** — managed binary now uses absolute mode **`0755`**. Prior `chmod +x` after `mktemp` (`0600`) produced **`0711`** (`rwx--x--x`): shell ship unit was not readable by non-owners, so normal users could not run a root global install. Re-running `install` without `--force` also **heals** broken `0700`/`0711` modes. Suites **TP-LC-09**, **TP-LC-10**.

### Changed

- Version SSOT **1.4.3**; `requirement-shell-local-self-management` **1.2.0** §2.3.1 multi-user mode law; project-folder install mode note.

## [1.4.2] - 2026-08-09

### Fixed

- **`remove-project-sudoers` honesty** — probe `/etc/sudoers.d/folder-backup` instead of hedging “if any”; when host elev is present, warn **STILL ACTIVE** and give admin leave-elev (`sudo rm` and/or install-script `uninstall`); when absent, say host fragment also absent. JSON includes `host_fragment_present`. Suite **TP-FOLDER-BACKUP-15**.

### Changed

- Version SSOT **1.4.2**; three-layer REQ §2.3.3b / AC-13 probe wording.

## [1.4.1] - 2026-08-09

### Added

- **`remove-project-sudoers [path]`** — Type 0 removes the **project-sudoers-file** draft only (default `~/.config/folder-backup/sudoers.fragment`); confirm or `--force`; refuses `/etc`; warns installed host fragment is separate (admin script `uninstall`). Suite **TP-FOLDER-BACKUP-15**.

### Changed

- Version SSOT **1.4.1**; domain + three-layer REQs §2.3.3b; mold portable §2.3.3b.

## [1.4.0] - 2026-08-09

### Added

- **`print-sudoers-install-script [path]`** — Type 0 generates an admin shell script (prefer `/dev/shm/{{APP_NAME}}-<user>-sudoers-admin.sh`) with `install` / `uninstall` / `replace` / `status` so a sudo-capable account can install or remove the **project-sudoers-file** under `/etc/sudoers.d/` without the CLI writing `/etc`.
- Terminology **`project-sudoers-file`** (draft path + handoff); suite **TP-FOLDER-BACKUP-14**.
- Harness aligned from RAM genesis (S11–S12 elev tables + **S13** trust tier) then pushed portable deltas back to RAM/HD genesis.

### Changed

- Version SSOT **1.4.0**; domain/three-layer REQs document admin-script workflow.
- Help/examples include install-script handoff for leaving test elevation (`uninstall`).

## [1.3.0] - 2026-08-09

### Security

- **Sudoers trust tiers:** global managed binary = production; local-only = **test mode only** (user can rewrite `~/.local/bin` and stage content).
- `print-sudoers` refuses non-production tier unless `--allow-test-local` or `ALLOW_TEST_LOCAL_SUDOERS=1`.
- Fragment headers and human output warn **TEST MODE ONLY / uninstall soon** for test_local.
- Stage allowlists tightened to **per-user** roots (`folder-backup-<user>/`), not broad `folder-backup-*`.
- Harness: `SK-CREATE-SUDOERS-FILE` v1.1, checklist **S11**, `LM-THREE-LAYER-PRIVILEGE-MODEL` v2.1, product three-layer requirement v1.2.
- Re-review: `reviews/reports/2026-08-09-sudoers-security-folder-backup.md` (Pass test only). WS record marked **test / to-uninstall**.

### Added

- `install --global` / `FORCE_GLOBAL=1` to target `/usr/local/bin` when writable.
- `about` reports `sudoers_trust_tier`.
- Uninstall warns that `/etc/sudoers.d/folder-backup` is not removed.
- Suite: TP-FOLDER-BACKUP-01b refuse without allow flag; 01c restore stage with allow flag.

### Changed

- Version SSOT **1.3.0** on ship unit.
- README / SECURITY.md document production vs test elevation paths.

## [1.2.1] - 2026-08-03

### Added

- Config repository identity: `REPO_USER=cloudgen`, `REPO_NAME=folder-backup` (project-repository alignment; `SCRIPT_URL` remains empty for local-only install).
- `about` / `--json about` report `repository` / `repo_user` / `repo_name` / `script_url`.
- Product README documents source repository and `REPO_*` env vars.

## [1.2.0] - 2026-08-03

### Added

- `restore <archive|prefix> [dest]` with count verification after extract.
- Default restore destination host is **hard-disk** (`PROJECTS_ROOT/<project>`) — reverse of ram-drive-first; override with `--ram`, `--disk`, or an explicit path.
- Sudoers fragment lines for restore: allowlisted `cp` from deposit into per-user stage (Type 0 `tar -xzf` after).
- Domain surface and ops requirement coverage for restore; suite cases TP-FOLDER-BACKUP-11..13.
- Product harness skill `SK-FOLDER-ARCHIVE-BACKUP` and related sudoers create skill.

### Changed

- Backup flow reports source/archive file and member counts; deposit size verification.
- `print-sudoers` includes `tar -tzf` list allowlist and restore stage fetch.
- Version SSOT **1.2.0** on ship unit.

## [1.1.0] - 2026-08-03

### Added

- Post-deposit verification (stage counts + deposit size; optional elevated `tar -tzf` re-list).
- `print-sudoers` allowlist for deposit listing.

### Fixed

- Fail-closed deposit path retained when sudoers missing.

## [1.0.0] - 2026-08-03

### Added

- Initial specialized product **folder-backup**: local install/uninstall, backup with elevated deposit, print-sudoers, isolated test suite.
