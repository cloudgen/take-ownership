**file**: docs/requirements/requirement-shell-cli-interface.md  
**Status**: Active (Version 2.3.0)  
**Area**: shell  
**Key**: `requirement-shell-cli-interface`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for the **POSIX shell CLI interface** of take-ownership: command surface, privilege typing, global flags, dispatcher behavior, help/about contracts, and mode rules.

It defines a **you-centric local self-managed shell CLI** plus **domain take-ownership** commands and a **narrow elevated `action`** path. Full domain semantics live in `requirement-domain-take-ownership.md`. Full elevation/sudoers rules live in `requirement-three-layer-privilege-model.md`. Recursive chown lives in `requirement-take-ownership-ops.md`.

### 1.1 Human-facing

**In one sentence:** You type `take-ownership` plus a listed command; typing only the name opens the numbered work list on a terminal (help in a pipe); `action` is the live take-ownership work.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Run listed verbs | `take-ownership help` |
| Scripts / CI | `--json` / no TTY must not hang | `take-ownership --json about` |
| Not this file | How chown walks the tree | `requirement-take-ownership-ops` |

| Includes | Excludes |
|----------|----------|
| Routed verbs + global flags | Online `self-update` / `curl\|sh` |
| Dual mention of domain verbs | Dest approve/reject |

| Surface | What you open | What for |
|---------|---------------|----------|
| `./src/take-ownership` | ship unit | `app_main` |
| `take-ownership help` | command | listed verbs |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| See the catalog | Help lists operational work apart from grant testers | `take-ownership help` |
| Open the numbered list | empty argv or `menu` / `main` | `take-ownership` or `take-ownership menu` |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Command surface (portable shape)

Every command **MUST** map to exactly one privilege type. Unclassified commands are incomplete design.

| Category | Privilege | Meaning |
|----------|-----------|---------|
| **You – CLI lifecycle + diagnostics** | Invoking user | `install`, `uninstall`, `where-is-me`, `version`, `about`, `help` |
| **You – Domain (user work)** | Invoking user | Grant generate/submit/print; `action` until re-exec |
| **Host change – Narrow elevated action** | Controlled sudo (allowlisted only) | Re-exec `/usr/local/bin/take-ownership action --path … --ownership …` |
| **Dedicated badge** | Dedicated app user | **Not in scope** |

### 2.2 Global flags (portable)

| Flag | Env / state | Behavior |
|------|-------------|----------|
| `--quiet`, `-q` | `QUIET=1` | Suppress non-error human output; errors still visible |
| `--json` | `JSON=1` (implies quiet) | Machine-readable structured output; for `action` **MUST** be before the verb (grant twin) |
| `--debug` | `DEBUG=1` | Extra diagnostics on stderr; must not break JSON purity on stdout |
| `--force` | `FORCE=1` | Skip safe confirms or force reinstall only where documented |
| `--path` | `TO_PATH` | Absolute folder (required on `action` and grant-emit) |
| `--ownership` | `TO_OWNERSHIP` | `user:group` (required on `action`; **not** frozen into the grant) |
| `--update` | `SUBMIT_ACTION=update` | Submit/generate explicit update |
| `--add` | `SUBMIT_ACTION=add` | Submit/generate explicit add |
| `--global` | `FORCE_GLOBAL=1` | Install into `GLOBAL_BIN` |

Additional flags **MAY** be added only when documented here (or a superseding requirement) and wired in the dispatcher.

### 2.3 Dispatcher and entry rules

1. **Single entry:** `app_main` **MUST** parse global flags and route commands.  
2. **Unknown command:** **MUST** fail loudly with pointer to `help` (via output SSOT).  
3. **Empty argv:** **Type N → `app_main_menu`** (`requirement-shell-cli-zero-arguments.md`). Never install. TTY list / off-TTY help (`requirement-shell-cli-default-interaction.md`).  
4. **No raw user I/O:** User-facing messages **MUST** go through `out_*`.  
5. Script end **MUST** call `app_main "$@"` (no basename gate that blocks dispatch).

### 2.4 Help surface

`help` **MUST** list usage, every supported command, privilege category, global flags, and an honest note that `action` needs an admin-installed sudoers fragment **and** a global install.

**Purpose split:** the test-purpose alias is **`generate-sudoer-json`**. Help **MUST** list it under a heading **apart** from operational work. The five sudoers grant/draft verbs are **operational** (main-menu family **sudoers** submenu; still live CLI commands). **`sudoers` is not a live command.**

