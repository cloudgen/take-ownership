**file**: docs/requirements/requirement-shell-cli-default-interaction.md  
**Status**: Active (Version 2.2.0)  
**Area**: shell  
**Key**: `requirement-shell-cli-default-interaction`  
**Optional RQ-ID**: `RQ-SHELL-CLI-DEFAULT-INTERACTION`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **product Single Source of Truth** for take-ownership’s **claimed default interactive main menu**. A specialized zero-argument requirement exists (`requirement-shell-cli-zero-arguments`): empty argv is Type N (never install) **and** routes to this menu handler. The numbered list therefore opens with **`take-ownership`** (no args), **`take-ownership menu`**, or **`take-ownership main`**. The ship unit routes those three paths to `app_main_menu`.

### 1.1 Human-facing

**In one sentence:** At a real terminal, type `take-ownership` (or `take-ownership menu`) to see a numbered list of live work commands; in a pipe you get help, never a hanging prompt.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Open the list or pick a number | `take-ownership` then `1` (action) |
| The other role | Scripts and CI must not hang on that list | `take-ownership` or `take-ownership menu` in a pipe → help |
| Not this file | Empty argv is Type N (never install) | `requirement-shell-cli-zero-arguments` |

| Includes | Excludes |
|----------|----------|
| Numbered live work commands | `help` as a row |
| Line `command: what it does` | `install`, `uninstall`, `where-is-me`, `version`, `about` |
| Exit as **9** (three command rows) | `setup`, `menu`/`main` as a choice; `list-folders` (help verb, not a menu row) |
| Empty argv **and** `menu` / `main` as the same list | Test-purpose: `print-sudoers`, `print-sudoers-install-script`, `generate-sudoer-request`, `generate-sudoer-json` |

| Surface | What you open | What for |
|---------|---------------|----------|
| `./src/take-ownership` | ship unit | live dispatch (empty argv / `menu` / `main`) |
| `take-ownership help` | command | listed verbs including lifecycle |
| `take-ownership` | no command | numbered list on TTY |
| `take-ownership menu` | command | same numbered list |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Open the list at a prompt | The program prints numbers 1–3 then 9 Exit. `--json` is ignored on a real terminal for `menu`/`main`. | `take-ownership` or `take-ownership menu` |
| Take ownership from the list | Choose `action`, then pick a numbered allowed folder. Ownership is this login’s `user:group` (no prompt). | `1` then `1` |
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

### 2.3 Numbered list (when the case says menu)

1. Print a **numbered list** at the start of the interactive menu path.  
2. Each command row is one live **operational** command that is **not** excluded below, numbered **1 … N** in kept-list order.  
3. Printed line **MUST** be the kept-list **human-readable** value: **`command: what it does`** (short-descript = the command token).  
4. **MUST NOT** list `help`, `menu`, `main`, gap/forbidden names, **diagnostics** (`version`, `about`), **self-managed / install-setup** tokens (`install`, `uninstall`, `where-is-me`, `setup`), or **test-purpose** verbs. On this product the test-purpose verbs **MUST** be `print-sudoers`, `print-sudoers-install-script`, `generate-sudoer-request`, and `generate-sudoer-json`. Those stay on `help`, listed apart from operational work.  
5. Accept a **number** or the **verb token**. Extra operands: prompt **one field at a time** on TTY, or print `Next: take-ownership <verb> …` and return.  
6. Last extra row is **Exit** (not a command). For this product **N = 3**, so Exit **MUST** be **9**. Unused integers 4–8 are omitted. `list-folders` is a live operational verb on `help` and **MUST NOT** appear on this numbered list.  
7. Exit number, `exit`, or `quit` returns 0 with no further prompt.  
8. Typical handler: `app_main_menu`.

### 2.4 Implementation Notes (this product)

| Item | Value |
|------|--------|
| **Product** | `take-ownership` |
| **Claimed** | yes |
| **Case** | **3** (zero-arg REQ exists; local-only; that REQ routes empty argv **to this handler**) |
| **Empty argv owner** | `requirement-shell-cli-zero-arguments` (Type N; handler `app_main_menu`) |
| **Menu verbs** | `menu` (preferred); `main` alias; empty argv same handler |
| **Handler** | `app_main_menu` |
| **Ship unit** | Implemented — `app_main` routes empty argv, `menu`, and `main` to `app_main_menu` |
| **Kept list** | `reviews/cli-routed-verb-table.md` |
| **N** | 3 |
| **Exit** | 9 |
| **Test-purpose (this product)** | `print-sudoers`, `print-sudoers-install-script`, `generate-sudoer-request`, `generate-sudoer-json` |

