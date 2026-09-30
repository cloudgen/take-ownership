**file**: docs/requirements/requirement-shell-cli-zero-arguments.md  
**Status**: Active (Version 2.0.1)  
**Area**: shell  
**Key**: `requirement-shell-cli-zero-arguments`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for **zero-argument (empty argv) dispatcher behavior** of the take-ownership POSIX shell CLI.

### 1.0 Product type

| Field | Value for take-ownership |
|-------|-------------------------|
| **Empty-argv type** | **Type O-S — Online script-alone** (off-TTY) **plus** TTY numbered menu |
| **Rationale** | Product advertises `curl … \| sh`; pipe empty argv is install-ensure. A real terminal keeps the daily-work menu. |

Type N (non-online-install → empty argv = help) does **not** apply.

**Empty argv** means **no command token** after global-flag parse. Overlay switches (`--debug`, `--quiet`/`-q`, `--force`) **do not** disqualify empty argv.

This file owns the TTY vs off-TTY split for **no command token**. List membership lives in `requirement-shell-cli-default-interaction`.

### 1.1 Human-facing

**In one sentence:** Typing only `take-ownership` at a prompt shows the numbered work list; piping the script (`curl | sh`) installs or reports already installed. `take-ownership --json` is JSON help.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Type `take-ownership` at a prompt | numbered list |
| The other role | `curl \| sh` / a script with no command | install-ensure, not help |
| Not this file | Menu row labels | `requirement-shell-cli-default-interaction` |

| Includes | Excludes |
|----------|----------|
| TTY empty argv = numbered list; off-TTY = install-ensure | Help on a pipe; a hanging menu in a script |
| `--json` with no command = JSON help | Domain `action` with no verb |

| Surface | What you open | What for |
|---------|---------------|----------|
| `./take-ownership` | ship unit | empty-argv branch |
| `curl … \| sh` | one-liner | first install |
| `take-ownership help` | command | full usage |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Pipe the script | Install-ensure | `curl -fsSL …/take-ownership \| sh` |
| Start at a prompt | Numbered list | `take-ownership` then `1` |
| Ask for JSON usage | JSON help (empty argv special case) | `take-ownership --json` |

---

## 2. Core Rules (Mandatory)

### 2.1 Single meaning of empty argv

1. **Empty argv** is: after global-flag parse, **no command token** was present. Overlay `--debug` / `--quiet` / `--force` still empty argv.  
2. **Interactive** (`TTY=1`): route to `app_main_menu` (numbered work list). **MUST NOT** install-ensure. **MUST NOT** print the help dump.  
3. **Not interactive** (`TTY=0`): **Type O install-ensure**. **MUST NOT** print help. **MUST NOT** draw the numbered list. **MUST NOT** prompt. Not installed → download from `SCRIPT_URL` and place. Already installed → success no-op (no `--force` required). `--force` re-downloads.  
4. **`--json` special case:** `--json` with no command token **is** empty argv. Outcome **MUST** be JSON help on **TTY and off-TTY**. **MUST NOT** the numbered list. **MUST NOT** Type O ensure.  
5. Explicit `take-ownership help` remains full usage.  
6. Explicit `take-ownership install` remains ensure.  
7. Explicit `take-ownership menu` / `main` remain the numbered list (TTY) / help (off-TTY).  
8. Script entry **MUST** always call `app_main "$@"` (no basename gate). Pipe-safe.  
9. The dispatcher **MUST** decide empty argv **after** flag parse.

### 2.2 Normative matrix

| Invocation | Behavior |
|------------|----------|
| `take-ownership` (no args), interactive (`TTY=1`) | Numbered work list (`app_main_menu`); same as `take-ownership menu` |
| `take-ownership` (no args), non-interactive (`TTY=0`) | Type O install-ensure; **MUST NOT** prompt |
| `take-ownership --json` (no command) | JSON help (TTY and off-TTY) |
| `take-ownership help` | Show help; exit 0 |
| `take-ownership install` | Channel install-ensure |
| `take-ownership menu` / `main` | Numbered list on TTY; help off-TTY |

### 2.3 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `take-ownership` |
| **Type** | **Type O off-TTY + TTY menu** |
| **Default empty-argv handler** | TTY `app_main_menu`; off-TTY `inst_empty_argv_ensure`; `--json` JSON help |
| **Default COMMAND after flags with no token** | TTY `menu`; off-TTY `ensure`; `--json` `help` |
| **Contrast parent** | cli-template is Type N help-default. This product is online-installable: off-TTY empty argv is Type O install-ensure; a real terminal uses the numbered list. |

### 2.4 Why This Requirement Exists (CIAO)

- **Principle 2 – Intentional**: Empty argv meaning is explicit: off-TTY Type O install-ensure, and the numbered list on a real terminal.  
- **Principle 1 – Caution**: A pipe installs. A terminal does not. An unreachable channel fails loud.  
- **Principle 16 – Interactive**: TTY list vs pipe ensure; no hang.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: Off-TTY ensure does not draw a menu. TTY empty argv does not install.  
- **Intentional**: Type O off-TTY; a real terminal shares `app_main_menu` with `menu` / `main`.  
- **Anti-fragile**: An unreachable channel is non-zero and not silent; explicit `help` is still full usage.  
- **Over-protect**: Do not turn TTY empty argv into install-ensure. Do not turn a pipe into the help dump.

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
| AC-1 | Off-TTY empty argv is Type O install-ensure (non-zero and not silent when the channel is unreachable) |
| AC-2 | Declared type is Type O off-TTY plus a TTY menu (Type N does not apply) |
| AC-3 | `install` remains an explicit command |
| AC-4 | Interactive empty argv uses `app_main_menu` (numbered list) |
| AC-5 | Non-interactive empty argv does not hang, does not draw the numbered list, and is not the help dump |
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
| **TP-CLI-07** | `tests/test_cli.sh` | **have** — off-TTY unreachable channel is non-zero, not the numbered list, not the help dump (AC-1, AC-5) |
| **TP-CLI-13** | `tests/test_cli.sh` | **have** — interactive empty argv and `menu` print the front board (AC-4) |
| **TP-CLI-15** | `tests/test_cli.sh` | **have** — non-interactive `menu` is help; off-TTY empty argv is not that help dump (AC-5) |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## Under command line for normal user only

When this program runs on Termux, Git Bash, or Windows Command Prompt, it **MUST** stay on **your own login**. Empty argv keeps the same split as §2.1 (TTY menu, off-TTY Type O ensure). That ensure **MUST NOT** wrap `sudo`.

Detect (typical): Termux — `PREFIX` contains `com.termux`; Git Bash — `MSYSTEM` is `MINGW*` / `MSYS*`; Windows cmd — `OS=Windows_NT` after excluding Git Bash / WSL.

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active 1.0.0 | Type N for local-only take-ownership; empty argv = help |
| 2026-08-30 | Active 1.1.0 | Type N kept (no install); empty argv routes to `app_main_menu` (same as `menu`/`main`) |
| 2026-09-08 | Active 2.0.0 | Online-installable: off-TTY empty argv is Type O; TTY menu kept (§1–§2.1) |
| 2026-09-30 | Active 2.0.1 | Acceptance, notes, and principles aligned with §2.1. They still said Type N / help after the 2.0.0 purpose edit. |

---

**Last Updated**: 2026-09-30  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
