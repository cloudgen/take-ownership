**file**: docs/requirements/requirement-shell-output-requirements.md  
**Status**: Active (Version 1.1.0)  
**Area**: shell  
**Key**: `requirement-shell-output-requirements`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for **all CLI output** of take-ownership: human messages, machine JSON, channel split (stdout vs stderr), and mode behavior (normal / quiet / JSON / debug).

Inherited architecture from bootstrap parent **cli-template** (`out_*` family); retargeted for this product’s identity and domain messages.

### 1.1 Human-facing

**In one sentence:** Every line this program shows you — info, errors, JSON, and the numbered list — comes from one printer family, not mixed raw prints.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Read `[INFO]` / `[ERROR]` / JSON on the terminal | `take-ownership version` |
| The other role | Scripts parse `--json` without human banners | `take-ownership --json version` |
| Not this file | Which commands exist, or the wording of one domain error | `requirement-shell-cli-interface` |

| Includes | Excludes |
|----------|----------|
| `out_*` human and JSON printers | Raw `echo` of user banners |
| Menu identity token and numbered-row ink | Which verbs belong on the list |
| Quiet / JSON / TTY color guards | Help catalog membership |

| Surface | What you open | What for |
|---------|---------------|----------|
| `./src/take-ownership` | ship unit | `out_*` / `util_app_ident` |
| `take-ownership --json help` | command | one JSON object on stdout |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Open the numbered list | Header names **take-ownership**(*live version*); descriptions after the colon are italic and light gray on a real terminal | `take-ownership` |
| Pipe the same command | No colors, no slant | `take-ownership </dev/null` |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Sacred core rule

**All user-facing and machine-facing product output MUST go through the centralized output system.**

| Forbidden outside the output module | Prefer |
|-------------------------------------|--------|
| Raw `echo` / bare `printf` for **user messages** | `out_info`, `out_success`, `out_warn`, `out_error`, `out_plain`, … |
| Direct `printf` of JSON from command logic | `out_json` / `out_json_error` |
| Ad-hoc `echo >&2` diagnostics | `out_warn` / `out_error` / `out_debug` |
| Second parallel print helper that bypasses mode guards | Extend `out_text` / wrappers only |

### 2.1.1 Allowed `printf` / `echo` exceptions

| Exception class | Rule |
|-----------------|------|
| **A. Inside output SSOT** | Only `out_text`, `out_json`, and `out_json_error` may `printf` to fd 1/2 for product human or JSON lines |
| **B. Function return-via-stdout** | Helpers may `printf '%s' "$value"` solely for `$(…)` capture (data return, not UI) |
| **C. File I/O (redirected)** | Writing config/sudoers draft files is file mutation; user-visible status still via `out_*` |
| **D. Tool protocol / computation pipes** | e.g. feeding `tar`/`gzip`/`sha256sum` via pipes; product status still via `out_*` |
| **E. Command-sub fallbacks** | Logic defaults only (`id -un \|\| echo "unknown"`) |

### 2.2 Output function catalog

| Function | Purpose | Typical channel | Quiet | JSON |
|----------|---------|-----------------|-------|------|
| `out_text` | SSOT for human levels | Level-dependent | Filters | Suppress all human levels |
| `out_info` | Informational | stdout | Suppress | Suppress human |
| `out_success` | Success / OK | stdout | Suppress | Suppress human |
| `out_warn` | Warning | stderr | Should still show | Prefer structured status when designed |
| `out_error` | Error | stderr | Always show (human) | Prefer `out_json_error` / `out_die` |
| `out_die` | Fatal + exit 1 | stderr (+ JSON error when JSON) | Always | Emits JSON error then exits |
| `out_plain` | Plain text, no prefix | stdout | Suppress under quiet | Suppress under JSON |
| `out_menu_choice` | Numbered menu row; TTY *italic* + light-gray explain | stdout | Suppress under quiet | Suppress under JSON |
| `out_msg_n` | Prompt fragment without newline | stdout | Suppress under quiet/json | Never for machines |
| `util_app_ident` | Identity token **bold** name / *italic* version (capture into `out_*`) | pipeline (class B) | n/a | Plain `take-ownership(VERSION)` when `TTY=0` or `JSON=1` |
| `out_json` | Machine success/status object | stdout | N/A | Only when `JSON=1` |
| `out_json_error` | Machine error object | as designed for fatal path | N/A | Only when `JSON=1` |

### 2.3 Channel contract

| Channel | Allowed content (via `out_*` only) |
|---------|-------------------------------------|
| **stdout (fd 1)** | Human info/success/plain in normal mode; **exactly one** JSON value in JSON mode for success/status |
| **stderr (fd 2)** | Errors, warnings, debug/diagnostics |

Rules:

1. Fatal paths use `out_die` / `out_json_error`.  
2. JSON mode: no colors, banners, or progress mixed into stdout JSON.  
3. Capture pattern: `take-ownership --json <cmd> 2>err.log`.  
4. **No secrets** on either channel (tokens, passwords, private keys, full private key material).

### 2.4 Mode behavior

| Mode | Contract |
|------|----------|
| Normal (TTY) | Prefixed human messages; colors only when TTY and not quiet/json |
| Quiet | Suppress info/success/plain; still show errors (and should show warnings) |
| JSON | Force quiet; structured JSON only on success path; structured errors on failure |
| Debug | Extra diagnostics on stderr; suppressed under JSON purity rules for stdout |

### 2.4.1 Operator identity and numbered-row ink (mandatory)

When a **human** line **names the running program** (main-menu header, about title, other “who is talking” banners), it **MUST** print live `take-ownership(VERSION)`: **name bold**, **version italic**. Markdown written form: `**take-ownership**(*VERSION*)`. TTY: SGR **1** on the name, SGR **3** on the version. Off-TTY / JSON: **plain** `take-ownership(VERSION)` — **MUST NOT** emit CSI.

Numbered menu rows **MUST** go through `out_menu_choice`. On a TTY the `explain` after the colon is *italic* and light gray (SGR **3** + **37**). Number and command name stay unstyled. Off-TTY / JSON: plain. This is the default CLI main menu style (`requirement-shell-cli-default-interaction`).

| MUST | MUST NOT |
|------|----------|
| Main-menu headers; about identity titles | Usage / `Next:` invocation lines (`take-ownership <verb>`) |
| Live Config `APP_NAME` and `VERSION` (same scalars as `version`) | A bare `take-ownership` on that header |
| TTY: bold name, italic version; off-TTY: plain `take-ownership(VERSION)` | CSI when `TTY=0` or `JSON=1`; raw CSI in README fences |
| Still via `out_*` (quiet/JSON rules unchanged) | Glue the token into JSON as the only `app`/`version` fields |

Proof when the numbered menu is claimed: **TP-CLI-19** (product alias of portable **TP-CLI-17**).

### 2.5 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `take-ownership` |
| **Ship unit** | `src/take-ownership` |
| **Human prefixes** | `[INFO]`, `[OK]`, `[WARN]`, `[ERROR]` (or equivalent consistent set) |
| **Identity token** | `util_app_ident` → `take-ownership(VERSION)` |
| **Menu rows** | `out_menu_choice n verb explain` |
| **Domain messages** | Take-ownership progress/results and sudoers-print status **must** use `out_*` |
| **Bootstrap inheritance** | Same `out_*` family as cli-template |

### 2.6 Why This Requirement Exists (CIAO)

- **Principle 5 – Single Source of Output**  
- **Principle 14 – Security & Traceability** (stdout vs stderr)  
- **Principle 1 – Caution** (fail loud, never silent corruption of JSON pipes)

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Never hide fatal errors under quiet.  
- **Intentional:** One emitter family.  
- **Anti-fragile:** JSON/human/quiet all work offline.  
- **Over-protect:** Do not “simplify” by scattering echo.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Introduce a second product messaging stack beside `out_*`.  
2. Print user-facing banners with raw `echo` outside allowed exceptions.  
3. Mix human text into JSON stdout success paths.  
4. Log secrets or private key material.  
5. Remove quiet/json contracts for “simplicity.”  
6. Print a main-menu (or APP_NAME-led) header as a bare `take-ownership`, or emit CSI off-TTY.  
7. Bypass `out_menu_choice` for numbered-choice rows, or print TTY `explain` unstyled.

**Violating this rule is a critical output SSOT regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | All product messages route through `out_*` |
| AC-2 | JSON mode produces structured success/error without human interleave |
| AC-3 | Quiet still surfaces errors |
| AC-4 | Domain take-ownership messaging uses the same SSOT |
| AC-5 | Menu header uses live `take-ownership(VERSION)` via `util_app_ident`; numbered rows use `out_menu_choice` |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-cli-interface` | Modes and flags |
| `requirement-shell-cli-default-interaction` | Numbered-list look consumes this printer family |
| `requirement-shell-interactive-vs-noninteractive` | Prompt vs auto |
| `requirement-domain-take-ownership` | Domain message payloads |
| `requirement-operator-readable-error` | Operator error **wording** (human-intro style) |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-CLI-03** | `tests/test_cli.sh` | **have** — version JSON purity |
| **TP-CLI-05** | same | **have** — help JSON |
| **TP-CLI-09** | same | **have** — quiet still surfaces errors |
| **TP-CLI-19** | same | **have** — identity token + numbered-row ink (AC-5) |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

---

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active | Output SSOT for take-ownership |
| 2026-09-03 | Active 1.1.0 | `util_app_ident` / `out_menu_choice`; default CLI main menu style ink |

---

**Last Updated**: 2026-09-03  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
