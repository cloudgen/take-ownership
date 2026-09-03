**file**: docs/requirements/requirement-shell-cli-default-interaction.md  
**Status**: Active (Version 2.4.0)  
**Area**: shell  
**Key**: `requirement-shell-cli-default-interaction`  
**Optional RQ-ID**: `RQ-SHELL-CLI-DEFAULT-INTERACTION`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **product Single Source of Truth** for take-ownership’s **default interaction**: a **short numbered main menu** of daily **folder work**, with sudoers grant/draft commands behind one **family** row. take-ownership has `requirement-shell-cli-zero-arguments` (**case 3**): that REQ **defers TTY empty argv** to this menu and **owns off-TTY empty argv as Type N help**. The menu **MUST** also be the command **`menu`**. **`main` MAY** be accepted as the same handler.

On a **real terminal**, empty argv and `take-ownership menu` (or `main`) **MUST** show the main menu. `menu`/`main` **MUST ignore `--json`**. Off-TTY, **`menu`/`main` MUST** print **help**, following `--json`. Off-TTY **empty argv** is **not** this file — it is Type N help on the zero-argument REQ. Command rows **MUST** be `command: what it does`. The family row **MUST NOT** be a live dispatcher command.

Empty-argv type and the TTY vs off-TTY split for **no command token** stay on `requirement-shell-cli-zero-arguments`. Confirm / no-hang stays on `requirement-shell-interactive-vs-noninteractive`. Live command inventory stays dispatcher truth (`requirement-shell-cli-interface`).

### 1.1 Human-facing

**In one sentence:** At a real terminal, type `take-ownership` (or `take-ownership menu`) to see **take-ownership**(*version*) then numbered daily work plus **sudoers**; pick **sudoers** for grant/drafts; in a pipe you get help, never a hanging prompt.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Open the list or pick a number | `take-ownership` then `1` (action) |
| The other role | Scripts and CI must not hang on that list | `take-ownership` or `take-ownership menu` in a pipe → help |
| Not this file | Empty argv is Type N (never install) | `requirement-shell-cli-zero-arguments` |

| Includes | Excludes |
|----------|----------|
| TTY empty argv numbered list; `menu`/`main` numbered TTY main list | `help` as a row |
| Default CLI main menu style (header `APP_NAME(APP_VERSION)`; TTY explain italic + light gray) | A bare `take-ownership` on that first line; color codes in a pipe |
| Family row **sudoers** + submenu; Exit **9**; Back **8**; off-TTY `menu` help | `install`, `uninstall`, `where-is-me`, `version`, `about`; `setup`; `menu`/`main` as a choice; `list-folders` (help verb, not a menu row) |
| Empty argv **and** `menu` / `main` as the same list | A live `sudoers` dispatcher token; test-purpose `generate-sudoer-json` on either list |

| Surface | What you open | What for |
|---------|---------------|----------|
| `./src/take-ownership` | ship unit | live dispatch (empty argv / `menu` / `main`) |
| `take-ownership help` | command | listed verbs including lifecycle |
| `take-ownership` | no command | numbered list on TTY |
| `take-ownership menu` | command | same numbered list |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Open the list at a prompt | Daily folder work; **action** is **1**; **sudoers** is **2**. `--json` is ignored on a real terminal for `menu`/`main`. | `take-ownership` or `take-ownership menu` |
| Take ownership from the list | Choose `action`, then pick a numbered allowed folder. Ownership is this login’s `user:group` (no prompt). | `1` then `1` |
| Open grant/drafts | Family row **2**, then a number | `take-ownership` then `2` then `1` |
| Leave the grant list | Back to the start list | `8` |
| Leave the menu | Exit | `9` |
| Run menu in CI | No prompt. Human help, or JSON help with `--json` on the `menu` verb. | `take-ownership menu </dev/null` |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Claim and case

