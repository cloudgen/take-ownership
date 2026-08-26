**file**: docs/requirements/requirement-shell-cli-interface.md  
**Status**: Active (Version 2.0.0)  
**Area**: shell  
**Key**: `requirement-shell-cli-interface`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for the **POSIX shell CLI interface** of take-ownership: command surface, privilege typing, global flags, dispatcher behavior, help/about contracts, and mode rules.

It defines a **you-centric local self-managed shell CLI** plus **domain take-ownership** commands and a **narrow elevated `action`** path. Full domain semantics live in `requirement-domain-take-ownership.md`. Full elevation/sudoers rules live in `requirement-three-layer-privilege-model.md`. Recursive chown lives in `requirement-take-ownership-ops.md`.

### 1.1 Human-facing

**In one sentence:** You type `take-ownership` plus a listed command; empty argv prints help; `action` is the live take-ownership work.

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
| Open the numbered list | `menu` / `main` — not empty argv | `take-ownership menu` |

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
3. **Empty argv:** **Type N → help** (`requirement-shell-cli-zero-arguments.md`).  
4. **No raw user I/O:** User-facing messages **MUST** go through `out_*`.  
5. Script end **MUST** call `app_main "$@"` (no basename gate that blocks dispatch).

### 2.4 Help surface

`help` **MUST** list usage, every supported command, privilege category, global flags, and an honest note that `action` needs an admin-installed sudoers fragment **and** a global install.

**Purpose split:** grant-emit verbs are **test-purpose**. Help **MUST** list them under a heading **apart** from operational work.

| Purpose | Verbs |
|---------|-------|
| **Operational** | `action`, `remove-project-sudoers`, `submit-sudoer-request`; `menu` / `main` when routed |
| **Self-managed** | `install`, `uninstall`, `where-is-me` |
| **Diagnostics** | `version`, `about`, `help` |
| **Test-purpose** | `print-sudoers`, `print-sudoers-install-script`, `generate-sudoer-request` |

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
| *(no args — empty argv)* | You | `app_main` → `app_help` | **Type N help** — not install |
| `install` | You | `inst_local_install` | Copy running ship unit to privilege-correct bin |
| `uninstall` | You | `inst_local_uninstall` | Remove managed binary; confirm unless `--force` |
| `where-is-me` | You | `app_where_is_me` | Running + install paths + installed flag |
| `version` | You | `app_version` | Local `VERSION` only; no network |
| `about` | You | `app_about` | Diagnostics including **global-bin presence**; no channel one-liner |
| `help` | You | `app_help` | Full usage; test-purpose apart |
| `action` | You (+ host-change re-exec) | `to_action` | **Operational.** `--path` then `--ownership`; recursive take-ownership |
| `print-sudoers` | You | `to_print_sudoers` | **Test-purpose.** `--path` required; **fails closed** without global binary |
| `print-sudoers-install-script` | You | `to_print_sudoers_install_script` | **Test-purpose.** Admin handoff script |
| `remove-project-sudoers` | You | `to_remove_project_sudoers` | **Operational.** Draft only |
| `generate-sudoer-request` | You | `to_generate_sudoer_request` | **Test-purpose.** Independent JSON; `--path` required; global-bin gate |
| `submit-sudoer-request` | You | `to_submit_sudoer_request` | **Operational.** Sibling inbound; global-bin gate |
| `menu` | You | `app_main_menu` | Numbered operational list |
| `main` | You | `app_main_menu` | Alias of `menu` |

#### Dispatcher acceptance criteria

1. Unknown token after flag parse → `out_die` with pointer to `take-ownership help`.  
2. Zero-arg → help (not install, not `action`).  
3. Command routing table in `app_main` **must** include every **Implemented** row above.  
4. Help text **must** stay aligned. Test-purpose verbs **MUST** appear under a heading **apart**.  
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
2. Change empty argv away from Type N help while install mode remains local-only.  
3. List commands in help that are not routed (or route commands not listed).  
4. Bypass `out_*` for product user messages.  
5. Run the entire CLI as root by default instead of narrow `action` elevation.  
6. Put full chown semantics only here and omit the ops SSOT.  
7. Mix test-purpose grant-emit verbs into operational help grouping, or put them on the numbered main menu.  
8. Reintroduce `backup` / `restore` or `--allow-test-local`.  
9. Attach the numbered list to empty argv.

**Violating this rule is a critical CLI interface regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | All **Implemented** commands in the table are routed and listed in help |
| AC-2 | Global flags wire QUIET/JSON/DEBUG/FORCE/TO_PATH/TO_OWNERSHIP as specified |
| AC-3 | Empty argv is help (Type N) |
| AC-4 | No online self-management verbs on the surface |
| AC-5 | Domain verbs point to domain requirement for deep semantics |
| AC-6 | `submit-sudoer-request` is Type 0, routed; does not write `/etc` or create inbound |
| AC-7 | `generate-sudoer-request` is Type 0, independent of submit; dest readable; global-bin gate |
| AC-8 | `menu` and `main` are routed; empty argv stays help |
| AC-9 | Help lists test-purpose grant-emit **apart** from operational verbs |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-cli-zero-arguments` | Empty argv Type N |
| `requirement-shell-cli-default-interaction` | Claimed `menu`/`main` numbered list |
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
| **TP-CLI-13..16** | same | **todo** — `menu`/`main` with three operational rows |
| **TP-CLI-17** | same | **todo** — help lists test-purpose grant-emit apart |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active 1.0.0 | folder-backup CLI + domain backup |
| 2026-08-23 | Active 1.6.0 | folder-backup menu/main routed |
| 2026-08-25 | Active 2.0.0 | Retarget take-ownership; `action`; retire backup/restore |

---

**Last Updated**: 2026-08-25  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
