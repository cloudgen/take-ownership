# take-ownership - Take Unix ownership of a named folder with a narrow sudo grant

![Version](https://img.shields.io/badge/Version-3.0.3-blue?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)
[![CIAO](https://img.shields.io/badge/Philosophy-CIAO%20(Caution%20%E2%80%A2%20Intentional%20%E2%80%A2%20Anti--fragile%20%E2%80%A2%20Over--engineered)-purple.svg)](https://github.com/cloudgen/ciao)
[![Stars](https://img.shields.io/github/stars/cloudgen/take-ownership?style=flat-square)](https://github.com/cloudgen/take-ownership)

**take-ownership** lets you ask an admin for one folder, then run `take-ownership action --path <folder> --ownership user:group` to recursively take that folder’s ownership (it does not follow symbolic links).

You can install it with one `curl | sh` line. Then write a grant for one folder and hand that grant to an admin. After the admin installs the grant, `action` may re-run the **global** program at `/usr/local/bin/take-ownership`. A copy in `~/.local/bin` is fine for help and local use; it is never written into the sudoers file (you could rewrite that file).

| You (your own login) | Admin / already root | Not this |
|----------------------|----------------------|----------|
| `curl \| sh` into your user bin, generate and submit a grant for one folder, run `action` after the grant exists | `sudo curl \| sudo sh` into `/usr/local/bin` and install the sudoers fragment | A normal login does not write `/etc`; `~/.local/bin` is never in sudoers |

## Features

- **Online self-management**: `curl | sh` install, `version-check`, `self-update`, `self-uninstall`, `about`, plus `menu` / `main` (TTY numbered work list: action, then family **sudoers** with a grant/draft submenu; empty argv on a terminal is the same list; in a pipe it installs)
- **Automatic SHA-256 companion** on install and self-update (the program fetches `${SCRIPT_URL}.sha256`)
- **Take ownership**: `action --path <folder> --ownership <user:group>` — recursive chown, no symlink follow, refuse system roots. On a real terminal, `action` (or menu `1`) lists **existing** granted folders by number and uses this login’s `user:group` with no extra prompt. A granted path that is not a directory is listed by `list-folders` as missing; it is not a live pick. Recreate the folder, then run `action` — do not generate a new grant.
- **Narrow sudoers**: exact `--path`, exact `--ownership user:group`, **global binary only**
- **Sudoer approval submit**: `generate-sudoer-request --path <folder> --ownership <user:group>` (alias `generate-sudoer-json`) writes a local JSON grant you can review. `--ownership` is an existing `user:group` (never `*`, never a directory listing). `submit-sudoer-request` hands it to sudoer-cli (does not write `/etc`, does not create the public drop box)
- **Stops when the grant would be unsafe**: missing global program, missing user:group, refuse-list paths, swapped flags, or a grant that is not a real `user:group`
- **Scratch for this run**: a cache folder named for this login and this process. `about` prints the folder that was used, the preferred folder, and this host’s fallbacks. A skipped tier stays silent. Durable notes stay in `~/.local/take-ownership` (not an override, and not the install bin).

## Quick Installation

Default install channel (Config SSOT):  
`https://raw.githubusercontent.com/cloudgen/take-ownership/main/take-ownership`

**Per-user (non-root):**

```sh
curl -fsSL https://raw.githubusercontent.com/cloudgen/take-ownership/main/take-ownership | sh
```

**System-wide (root / elevated — preferred before durable sudoers):**

```sh
sudo curl -fsSL https://raw.githubusercontent.com/cloudgen/take-ownership/main/take-ownership | sudo sh
```

Managed binary mode is always **0755** so every user can run the shell program. Grant emit requires the global path. Local `~/.local/bin` is not written into sudoers.

### Integrity (automatic checksum)

When `CHECKSUM` is **not** set, install and self-update use **automatic** companion verification:

| Topic | Behavior |
|-------|----------|
| **Algorithm** | SHA-256 |
| **Companion** | Program downloads `${SCRIPT_URL}.sha256` itself — **no** env pin required |
| **In-repo file** | [`take-ownership.sha256`](./take-ownership.sha256) next to `./take-ownership` |
| **Transparency** | Human mode shows companion **link**, expected **value**, and **result** |
| **Match** | Continue install |
| **Mismatch** | **Abort** — do not install mismatched bytes |
| **Missing sidecar** | **Warn** and continue (best-effort; not “always verified”) |

### From a local checkout

```sh
chmod +x ./take-ownership
./take-ownership install
take-ownership version
```

`install` still downloads from `SCRIPT_URL` (override the env for a fork or a local HTTP channel).

**Sudoers (required before non-root `action`):**

```sh
# Global install must exist first (grant emit stops otherwise):
sudo curl -fsSL https://raw.githubusercontent.com/cloudgen/take-ownership/main/take-ownership | sudo sh
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

After install, on a terminal (`take-ownership` or `take-ownership menu`) the front board looks like:

```text
[INFO] **take-ownership**(*3.0.3*) — Take Unix ownership of a named folder with a narrow global-only sudo grant
1. action: Recursively take ownership of a named folder
7. sudoers: Grant and drafts
8. self-management: This CLI install, version, update, uninstall
9. Exit
Choice:
```

**1** opens the folders this login may take. That list has **0** Back. **0** returns to the front board. A number that is not on the list warns and shows the list again. It does not leave the program.

```text
[INFO] Folders this login may take ownership of (1):
1. /var/www/html
0. Back
Choice:
```

**7** opens grant and drafts. **0** returns to the front board. **9** on that board is not Exit.

```text
[INFO] **take-ownership**(*3.0.3*) — sudoers (grant and drafts)
71. generate-sudoer-request: Write a JSON grant you can read
72. submit-sudoer-request: Queue the JSON grant inbound
73. print-sudoers: Emit sudoers draft
74. print-sudoers-install-script: Write admin install script
75. remove-project-sudoers: Remove sudoers draft only
0. Back
Choice:
```

**8** opens install, version, update, and remove. **0** returns. `self-install` is not a row.

```text
[INFO] **take-ownership**(*3.0.3*) — self-management (this CLI)
81. install: Ensure this program from the channel
82. version: Show the local version
83. about: Show diagnostics including global-bin presence
84. version-check: Compare local version to the channel
85. self-update: Update this program when the channel is newer
86. self-uninstall: Remove the managed binary (not the host grant)
0. Back
Choice:
```

Choose a number, or type the command name. **9** leaves only from the front board. `take-ownership sudoers` and `take-ownership self-management` are not commands — type the member verb instead. In a pipe, empty argv is install-ensure (`curl | sh`), not this list.

Git host identity (override with env if needed): owner `cloudgen`, repository `take-ownership`. Channel URL is Config `SCRIPT_URL`.

## Usage

```sh
take-ownership                               # TTY numbered work list; off-TTY is install-ensure
take-ownership help
take-ownership menu                          # same numbered list as empty argv
take-ownership about
take-ownership --json about

take-ownership generate-sudoer-request --path /var/www/html --ownership www-data:www-data
take-ownership generate-sudoer-json --path /var/www/html --ownership www-data:www-data /tmp/gold-sudoer.json
take-ownership submit-sudoer-request --path /var/www/html --ownership www-data:www-data
take-ownership list-folders
take-ownership action --path /var/www/html --ownership www-data:www-data

take-ownership version-check
take-ownership self-update
take-ownership self-uninstall --force
```

**Environment (selected):**

| Variable | Role |
|----------|------|
| `REPO_USER` | Git host owner (default `cloudgen`) |
| `REPO_NAME` | Git repository name (default `take-ownership`) |
| `SCRIPT_URL` | Online install channel (default `https://raw.githubusercontent.com/cloudgen/take-ownership/main/take-ownership`) |
| `GLOBAL_BIN` | System bin (default `/usr/local/bin`) — **only this path** is a legal sudoers command |
| `USER_BIN` | Per-user bin (default `~/.local/bin`) |
| `SUDOER_CLI` | Override path to `sudoer-cli` |
| `SUDOER_ADM_USER` | Approver login to detect (default `sudoer-adm`) |

Persistence storage is always `~/.local/take-ownership`. It is not the cache folder and not `~/.local/bin`.

## Examples

```sh
curl -fsSL https://raw.githubusercontent.com/cloudgen/take-ownership/main/take-ownership | sh
sudo curl -fsSL https://raw.githubusercontent.com/cloudgen/take-ownership/main/take-ownership | sudo sh
take-ownership generate-sudoer-request --path /var/www/html --ownership www-data:www-data
take-ownership action --path /var/www/html --ownership www-data:www-data
```

## Platform Compatibility

| Platform | Status |
|----------|--------|
| Linux, `/bin/sh` (dash/bash) | Supported |
| `chown` (recursive, no symlink follow) | Required |
| `sudo` + narrow sudoers | Required for non-root `action` on a folder this login does not already own |
| Termux / Git Bash / Windows cmd | Your own login only — no in-tool `sudo`, no writing `/etc` |
| macOS / BSD | Not primary; GNU `stat`/`sed -E` assumptions may differ |

## Related Projects

- [take-ownership](https://github.com/cloudgen/take-ownership) — this product
- [CIAO Defensive Programming](https://github.com/cloudgen/ciao)
- [CIAO-Lite](https://github.com/cloudgen/ciao-lite)
- [selfmanaged](https://github.com/cloudgen/selfmanaged) — bootstrap parent (online Type 0)

## Contributing

Keep changes surgical. Honor **CIAO-Lite Protection Zones** in `./take-ownership`. Product behavior must stay consistent with live `docs/requirements/requirement-*.md`. After editing the ship unit, regenerate `take-ownership.sha256`. Run `sh tests/run.sh` before proposing commits.

## License

MIT License — see [`LICENSE.md`](./LICENSE.md).

## Last Update

2026-09-30 — version **3.0.3** (folder list and other layers except the front board: **0** Back; a bad choice stays on that list). See [`CHANGELOG.md`](./CHANGELOG.md) for earlier releases.