1. This product **claims** a default interactive main menu.  
2. **Case 3** applies: a specialized zero-argument requirement exists **and** the product is **not** online-installable. Empty argv **MUST** follow `requirement-shell-cli-zero-arguments`.  
3. That zero-argument requirement **MUST** route empty argv to **this** menu handler (`app_main_menu`). **MUST NOT** keep empty argv as TTY help while this menu is claimed.  
4. The menu **MUST** also be routed-verb **`menu`**. **`main` MAY** call the same handler.  
5. `app_main` **MUST** route empty argv, `menu`, and `main` to `app_main_menu`.

### 2.2 Mode check (empty argv, `menu`, and `main`)

Measure interactive capability **outside functions** (`TTY=1` only when stdin and stdout are terminals). Helpers consume `TTY` (`requirement-shell-interactive-vs-noninteractive`).

| Invocation | Mode | `--json` | MUST | MUST NOT |
|------------|------|----------|------|----------|
| `take-ownership` (no args) | Interactive (`TTY=1`) | N/A (no flags) | Draw the numbered list | Treat as help; hang; install |
| `take-ownership` (no args) | Non-interactive (`TTY=0`) | N/A | **Help** (human) | Draw the menu; hang; silent return; install |
| `take-ownership menu` or `main` | Interactive (`TTY=1`) | **Ignore** | Draw the numbered list | Treat as JSON help; hang |
| same | Non-interactive (`TTY=0`) | **Follow** | **Help**: human when JSON=0; JSON help when JSON=1 | Draw the menu; hang; silent return |

`--quiet` off-TTY is still the help path (do not swallow help). Reuse `app_help` — **MUST NOT** invent a second JSON help catalog.

### 2.3 Main menu

0. **Look (mandatory):** the numbered list **MUST** use the default CLI main menu style. Header **MUST** print live `take-ownership(VERSION)` (no space; same Config scalars as `version`) then the product short description (`SHORT_DESCRIPTION` / `APP_DESC`). On a TTY the name is **bold** and the version *italic*. Each numbered `explain` **MUST** be *italic* and light gray on a TTY (SGR 3 + 37). Number and command name stay unstyled. Off-TTY / JSON: **plain** — **MUST NOT** emit CSI. Typical helpers: `util_app_ident` then `out_menu_choice`. **MUST NOT** a bare `take-ownership` on that header. **MUST NOT** print `explain` unstyled on a TTY. **MUST NOT** freeze “numbered list of live work commands” as the header suffix.  
1. Print a **numbered list** of **daily folder work** plus one **family** row, then **Exit**.  
2. **MUST NOT** list **install / setup**, **self-managed** commands (`install`, `uninstall`, `where-is-me`), **diagnostics** (`version`, `about`), or **test-purpose** verbs. On this product the test-purpose verb **MUST** be `generate-sudoer-json`.  
3. Command-row text **MUST** be `command: what it does`.  
4. **MUST NOT** list `help`, `menu`/`main`, `list-folders`, or the five sudoers verbs on the **main** list (sudoers verbs live on the submenu; `list-folders` stays a live help verb).  
5. Main command rows **N = 2** (one verb + one family). Exit **MUST** be **9**. Unused integers **3–8** are omitted.  
6. Accept a **number** or a **listed verb**. **9** / `exit` / `quit` returns 0.  
7. **`sudoers` is not a live CLI command.** Choosing **2** or typing `sudoers` at the pick prompt **MUST** open the submenu (§2.4). `take-ownership sudoers` **MUST** remain unknown.  
8. Typing a submenu verb at the **main** pick prompt **MAY** run that handler (shortcut).  
9. Extra operands: prompt **one field at a time** on TTY, or print `Next: take-ownership <verb> …` and return.  
10. **Do not capture `read`:** the choice **MUST** be read in the **current shell**. Typical: `prompt_line "Choice"` then `_pick="${_prompt_line}"`. **MUST NOT** `_pick=$(prompt_line …)` / `_pick=$(prompt_ask …)` / `$()` / backticks of **any** function whose body contains `read`. stderr+$() is **not** a license.

Normative **main** order:

