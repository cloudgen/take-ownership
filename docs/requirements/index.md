# Requirements index

**Product:** take-ownership (POSIX `/bin/sh` local self-managed CLI — take Unix ownership of a named folder with a narrow global-only sudo grant)  
**Workspace state:** Specialized product law; **software-development** class; bootstrap **cli-template → folder-backup → take-ownership** (domain replace; online install **intentionally absent**).  
**Updated:** 2026-08-30

| ID / key | Title | Area | Status | Path | Updated |
|----------|-------|------|--------|------|---------|
| requirement-class-software-dev | Software-development class law + residual stack (posix-sh, local-only); dest approver/fences **None**; coding-style + sudo-wrap peers | class | Active (2.0.1) | `requirement-class-software-dev.md` | 2026-08-30 |
| requirement-bootstrap-chain | Bootstrap chain A0=cli-template → A1=folder-backup → B=take-ownership (domain replace) | architecture | Active (3.1.0) | `requirement-bootstrap-chain.md` | 2026-08-30 |
| requirement-project-folder | Project layout (`src/`), install bins, config drafts; **no** `/var/backup` | architecture | Active (2.0.0) | `requirement-project-folder.md` | 2026-08-25 |
| requirement-three-layer-privilege-model | You + narrow `action` elev; sudoers emit + install-script; **global-only** grant; **no** `--allow-test-local`; per-user fragments; submit workflow; `--ownership user:group` | architecture | Active (2.2.0) | `requirement-three-layer-privilege-model.md` | 2026-08-26 |
| requirement-sudoer-json-file | JSON sudoer file SSOT: one recursive **folder per line**; `--ownership user:group` (never `*`); later submit = replacement union of unique folders; text dual escapes `:` | architecture | Active (2.4.0) | `requirement-sudoer-json-file.md` | 2026-08-26 |
| requirement-incorrect-ownership-parameter | Product grant/inbound fence: `--ownership` is existing `user:group`; `*` and cwd listings fail closed | architecture | Active (1.0.0) | `requirement-incorrect-ownership-parameter.md` | 2026-08-26 |
| requirement-take-ownership-ops | **Ops SSOT**: recursive chown, no symlink follow; `--path` then `--ownership`; refuse-list; TTY numbered folder pick + current `user:group` | domain-ops | Active (1.3.0) | `requirement-take-ownership-ops.md` | 2026-08-30 |
| requirement-shell-script-coding | POSIX `/bin/sh` coding-style specialize-in (without it, portable lessons arrive raw) | shell | Active (1.0.0) | `requirement-shell-script-coding.md` | 2026-08-25 |
| requirement-shell-sudo-command | In-tool `util_sudo`; check before sudo; chmod example; `action` re-execs global binary | shell | Active (1.0.0) | `requirement-shell-sudo-command.md` | 2026-08-25 |
| requirement-shell-cli-interface | Shell CLI interface (commands, flags, dispatch, modes); `action`; submit `--add`/`--update`; generate; empty argv + `menu`/`main` → numbered list | shell | Active (2.2.0) | `requirement-shell-cli-interface.md` | 2026-08-30 |
| requirement-shell-cli-zero-arguments | Empty argv Type N (never install); routes to `app_main_menu` | shell | Active (1.1.0) | `requirement-shell-cli-zero-arguments.md` | 2026-08-30 |
| requirement-shell-cli-default-interaction | Claimed TTY numbered list on empty argv and `menu`/`main` (case 3; three work rows; `list-folders` off the list) | shell | Active (2.2.0) | `requirement-shell-cli-default-interaction.md` | 2026-08-30 |
| requirement-shell-local-self-management | Local install / uninstall / where-is-me; mode **0755** multi-user; global required before grant emit | shell | Active (1.2.0) | `requirement-shell-local-self-management.md` | 2026-08-25 |
| requirement-shell-output-requirements | Central `out_*` output SSOT | shell | Active | `requirement-shell-output-requirements.md` | 2026-08-25 |
| requirement-operator-readable-error | Operator-facing error wording (what happened / next step) | shell | Active (1.0.0) | `requirement-operator-readable-error.md` | 2026-08-25 |
| requirement-shell-modular-function-design | Single-file modular prefixes (`out_`/`inst_`/`app_`/`to_`) | shell | Active | `requirement-shell-modular-function-design.md` | 2026-08-25 |
| requirement-shell-idempotency | Re-run safety; `action` already-matching success | shell | Active | `requirement-shell-idempotency.md` | 2026-08-25 |
| requirement-shell-interactive-vs-noninteractive | Interactive vs non-interactive / confirm policy; `action` TTY walk | shell | Active | `requirement-shell-interactive-vs-noninteractive.md` | 2026-08-25 |
| requirement-shell-cli-storage | Scratch/cache resolve; no backup staging | shell | Active | `requirement-shell-cli-storage.md` | 2026-08-25 |
| requirement-domain-take-ownership | Domain **surface** SSOT (four pillars); ops defer to take-ownership-ops; submit public inbound; independent generate; grant-emit **test-purpose**; `--ownership user:group` | domain | Active (1.3.0) | `requirement-domain-take-ownership.md` | 2026-08-26 |

## Superseded (lineage only — not live law)

| ID / key | Title | Replaced by | Path |
|----------|-------|-------------|------|
| requirement-domain-folder-backup | folder-backup domain four pillars | `requirement-domain-take-ownership` | `requirement-domain-folder-backup.md` |
| requirement-folder-archive-backup | Backup/restore ops | `requirement-take-ownership-ops` | `requirement-folder-archive-backup.md` |
| requirement-folder-archive-backup-retention-total | Total retention 30 | retired (not a backup product) | `requirement-folder-archive-backup-retention-total.md` |
| requirement-folder-archive-backup-retention-daily | Daily retention 5 | retired (not a backup product) | `requirement-folder-archive-backup-retention-daily.md` |

## Intentionally absent (by design — inherited from cli-template / folder-backup)

| Parent surface | Status on take-ownership |
|----------------|--------------------------|
| Online install / `SCRIPT_URL` / Type O empty-argv install-ensure | **Absent** |
| `version-check` / `self-update` / `self-uninstall` | **Absent** |
| Automatic companion `.sha256` channel integrity law | **Absent** |
| `--allow-test-local` / USER_BIN in sudoers | **Absent** (forbidden; security leak) |

**Install mode:** **local-only** / **non-online-installable** (`install` + `uninstall` + `where-is-me`). Not dual-mode. Destination may be user-bin or global-bin; **only global-bin** may appear in the sudoer file.

**Rules for agents:**

1. Treat **Active** rows above as the **live product-law inventory** for take-ownership.  
2. **Do not invent** additional `requirement-*.md` paths — verify on disk and add a registry row in the same change when creating one.  
3. Product source comments cite **only** these live requirement files — never templates/skills as behavioral authority.  
4. This versioned surface lists **requirement rows only**.  
5. Keep Status and Path in sync with each file’s header when status changes.  
6. **Class gate:** software-development requires exactly one Active `requirement-class-software-dev.md` (this registry includes it).  
7. **Domain SSOT:** exactly one Active `requirement-domain-*` (`requirement-domain-take-ownership`).  
8. **Do not reintroduce** online install package, backup/restore verbs, or USER_BIN sudoers without explicit user order and registry update.

When adding a requirement: append a row, create the file under `docs/requirements/`, keep Status in sync with the file header.