| Purpose | Verbs |
|---------|-------|
| **Operational** | `list-folders`, `action`, `generate-sudoer-request`, `submit-sudoer-request`, `print-sudoers`, `print-sudoers-install-script`, `remove-project-sudoers`; `menu` / `main` when routed |
| **Self-managed** | `install`, `uninstall`, `where-is-me` |
| **Diagnostics** | `version`, `about`, `help` |
| **Test-purpose** | `generate-sudoer-json` |
| **Menu-only family (not dispatched)** | `sudoers` |

Help **MUST** state: JSON field `action` (add/update) is **not** the CLI verb `action`.

In JSON mode, help **MUST NOT** dump long human text; return a short structured success/note object.

### 2.5 Implementation Notes (this project)

| Item | Value for take-ownership |
|------|-------------------------|
| **Product / binary name** | `take-ownership` (`APP_NAME`) |
| **Primary executable** | `src/take-ownership` (POSIX `/bin/sh`, single-file ship unit) |
| **Dispatcher** | `app_main` |
| **Output SSOT** | `out_text` + wrappers |
| **Version SSOT** | ship unit `VERSION=` in `src/take-ownership` |
| **Install paths** | Global: `/usr/local/bin`; User: `${HOME}/.local/bin` |
| **Primary install story** | User bin for Type 0; **global bin required** before grant emit |
| **Online channel** | **Not product UX** (absent) |
| **Type 2 commands** | None |

#### Supported commands (normative for this project)

| Command | Type | Handler family | Required behavior |
|---------|------|----------------|-------------------|
| *(no args — empty argv)* | You | `app_main` → `app_main_menu` | **Type N** — numbered list on TTY; help off-TTY; not install |
| `install` | You | `inst_local_install` | Copy running ship unit to privilege-correct bin |
| `uninstall` | You | `inst_local_uninstall` | Remove managed binary; confirm unless `--force` |
| `where-is-me` | You | `app_where_is_me` | Running + install paths + installed flag |
| `version` | You | `app_version` | Local `VERSION` only; no network |
| `about` | You | `app_about` | Diagnostics including **global-bin presence**; **Cache folder (preferred)** `/dev/shm/cache/cache-${APP_NAME}` and **Cache folder (fallback)**; **Persistence storage** `${HOME}/.local/${APP_NAME}`; no channel one-liner |
| `help` | You | `app_help` | Full usage; test-purpose `generate-sudoer-json` apart |
| `list-folders` | You | `to_list_folders` | **Operational.** List folders this login may take ownership of |
| `action` | You (+ host-change re-exec) | `to_action` | **Operational.** `--path` then `--ownership`; confirm against `list-folders` then recursive take-ownership. TTY without `--path`: numbered allowed-folder pick. TTY without `--ownership`: current `user:group` (no prompt). Off-TTY still requires both flags |
| `print-sudoers` | You | `to_print_sudoers` | **Operational.** `--path` required; **fails closed** without global binary. Submenu row 3 |
| `print-sudoers-install-script` | You | `to_print_sudoers_install_script` | **Operational.** Admin handoff script. Submenu row 4 |
| `remove-project-sudoers` | You | `to_remove_project_sudoers` | **Operational.** Draft only. Submenu row 5 |
| `generate-sudoer-request` | You | `to_generate_sudoer_request` | **Operational.** Independent JSON; `--path` required; global-bin gate. Submenu row 1 |
| `generate-sudoer-json` | You | `to_generate_sudoer_request` | **Test-purpose alias.** Same handler as `generate-sudoer-request`. Canonical JSON for tests (`--ownership` stays `user:group`). Off both menus |
| `submit-sudoer-request` | You | `to_submit_sudoer_request` | **Operational.** Sibling inbound; global-bin gate. Submenu row 2 |
| `menu` | You | `app_main_menu` | Numbered operational list (family **sudoers** + submenu) |
| `main` | You | `app_main_menu` | Alias of `menu` |

#### Dispatcher acceptance criteria

1. Unknown token after flag parse → `out_die` with pointer to `take-ownership help`.  
2. Zero-arg → `app_main_menu` (not install, not `action`; off-TTY help).  
3. Command routing table in `app_main` **must** include every **Implemented** row above.  
4. Help text **must** stay aligned. Test-purpose `generate-sudoer-json` **MUST** appear under a heading **apart**. The five sudoers verbs **MUST** stay routed (same handlers as the submenu). **MUST NOT** route `sudoers`.  
5. Domain catalog detail is owned by `requirement-domain-take-ownership.md`.

#### Explicitly out of scope