| # | Token | Label |
|---|-------|-------|
| *(header)* | — | `take-ownership(VERSION) — Take Unix ownership of a named folder with a narrow global-only sudo grant` |
| 1 | `action` | `action: Recursively take ownership of a named folder` |
| 2 | family `sudoers` | `sudoers: Grant and drafts` |
| **9** | **Exit** | leave the menu |

### 2.4 Sudoers submenu

Choosing main **2** / `sudoers` **MUST** print a second numbered list of the grouped live verbs. Submenu header **MUST** use the same `APP_NAME(APP_VERSION)` nametag, then ` — sudoers (grant and drafts)`. Explain text **MUST** follow the same default CLI main menu style as the main list (*italic* + light gray SGR **3** + **37** on a TTY via `out_menu_choice`). **MUST NOT** hang off-TTY (submenu exists only on the interactive menu path).

| # | Command | Label |
|---|---------|-------|
| 1 | `generate-sudoer-request` | `generate-sudoer-request: Write a JSON grant you can read` |
| 2 | `submit-sudoer-request` | `submit-sudoer-request: Queue the JSON grant inbound` |
| 3 | `print-sudoers` | `print-sudoers: Emit sudoers draft` |
| 4 | `print-sudoers-install-script` | `print-sudoers-install-script: Write admin install script` |
| 5 | `remove-project-sudoers` | `remove-project-sudoers: Remove sudoers draft only` |
| **8** | **Back** | return to the main list (not a command) |
| **9** | **Exit** | leave the menu |

Submenu command rows **N = 5**. Exit **MUST** be **9**. **Back MUST** be **8**. Unused **6** and **7** are omitted.

- **8** / `back` / `Back` returns to the main list (does not run a handler).  
- **9** / `exit` / `quit` returns 0 from `menu` (same as main Exit).  
- A listed number or verb runs that handler, then returns 0 from `menu` (one command, then done).  
- All five grouped verbs **MUST** appear here. **MUST NOT** put install/version/about/`help`/`setup`/`generate-sudoer-json` on this list.

The five grouped verbs **MUST** remain live dispatcher commands (`requirement-shell-cli-interface`). Opening them from the submenu **MUST** call the same handlers as typing `take-ownership generate-sudoer-request` (and the other four). **MUST NOT** add a live `sudoers` token to `app_main`.

### 2.5 Implementation Notes (this product)

| Item | Value |
|------|--------|
| **Product** | `take-ownership` |
| **Claimed** | yes |
| **Case** | **3** (zero-arg REQ exists; local-only; that REQ routes empty argv **to this handler**) |
| **Empty argv owner** | `requirement-shell-cli-zero-arguments` (Type N; handler `app_main_menu`) |
| **Menu verbs** | `menu` (preferred); `main` alias; empty argv same handler |
| **Handler** | `app_main_menu` (`app_main_menu_print` / `app_main_menu_print_sudoers` / `app_main_menu_run_pick` / `app_main_menu_run_sudoers_pick` / `app_main_menu_sudoers_loop`) |
| **Ship unit** | Implemented — `app_main` routes empty argv, `menu`, and `main` to `app_main_menu` |
| **Family row** | `sudoers` — menu-only; **not** dispatched |
| **Label source** | `reviews/cli-routed-verb-table.md` **human-readable** for command rows; family explain is this file’s table |
| **Look** | Default CLI main menu style — header `take-ownership(VERSION)` then `SHORT_DESCRIPTION`; TTY italic + light-gray explain; `out_menu_choice` / `util_app_ident` |
| **Choice read** | Current-shell `prompt_line` → `_prompt_line` (not `$()`) |
| **N (main)** | 2 |
| **N (submenu)** | 5 |
| **Exit** | 9 (both lists) |
| **Back** | 8 (submenu only) |
| **Test-purpose (this product)** | `generate-sudoer-json` (off both lists; stays on `help` apart) |

**Normative menu draft** (operational only; self-managed, diagnostics, and test-purpose omitted). README example look uses these **plain glyphs** (no CSI, no markdown restyle); the live TTY uses SGR:

```text
[INFO] take-ownership(VERSION) — Take Unix ownership of a named folder with a narrow global-only sudo grant
1. action: Recursively take ownership of a named folder
2. sudoers: Grant and drafts
9. Exit
Choice:
```

**Invocation samples (CI-M1a):**

```text
take-ownership
take-ownership menu
take-ownership main
take-ownership menu --json
```

On a real terminal those four **MUST** show the list (`--json` is ignored for `menu`/`main` on TTY; empty argv has no flags). Off-TTY, `take-ownership` and `take-ownership menu` **MUST** call help; `take-ownership menu --json` **MUST** call JSON help.

### 2.6 Why This Requirement Exists (CIAO)

- **Principle 2 – Intentional**: Daily folder work is the start list; grant/draft commands are one extra pick.  
- **Principle 1 – Caution**: Scripts do not hang; `--json` on a real terminal does not hide the `menu` list.  
- **Principle 16 – Interactive vs non-interactive**: TTY vs pipe is explicit.  
- **Principle 10 – Least privilege**: Install/uninstall, version/about, and test-purpose `generate-sudoer-json` are not on either list. `sudoers` is not a live dispatcher token.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Do not hang off-TTY; do not steal Type O install-ensure.  
- **Intentional:** Case 3; empty argv and `menu`/`main` share one handler; labels from the kept list; related rare commands share one family row.  
- **Anti-fragile:** `main` may alias `menu`; Back returns to the start list; Exit leaves from either screen.  
- **Over-protect:** Self-managed, diagnostics, and test-purpose stay off both lists; Exit is **9**, not **3**; `sudoers` is not added to the dispatcher.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Route interactive empty argv to help while this menu is claimed and `requirement-shell-cli-zero-arguments` says empty argv uses `app_main_menu`.  
2. Invent menu labels instead of `command: what it does` from the kept list (family explain is this file).  
3. Put `help`, `install`, `uninstall`, `where-is-me`, `version`, `about`, `setup`, `menu`, `main`, `list-folders`, or a test-purpose verb (`generate-sudoer-json`) on the numbered main list or the sudoers submenu.  
4. Put the five sudoers verbs on the **main** list.  
5. Drop a grouped sudoers verb from the submenu.  
6. Number main Exit as **3** or submenu Exit as **6** (Exit **MUST** be **9**; Back **MUST** be **8** on the submenu).  
7. Wire `sudoers` as a live `app_main` command.  
8. Draw the menu in non-interactive mode, or hang a pipe on empty argv / `menu` / `main`.  
9. Treat interactive `take-ownership menu --json` as JSON help.  
10. Claim the ship unit lacks the menu while `app_main` routes empty argv / `menu` / `main`.  
11. Auto-write `/etc` from a menu choice (print/submit stay Type 0 drafts).  
12. Turn empty argv into install-ensure.  
13. Print the header as a bare `take-ownership` without the live version, or emit CSI off-TTY.  
14. Print TTY `explain` unstyled, or bypass `out_menu_choice` for numbered-choice rows.  
15. Capture the menu choice with `$()` / backticks of a `read` helper.  
16. Print the generic board title “numbered list of live work commands” instead of Config `SHORT_DESCRIPTION` / `APP_DESC`.

