**file**: docs/requirements/requirement-shell-script-coding.md  
**Status**: Active (Version 1.0.0)  
**Area**: shell  
**Key**: `requirement-shell-script-coding`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **specialize-in home** for POSIX `/bin/sh` coding style on take-ownership.

**Without this requirement, agents bring portable learned lessons raw** (from harness coding skills) and treat those skills as product law. This file is the product coding-style SSOT. Peer requirements **own** output, prefixes, TTY, temps, prompts, and sudo wrappers; this file **points** and keeps the residual shell style.

### 1.1 Human-facing

**In one sentence:** The ship unit is a POSIX `/bin/sh` script with a fixed shebang, no Bash-only tricks, and comments that point at these requirement files — not at agent skills.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Read ship unit + this file | `src/take-ownership` |
| Maintainers / agents | Follow this REQ, not a raw coding skill | shebang `#!/bin/sh` |
| Not this file | `out_*` catalog, `util_sudo` body | peer REQs |

| Includes | Excludes |
|----------|----------|
| Shebang, POSIX subset, `set` policy, comment citation | Dumping the full portable mold into the ship unit twice |
| Pointing at peers for output / TTY / sudo | Treating `skill-sh-script-coding` as product law |

| Surface | What you open | What for |
|---------|---------------|----------|
| `./src/take-ownership` | ship unit | live style |
| `docs/requirements/index.md` | registry | peer owners |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Add a helper | Prefix + header; output via `out_*` | edit `src/take-ownership` |
| Need sudo | Use `util_sudo` from the sudo REQ | do not paste raw `sudo` |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Shebang and runtime

1. Ship unit shebang **MUST** be **`#!/bin/sh`**.  
2. **MUST** stay in the POSIX `/bin/sh` subset (dash / BusyBox ash compatible). **MUST NOT** require Bash arrays, `[[ ]]`, `source`, or process substitution.  
3. **MUST NOT** use `set -e` or `set -u` as a substitute for explicit checks (`set -u` is allowed only if the ship unit already uses it **and** every expansion is guarded — this product **SHOULD** prefer explicit `: "${VAR:?}"` / defaults over a new `set -e`).  
4. Source files with **`.`**, not `source`.  
5. Detect tools with **`command -v`**, not `which`.

### 2.2 Own-or-point (do not duplicate peer bodies)

| Topic | Owner |
|-------|--------|
| Output `out_*` | `requirement-shell-output-requirements` |
| Function prefixes | `requirement-shell-modular-function-design` |
| TTY measure outside functions; helpers consume `TTY` | `requirement-shell-interactive-vs-noninteractive` |
| Temps / `util_mktemp` | `requirement-shell-cli-storage` |
| Prompts | `requirement-shell-interactive-vs-noninteractive` |
| Sudo wrapper / check before sudo / chmod example | `requirement-shell-sudo-command` |
| Operator error copy | `requirement-operator-readable-error` |

This file **MUST NOT** paste those complete catalogs again.

### 2.3 Product-source citations

Ship-unit comments that name behavioral authority **MUST** cite live `docs/requirements/requirement-*.md` paths registered in `index.md`. **MUST NOT** cite `template-*.md` or `skill-*.md` as product law.

### 2.4 Defaults and SSOT

1. Identity (`APP_NAME`, `VERSION`) **MUST** be hard-assign in the ship unit Config block (one place).  
2. **MUST** use `: "${VAR:=default}"` for overridable paths (`GLOBAL_BIN`, `USER_BIN`).  
3. **MUST NOT** freeze a session Unix login or `/home/<login>/…` into source.

### 2.5 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `take-ownership` |
| **Ship unit** | `src/take-ownership` |
| **Shebang** | `#!/bin/sh` |
| **Language** | posix-sh |
| **Sudo peer** | `requirement-shell-sudo-command` |
| **Domain prefix** | `to_` |

### 2.6 Why This Requirement Exists (CIAO)

- **Principle 2 – Intentional**: Specialize-in home so lessons are not raw.  
- **Principle 21 – Dual policies**: Portable style in cores; product fills in notes.  
- **Principle 5 – SSOT**: Peers own catalogs; this file does not fork them.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** POSIX subset; no Bashism surprise on dash.  
- **Intentional:** One coding-style REQ.  
- **Anti-fragile:** Works on minimal `/bin/sh`.  
- **Over-protect:** Do not strip Protection Zones “for brevity.”

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Change the shebang away from `#!/bin/sh` without an explicit product-runtime change.  
2. Treat harness coding skills as product law while this REQ is Active.  
3. Duplicate full `out_*` / TTY / sudo catalogs here.  
4. Cite templates or skills as behavioral authority in the ship unit.  
5. Introduce `set -e` as a silent rewrite of explicit error handling.  
6. Skip this REQ so portable lessons arrive raw.

**Violating this rule is a critical coding-style regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Active language-matched coding-style REQ exists |
| AC-2 | Shebang `#!/bin/sh` |
| AC-3 | Peers pointed, not duplicated |
| AC-4 | Sudo bodies live on `requirement-shell-sudo-command` |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-class-software-dev` | Class residual points here |
| `requirement-shell-sudo-command` | Wrapper bodies |
| `requirement-shell-output-requirements` | `out_*` |
| `requirement-shell-modular-function-design` | Prefixes |
| `requirement-shell-interactive-vs-noninteractive` | TTY |
| `requirement-shell-cli-storage` | Temps |
| `docs/requirements/index.md` | Registry |
| `./src/take-ownership` | Implementation under test |

---

## Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-CLI-style** | `tests/test_cli.sh` | **todo** — shebang is `#!/bin/sh` (head of ship unit) |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-25 | Active 1.0.0 | Mandatory coding-style specialize-in for take-ownership |

---

**Last Updated**: 2026-08-25  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