**Normative menu draft** (operational only; self-managed, diagnostics, and test-purpose omitted):

```text
1. action: Recursively take ownership of a named folder
2. remove-project-sudoers: Remove the local grant draft only
3. submit-sudoer-request: Hand the JSON grant to the approval queue
9. Exit
```

**Invocation samples (CI-M1a):**

```text
take-ownership
take-ownership menu
take-ownership main
take-ownership menu --json
```

On a real terminal those four **MUST** show the list (`--json` is ignored for `menu`/`main` on TTY; empty argv has no flags). Off-TTY, `take-ownership` and `take-ownership menu` **MUST** call help; `take-ownership menu --json` **MUST** call JSON help.

### 2.5 Why This Requirement Exists (CIAO)

- **Principle 2 – Intentional**: Empty argv is the claimed work list; Type N still forbids install.  
- **Principle 1 – Caution**: Scripts do not hang.  
- **Principle 16 – Interactive vs non-interactive**: TTY vs pipe is explicit.  
- **Principle 10 – Least privilege**: Install/uninstall, version/about, and test-purpose grant-emit verbs are not on the work list.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Do not hang off-TTY; do not steal Type O install-ensure.  
- **Intentional:** Case 3; empty argv and `menu`/`main` share one handler; labels from the kept list.  
- **Anti-fragile:** `main` may alias `menu`; Exit 9 when N=3.  
- **Over-protect:** Self-managed, diagnostics, and test-purpose verbs stay off the list even if they are live.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Route interactive empty argv to help while this menu is claimed and `requirement-shell-cli-zero-arguments` says empty argv uses `app_main_menu`.  
2. Invent menu labels instead of `command: what it does` from the kept list.  
3. Put `help`, `install`, `uninstall`, `where-is-me`, `version`, `about`, `setup`, `menu`, `main`, `list-folders`, or a test-purpose verb (`print-sudoers`, `print-sudoers-install-script`, `generate-sudoer-request`, `generate-sudoer-json`) on the numbered list.  
4. Number Exit as 4 when N=3 (Exit **MUST** be 9).  
5. Draw the menu in non-interactive mode.  
6. Treat interactive `take-ownership menu --json` as JSON help.  
7. Claim the ship unit lacks the menu while `app_main` routes empty argv / `menu` / `main`.  
8. Auto-write `/etc` from a menu choice (print/submit stay Type 0 drafts).  
9. Turn empty argv into install-ensure.

**Violating this rule is a critical dispatcher / hang / honesty regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Empty argv uses `app_main_menu` (TTY list; off-TTY help); never install |
| AC-2 | Case 3 recorded; empty argv, `menu`, and `main` named and routed |
| AC-3 | Interactive `menu` **and** interactive empty argv draw the three-row list (`action`, `remove-project-sudoers`, `submit-sudoer-request`) + Exit 9; no `list-folders` row |
| AC-4 | Interactive `menu --json` still draws the list |
| AC-5 | Non-interactive `menu` and empty argv are help; `menu --json` is JSON help |
| AC-6 | Numbered choices omit help, install, uninstall, where-is-me, version, about, setup, menu, main, list-folders, and test-purpose (`print-sudoers`, `print-sudoers-install-script`, `generate-sudoer-request`, `generate-sudoer-json`) |
| AC-7 | Labels match kept-list human-readable `verb: explain` |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-cli-zero-arguments` | Empty argv Type N; routes to this handler |
| `requirement-shell-cli-interface` | Dual mention: empty argv + `menu` / `main` on the command table |
| `requirement-shell-interactive-vs-noninteractive` | `TTY`; no hang |
| `requirement-shell-output-requirements` | `out_*`; reuse `app_help` |
| `requirement-shell-local-self-management` | install/uninstall/where-is-me stay on help, not this list |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-CLI-07** | `tests/test_cli.sh` | **have** — off-TTY empty argv still help; not install (AC-1, AC-5) |
| **TP-CLI-13** | `tests/test_cli.sh` | **have** — interactive `menu` **and** interactive empty argv print the three labels + `9. Exit`; no `list-folders` row (AC-3) |
| **TP-CLI-14** | same | **have** — interactive `menu --json` still prints the list (AC-4) |
| **TP-CLI-15** | same | **have** — non-interactive `menu` and empty argv are help; `--json` JSON help (AC-5) |
| **TP-CLI-16** | same | **have** — numbered list omits help/install/uninstall/where-is-me/version/about/test-purpose/menu (AC-6) |

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

---

**Last Updated**: 2026-08-30  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