**Violating this rule is a critical dispatcher / hang / honesty regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Empty argv uses `app_main_menu` (TTY list; off-TTY help); never install |
| AC-2 | Case 3 recorded; empty argv, `menu`, and `main` named and routed |
| AC-3 | Interactive `menu` **and** interactive empty argv draw the two-row list (`action`, family `sudoers`) + Exit 9; no `list-folders` row; no five sudoers verbs on the **main** list |
| AC-4 | Interactive `menu --json` still draws the list |
| AC-5 | Non-interactive `menu` and empty argv are help; `menu --json` is JSON help |
| AC-6 | Numbered choices omit help, install, uninstall, where-is-me, version, about, setup, menu, main, list-folders, and test-purpose (`generate-sudoer-json`) |
| AC-7 | Labels match kept-list human-readable `verb: explain` for command rows; family explain is `Grant and drafts` |
| AC-8 | Header is live `take-ownership(VERSION)` (bold name, italic version on TTY) then `SHORT_DESCRIPTION`; numbered `explain` is italic + light gray on TTY; no CSI off-TTY |
| AC-9 | Menu choice is read in the current shell; **MUST NOT** `$()` a `read` helper |
| AC-10 | Choosing **2** / `sudoers` on TTY opens the five-verb submenu with Back **8** and Exit **9** |
| AC-11 | `take-ownership sudoers` is unknown (not a live dispatcher token) |
| AC-12 | Submenu member verbs remain live CLI commands and share the same handlers as the typed verbs |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-cli-zero-arguments` | Empty argv Type N; routes to this handler |
| `requirement-shell-cli-interface` | Dual mention: empty argv + `menu` / `main` on the command table; five sudoers verbs routed |
| `requirement-shell-interactive-vs-noninteractive` | `TTY`; no hang |
| `requirement-shell-output-requirements` | `out_*` / `util_app_ident` / `out_menu_choice`; reuse `app_help` |
| `requirement-shell-local-self-management` | install/uninstall/where-is-me stay on help, not this list |
| `requirement-domain-take-ownership` | Domain catalog; grant-emit live verbs |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-CLI-07** | `tests/test_cli.sh` | **have** — off-TTY empty argv still help; not install (AC-1, AC-5) |
| **TP-CLI-13** | `tests/test_cli.sh` | **have** — interactive `menu` **and** interactive empty argv print `action` + family `sudoers` + `9. Exit`; submenu Back/Exit; `sudoers` unknown (AC-3, AC-10, AC-11) |
| **TP-CLI-14** | same | **have** — interactive `menu --json` still prints the list (AC-4) |
| **TP-CLI-15** | same | **have** — non-interactive `menu` and empty argv are help; `--json` JSON help (AC-5) |
| **TP-CLI-16** | same | **have** — numbered list omits help/install/uninstall/where-is-me/version/about/test-purpose/menu (AC-6); static no `$()` of `read` (AC-9) |
| **TP-CLI-19** | same | **have** — default CLI main menu style: header `take-ownership(VERSION)` bold/italic then short description; numbered explain italic + light gray; no CSI off-TTY (AC-8; product alias of portable **TP-CLI-17**) |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-23 | Active 1.0.0 | Case 3 claimed; menu/main Gap; nine-row list; Exit 99 |
| 2026-08-23 | Active 1.1.0 | Colon labels; exclude version/about; test-purpose print-sudoers / generate-sudoer-request / print-sudoers-install-script; N=4 Exit 9 |
| 2026-08-23 | Active 1.2.0 | Ship unit routes `menu` / `main`; Gap closed |
| 2026-08-25 | Active 2.0.0 | take-ownership: N=3 (`action`, remove, submit); Exit 9 |
| 2026-08-26 | Active 2.1.0 | Test-purpose list includes `generate-sudoer-json` (still off the numbered menu; N=4) |
| 2026-08-30 | Active 2.2.0 | Empty argv routes to `app_main_menu` (same as `menu`/`main`); Case 3 kept; Type N still never install; N=3 (`list-folders` off the numbered list, still a live help verb) |
| 2026-09-03 | Active 2.3.0 | Default CLI main menu style: header `take-ownership(VERSION)` bold/italic; TTY gray italic explain; `out_menu_choice` / `util_app_ident`; do-not-capture-read |
| 2026-09-03 | Active 2.4.0 | Family row **sudoers** + five-verb submenu (sibling grok-cli pattern). Main **N = 2**; submenu **N = 5**; Back **8**; `sudoers` not dispatched. Header board title is product short description. Test-purpose is only `generate-sudoer-json`. |

---

**Last Updated**: 2026-09-03  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