- Online: `version-check`, `self-update`, `self-uninstall`, channel `install` via URL  
- `backup` / `restore`  
- `--allow-test-local`  
- Creating the sibling inbound  
- Type 2 app runtime  

### 2.6 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 1 – Caution**: Unknown commands fail loud.  
- **CIAO Principle 2 – Intentional**: Every command has one privilege type and one handler family.  
- **CIAO Principle 5 – Single Source of Output**: Central `out_*`.  
- **CIAO Principle 6 – Single Point of Entry**: `app_main`.  
- **CIAO Principle 9 – Three Types of Commands**.  
- **CIAO Principle 16 – Interactive vs Non-Interactive**: No hang.  
- **CIAO Principle 4 / 20 – Over-protect**.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Fail loud on bad input; never silent wrong privilege context.  
- **Intentional:** Command table + help + dispatcher stay synchronized.  
- **Anti-fragile:** Works under TTY, quiet, JSON, offline local install.  
- **Over-protect:** Do not collapse layers, reintroduce online verbs, or raw output.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Add online lifecycle commands without an explicit product-mode change and registry update.  
2. Change empty argv to install-ensure while install mode remains local-only.  
3. List commands in help that are not routed (or route commands not listed).  
4. Bypass `out_*` for product user messages.  
5. Run the entire CLI as root by default instead of narrow `action` elevation.  
6. Put full chown semantics only here and omit the ops SSOT.  
7. Mix test-purpose `generate-sudoer-json` into operational help grouping, put it on the numbered main menu or sudoers submenu, or wire `sudoers` as a live `app_main` command.  
8. Reintroduce `backup` / `restore` or `--allow-test-local`.  
9. Route interactive empty argv to help while the claimed numbered list is Active.

**Violating this rule is a critical CLI interface regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | All **Implemented** commands in the table are routed and listed in help |
| AC-2 | Global flags wire QUIET/JSON/DEBUG/FORCE/TO_PATH/TO_OWNERSHIP as specified |
| AC-3 | Empty argv is Type N (not install) and routes to `app_main_menu` |
| AC-4 | No online self-management verbs on the surface |
| AC-5 | Domain verbs point to domain requirement for deep semantics |
| AC-6 | `submit-sudoer-request` is Type 0, routed; does not write `/etc` or create inbound |
| AC-7 | `generate-sudoer-request` / `generate-sudoer-json` are Type 0, independent of submit; dest readable; global-bin gate |
| AC-8 | Empty argv, `menu`, and `main` are routed to `app_main_menu` |
| AC-9 | Help lists test-purpose `generate-sudoer-json` **apart** from operational verbs |
| AC-10 | Five sudoers grant/draft verbs are routed live commands; `sudoers` is unknown |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-cli-zero-arguments` | Empty argv Type N; routes to `app_main_menu` |
| `requirement-shell-cli-default-interaction` | Claimed numbered list on empty argv and `menu`/`main` |
| `requirement-shell-local-self-management` | install/uninstall/where-is-me |
| `requirement-shell-output-requirements` | `out_*` catalog |
| `requirement-domain-take-ownership` | Domain four pillars |
| `requirement-take-ownership-ops` | `action` ops |
| `requirement-three-layer-privilege-model` | Elevation model |
| `docs/requirements/index.md` | Registry |
| `./src/take-ownership` | Implementation under test |

---

## Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-CLI-01..12** | `tests/test_cli.sh` | **todo** — retarget from folder-backup names |
| **TP-CLI-13..16** | same | **have** — `menu`/`main` and empty argv; family **sudoers** + submenu |
| **TP-CLI-17** | same | **have** — help lists test-purpose `generate-sudoer-json` apart |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active 1.0.0 | folder-backup CLI + domain backup |
| 2026-08-23 | Active 1.6.0 | folder-backup menu/main routed |
| 2026-08-25 | Active 2.0.0 | Retarget take-ownership; `action`; retire backup/restore |
| 2026-08-26 | Active 2.1.0 | `generate-sudoer-json` test-purpose alias of generate-sudoer-request |
| 2026-08-30 | Active 2.2.0 | Empty argv routes to `app_main_menu` (Type N; not install) |
| 2026-08-30 | Active 2.2.1 | `about` Persistence storage `${HOME}/.local/${APP_NAME}` |
| 2026-09-03 | Active 2.3.0 | Five sudoers verbs operational (submenu); `generate-sudoer-json` remains test-purpose; `sudoers` not dispatched |

---

**Last Updated**: 2026-09-03  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
