**file**: docs/requirements/requirement-shell-cli-zero-arguments.md  
**Status**: Active (Version 1.1.0)  
**Area**: shell  
**Key**: `requirement-shell-cli-zero-arguments`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for **zero-argument (empty argv) dispatcher behavior** of the take-ownership POSIX shell CLI.

### 1.0 Product type

| Field | Value for take-ownership |
|-------|-------------------------|
| **Empty-argv type** | **Type N — Non-online-install** |
| **Rationale** | Product is **local-only**; no `curl \| sh` channel; empty argv **MUST NOT** install-ensure |

Type O (online-install empty-argv = install-ensure) does **not** apply.

Empty argv **MUST** use the same handler as **`menu` / `main`** (`app_main_menu`). List membership, TTY vs off-TTY, and Exit 9 live in `requirement-shell-cli-default-interaction`. This file owns **whether** empty argv is that path (yes) and **that it is never install**.

### 1.1 Human-facing

**In one sentence:** Typing only `take-ownership` at a real terminal opens the numbered list of live work commands; in a pipe it prints help; it never copies the program onto PATH.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Bare name at a prompt is the work list | `take-ownership` then `1` |
| Scripts / CI | Bare name must not hang or install | `take-ownership </dev/null` → help |
| Not this file | Which rows appear on that list | `requirement-shell-cli-default-interaction` |

| Includes | Excludes |
|----------|----------|
| Empty argv (`$# -eq 0` at `app_main`) | Install-ensure / Type O |
| Same handler as `menu` / `main` | Running `action` with no verb |
| Explicit `help` still full usage | Flags-only (`--json` with no command) as this empty-argv path |

| Surface | What you open | What for |
|---------|---------------|----------|
| `./src/take-ownership` | ship unit | empty-argv branch |
| `take-ownership` | no command | numbered list on TTY; help off-TTY |
| `take-ownership help` | command | full usage |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Open the work list with no command | Same numbered list as `menu`. | `take-ownership` |
| Ask for the catalog | Full usage, including lifecycle and grant testers. | `take-ownership help` |
| Run with no args in CI | Human help, or JSON help with `--json` only when a command/flags path says so. Bare empty argv has no `--json`. | `take-ownership </dev/null` |

---

## 2. Core Rules (Mandatory)

### 2.1 Single meaning of empty argv

1. When **argv is empty** (`$# -eq 0` at entry to `app_main`), the dispatcher **MUST** route to **`app_main_menu`** (the same handler as `take-ownership menu` / `main`).  
2. Empty argv **MUST NOT** perform install, `action`, or any state-changing ensure.  
3. Explicit `take-ownership help` remains the **full-usage** path (not the numbered list). Empty argv **MUST NOT** be treated as identical to explicit `help` on a real terminal.  
4. Explicit `take-ownership install` remains the only first-time local install path (plus documented force refresh).  
5. Script entry **MUST** always call `app_main "$@"` (no basename product-name gate that blocks dispatch).  
6. Interactive vs non-interactive for this path **MUST** follow `requirement-shell-cli-default-interaction`: TTY numbered list; off-TTY help (no hang).  
7. Flags only (e.g. `--json` with no command token) is **not** empty argv. After flag parse with no command token, default remains **help** (JSON help when `--json`).

### 2.2 Normative matrix

| Invocation | Behavior |
|------------|----------|
| `take-ownership` (no args), interactive (`TTY=1`) | Numbered work list (`app_main_menu`); same as `take-ownership menu` |
| `take-ownership` (no args), non-interactive (`TTY=0`) | Help; exit 0; **MUST NOT** prompt |
| `take-ownership help` | Show help; exit 0 |
| `take-ownership install` | Local install ensure |
| `take-ownership menu` / `main` | Same handler as empty argv |
| Flags only (e.g. `--json` with no command) | **Help** after flag parse (JSON help when `--json`) |

### 2.3 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `take-ownership` |
| **Type** | **Type N** |
| **Default empty-argv handler** | `app_main_menu` |
| **Default COMMAND after flags with no token** | `help` |
| **Contrast parent** | cli-template is Type N help-default. This product **keeps Type N (no install)** and **routes empty argv to the claimed numbered list**. (Historical: selfmanaged Type O was trimmed in 2026-08-03; not live origin.) |

### 2.4 Why This Requirement Exists (CIAO)

- **Principle 2 – Intentional**: Empty argv meaning is explicit: Type N (not install) **and** the claimed default work list.  
- **Principle 1 – Caution**: Avoid surprise install on bare invocation for an ops CLI.  
- **Principle 16 – Interactive**: TTY list vs pipe help; no hang.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: No silent ensure on empty argv.  
- **Intentional**: Type N declared; empty argv shares `app_main_menu` with `menu` / `main`.  
- **Anti-fragile**: Off-TTY help works offline; explicit `help` still full usage.  
- **Over-protect**: Do not reintroduce Type O without reclassifying product install mode.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Change empty argv to install-ensure while the product remains local-only.  
2. Copy a Type O empty-argv parent wholesale without updating this file and install mode.  
3. Make bare invocation run domain `action`.  
4. Route empty argv back to `app_help` on a real terminal while the claimed numbered list is Active.  
5. Hang off-TTY empty argv on the numbered list.

**Violating this rule is a critical dispatcher regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Empty argv does not install |
| AC-2 | Type N is the declared empty-argv type |
| AC-3 | `install` remains an explicit command |
| AC-4 | Interactive empty argv uses `app_main_menu` (numbered list) |
| AC-5 | Non-interactive empty argv is help (no hang, no numbered list) |
| AC-6 | Explicit `help` still prints full usage |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-cli-interface` | Dispatcher command table |
| `requirement-shell-cli-default-interaction` | Numbered list + TTY/off-TTY for empty argv and `menu`/`main` |
| `requirement-shell-local-self-management` | Explicit install |
| `requirement-bootstrap-chain` | Trim of Type O from parent |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-CLI-07** | `tests/test_cli.sh` | **have** — off-TTY empty argv is help; not install (AC-1, AC-5) |
| **TP-CLI-13** | `tests/test_cli.sh` | **have** — interactive empty argv and `menu` print the list (AC-4) |
| **TP-CLI-15** | `tests/test_cli.sh` | **have** — non-interactive empty argv / `menu` is help (AC-5) |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active 1.0.0 | Type N for local-only take-ownership; empty argv = help |
| 2026-08-30 | Active 1.1.0 | Type N kept (no install); empty argv routes to `app_main_menu` (same as `menu`/`main`) |

---

**Last Updated**: 2026-08-30  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
