# take-ownership - Take Unix ownership of a named folder with a narrow sudo grant

![Version](https://img.shields.io/badge/Version-2.7.0-blue?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)
[![CIAO](https://img.shields.io/badge/Philosophy-CIAO%20(Caution%20%E2%80%A2%20Intentional%20%E2%80%A2%20Anti--fragile%20%E2%80%A2%20Over--engineered)-purple.svg)](https://github.com/cloudgen/ciao)
[![Stars](https://img.shields.io/github/stars/cloudgen/take-ownership?style=flat-square)](https://github.com/cloudgen/take-ownership)

**take-ownership** lets you submit a sudoers grant for one folder, then run `take-ownership action --path <folder> --ownership user:group` to recursively take that folder’s ownership (no symlink follow). Only the globally installed binary (`/usr/local/bin/take-ownership`) may appear in the sudoer file. A local `~/.local/bin` copy is fine for help, but grant emit fails closed until the global program exists. There is no online `curl|sh` install.

| You (your own login) | Admin / already root | Not this |
|----------------------|----------------------|----------|
| Install locally, generate and submit a grant for one folder, run `action` after the grant exists | Install into `/usr/local/bin` and install the sudoers fragment | No download-and-run install channel; a normal login does not write `/etc`; USER_BIN is never in sudoers |

## Features

- **Local self-management**: `install`, `uninstall`, `where-is-me`, `version`, `about`, `help`, `menu` / `main` (TTY numbered work list: action, then family **sudoers** with a grant/draft submenu; empty argv is the same list)
- **Take ownership**: `action --path <folder> --ownership <user:group>` — recursive chown, no symlink follow, refuse system roots. On a real terminal, `action` (or menu `1`) lists granted folders by number and uses this login’s `user:group` with no extra prompt
- **Narrow sudoers**: exact `--path`, exact `--ownership user:group`, **global binary only** (no `--allow-test-local`)
- **Sudoer approval submit**: `generate-sudoer-request --path <folder> --ownership <user:group>` (alias `generate-sudoer-json`) writes a local JSON grant you can review. `--ownership` is an existing `user:group` (never `*`, never a directory listing). `submit-sudoer-request` hands it to sudoer-cli (does not write `/etc`, does not `mkdir` inbound)
- **Fail-closed**: missing global binary, missing user:group, refuse-list paths, swapped flags
- **CIAO / CIAO-Lite** defensive design (Protection Zones, `out_*` output SSOT)

## Quick Installation

**Local (your own login, no root needed):**

```sh
# From this repository checkout
sh src/take-ownership install
# or force refresh after updates
sh src/take-ownership install --force

# Ensure ~/.local/bin is on PATH, then:
take-ownership version
```

**Global (preferred before durable sudoers / production elevation):**

```sh
sudo sh src/take-ownership install
# or: take-ownership install --global   # needs write access to /usr/local/bin
# Managed binary mode is always 0755 so every user can run the shell ship unit.
# Grant emit requires this global path. Local ~/.local/bin is not written into sudoers.
```

**Sudoers (required before non-root `action`):**

```sh
# Global install must exist first (grant emit fails closed otherwise):
sudo sh src/take-ownership install
take-ownership generate-sudoer-request --path /var/www/html --ownership www-data:www-data
take-ownership submit-sudoer-request --path /var/www/html --ownership www-data:www-data
# or print a text dual for an admin:
take-ownership print-sudoers-install-script --path /var/www/html

# Admin (account with sudo rights) — handoff script (path printed by CLI):
sudo sh /dev/shm/take-ownership-<user>-sudoers-admin.sh install
sudo sh /dev/shm/take-ownership-<user>-sudoers-admin.sh replace
sudo sh /dev/shm/take-ownership-<user>-sudoers-admin.sh uninstall
```

**Security note:** Local `~/.local/bin` is **never** written into sudoers (the user could rewrite the file). Only `/usr/local/bin/take-ownership` is a legal grant path. See [`SECURITY.md`](./SECURITY.md).

This product is **local-only** for its install *channel* (no default `SCRIPT_URL` online install). Global vs local here means install *location*, not an online channel.

After install, on a terminal (`take-ownership` with no arguments) the main menu looks like:

```text
[INFO] take-ownership(2.7.0) — Take Unix ownership of a named folder with a narrow global-only sudo grant
1. action: Recursively take ownership of a named folder
2. sudoers: Grant and drafts
9. Exit
Choice:
```

Choose a number, or type the command name. Pick **2** / `sudoers` for grant/drafts (`8` goes back; `9` leaves). `take-ownership sudoers` is not a command — type the member verb instead. In a pipe, `take-ownership` prints help instead.

Config identity: `REPO_USER=cloudgen`, `REPO_NAME=take-ownership` (override with env if needed; does not enable online install while `SCRIPT_URL` is empty).

## Usage

```sh
take-ownership                               # TTY numbered work list; off-TTY is help
take-ownership help
take-ownership menu                          # same numbered list as empty argv
take-ownership about
take-ownership --json about

take-ownership generate-sudoer-request --path /var/www/html --ownership www-data:www-data
take-ownership generate-sudoer-json --path /var/www/html --ownership www-data:www-data /tmp/gold-sudoer.json
take-ownership submit-sudoer-request --path /var/www/html --ownership www-data:www-data
take-ownership list-folders
take-ownership action --path /var/www/html --ownership www-data:www-data

take-ownership uninstall --force
```

**Environment (selected):**

| Variable | Role |
|----------|------|
| `REPO_USER` | Git host owner (default `cloudgen`) |
| `REPO_NAME` | Git repository name (default `take-ownership`) |
| `SCRIPT_URL` | Online install channel (default **empty** — local only) |
| `GLOBAL_BIN` | System bin (default `/usr/local/bin`) — **only this path** is a legal sudoers Cmnd |
| `USER_BIN` | Per-user bin (default `~/.local/bin`) |
| `PERSIST_DIR` | Persistence storage (default `~/.local/take-ownership`) |
| `SUDOER_CLI` | Override path to `sudoer-cli` |
| `SUDOER_ADM_USER` | Approver login to detect (default `sudoer-adm`) |

## Examples

```sh
sudo sh src/take-ownership install
take-ownership generate-sudoer-request --path /var/www/html --ownership www-data:www-data
take-ownership action --path /var/www/html --ownership www-data:www-data
```

## Platform Compatibility

| Platform | Status |
|----------|--------|
| Linux, `/bin/sh` (dash/bash) | Supported |
| `tar`, `find`, `date` | Required |
| `sudo` + narrow sudoers | Required for non-root deposit/restore of root-owned archives |
| macOS / BSD | Not primary; GNU `stat`/`sed -E` assumptions may differ |

## Related Projects

- [take-ownership](https://github.com/cloudgen/take-ownership) — this product (upstream may still name folder-backup until retargeted)
- [CIAO Defensive Programming](https://github.com/cloudgen/ciao)
- [CIAO-Lite](https://github.com/cloudgen/ciao-lite)
- [cli-template](https://github.com/cloudgen/cli-template) — bootstrap parent architecture (Type 0 local-only template)

## Contributing

Keep changes surgical. Honor **CIAO-Lite Protection Zones** in `src/take-ownership`. Product behavior must stay consistent with live `docs/requirements/requirement-*.md`. Run `sh tests/run.sh` before proposing commits.

## License

MIT License — see [`LICENSE.md`](./LICENSE.md).

## Last Update

2026-09-03 — README main-menu example look (plain `take-ownership(2.7.0)`, Choice) immediately before Usage.
2026-09-03 — version **2.7.0** (main-menu family **sudoers** + five-verb submenu; `sudoers` is not a typed command; TP-CLI-13/17/19).
2026-09-03 — version **2.6.0** (default CLI main menu style: **take-ownership**(*version*) header; gray italic descriptions; TP-CLI-19).
2026-08-30 — version **2.5.0** (storage = cache folder **and** persistence `~/.local/take-ownership`; `about` Persistence storage / `persist_dir`).
2026-08-30 — version **2.4.1** (`about` Cache folder preferred `/dev/shm/cache/cache-take-ownership`; fallback under XDG `cache-take-ownership`).
2026-08-30 — version **2.4.0** (empty argv opens the numbered work list on a terminal; off-TTY still help; Type N never install).
2026-08-30 — version **2.4.0** (menu drops `list-folders`; interactive `action` numbered folder pick + current `user:group`; TP-42/43).
2026-08-26 — version **2.3.0** (grant `--ownership user:group`; withdraw leftover `*` gold from SSOT; text dual `user\:group`; TP-27/29/31).
2026-08-26 — version **2.2.0** (`generate-sudoer-json`; inbound exact-args; TP-27/28).
2026-08-26 — version **2.1.0** (`list-folders`; `action` confirms the same folder list first).
2026-08-23 — version **1.11.0** (`menu` / `main` numbered work list; TP-CLI-13..16).
2026-08-23 — version **1.10.0** (`print-sudoers` / JSON emit `backup *` / `restore *`; TP-26; INC-20260823-001).
2026-08-18 — housekeeping: Description rewritten in people-and-folders voice (no Type-1 lead); install heading says “your own login.” Version still **1.9.0** (no product-source change).
2026-08-17 — version **1.9.0** (`generate-sudoer-request`; independent generate dest; operator-readable errors; TP-24/25).
2026-08-17 — version **1.8.2** (submit **update** when `/etc/sudoers.d/folder-backup-<user>` exists; TP-23).
2026-08-17 — version **1.8.1** (submit inbound fidelity; pretty JSON re-encode; TP-22e/22f; review JR-1..8).
2026-08-15 — version **1.8.0** (JSON sudoer file = `folder-backup` backup/restore only; TP-22/22b/22c).
