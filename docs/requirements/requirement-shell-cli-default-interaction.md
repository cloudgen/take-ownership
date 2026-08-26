**file**: docs/requirements/requirement-shell-cli-default-interaction.md  
**Status**: Active (Version 2.1.0)  
**Area**: shell  
**Key**: `requirement-shell-cli-default-interaction`  
**Optional RQ-ID**: `RQ-SHELL-CLI-DEFAULT-INTERACTION`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **product Single Source of Truth** for take-ownership’s **claimed default interactive main menu**. Empty argv stays help (`requirement-shell-cli-zero-arguments`). The numbered list opens with **`take-ownership menu`** (or **`main`**). The ship unit routes those verbs to `app_main_menu`.

### 1.1 Human-facing

**In one sentence:** At a real terminal, type `take-ownership menu` to see a numbered list of live work commands; typing only `take-ownership` still prints help.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Open the list or pick a number | `take-ownership menu` then `1` (action) or `2` (list-folders) |
| The other role | Scripts and CI must not hang on that list | `take-ownership menu` in a pipe → help |
| Not this file | Empty argv meaning | `requirement-shell-cli-zero-arguments` |

| Includes | Excludes |
|----------|----------|
| Numbered live work commands | `help` as a row |
| Line `command: what it does` | `install`, `uninstall`, `where-is-me`, `version`, `about` |
| Exit as **9** (four command rows) | `setup`, `menu`/`main` as a choice |
| `main` as the same list | Test-purpose: `print-sudoers`, `print-sudoers-install-script`, `generate-sudoer-request`, `generate-sudoer-json` |

| Surface | What you open | What for |
|---------|---------------|----------|
| `./src/take-ownership` | ship unit | live dispatch (`menu` / `main`) |
| `take-ownership help` | command | listed verbs including lifecycle |
| `take-ownership menu` | command | numbered list when implemented |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Open the list at a prompt | The program prints numbers 1–4 then 9 Exit. `--json` is ignored on a real terminal. | `take-ownership menu` |
| Take ownership from the list | Choose `action`, then give folder and `user:group` one field at a time, or read Next. | `1` then `--path /var/www/html` |
| Run menu in CI | No prompt. Human help, or JSON help with `--json`. | `take-ownership menu </dev/null` |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Claim and case

1. This product **claims** a default interactive main menu.  
2. **Case 3** applies: a specialized zero-argument requirement exists **and** the product is **not** online-installable.  
3. Empty argv **MUST** stay help (`requirement-shell-cli-zero-arguments`). **MUST NOT** attach this menu to empty argv.  
4. The menu **MUST** be routed-verb **`menu`**. **`main` MAY** call the same handler.  
5. `app_main` **MUST** route `menu` / `main` to `app_main_menu`.

### 2.2 Mode check (`menu` / `main` only)

Measure interactive capability **outside functions** (`TTY=1` only when stdin and stdout are terminals). Helpers consume `TTY` (`requirement-shell-interactive-vs-noninteractive`).

| Invocation | Mode | `--json` | MUST | MUST NOT |
|------------|------|----------|------|----------|
| `take-ownership menu` or `main` | Interactive (`TTY=1`) | **Ignore** | Draw the numbered list | Treat as JSON help; hang |
| same | Non-interactive (`TTY=0`) | **Follow** | **Help**: human when JSON=0; JSON help when JSON=1 | Draw the menu; hang; silent return |

`--quiet` off-TTY is still the help path (do not swallow help). Reuse `app_help` — **MUST NOT** invent a second JSON help catalog.

### 2.3 Numbered list (when the case says menu)

1. Print a **numbered list** at the start of the interactive menu path.  
2. Each command row is one live **operational** command that is **not** excluded below, numbered **1 … N** in kept-list order.  
3. Printed line **MUST** be the kept-list **human-readable** value: **`{{short-descript}}: {{explain}}`** (short-descript = the command token).  
4. **MUST NOT** list `help`, `menu`, `main`, gap/forbidden names, **diagnostics** (`version`, `about`), **self-managed / install-setup** tokens (`install`, `uninstall`, `where-is-me`, `setup`), or **test-purpose** verbs. On this product the test-purpose verbs **MUST** be `print-sudoers`, `print-sudoers-install-script`, `generate-sudoer-request`, and `generate-sudoer-json`. Those stay on `help`, listed apart from operational work.  
5. Accept a **number** or the **verb token**. Extra operands: prompt **one field at a time** on TTY, or print `Next: take-ownership <verb> …` and return.  
6. Last extra row is **Exit** (not a command). For this product **N = 4**, so Exit **MUST** be **9**. Unused integers 5–8 are omitted.  
7. Exit number, `exit`, or `quit` returns 0 with no further prompt.  
8. Typical handler: `app_main_menu`.

### 2.4 Implementation Notes (this product)

| Item | Value |
|------|--------|
| **Product** | `take-ownership` |
| **Claimed** | yes |
| **Case** | **3** (zero-arg REQ exists; local-only) |
| **Empty argv owner** | `requirement-shell-cli-zero-arguments` (help) |
| **Menu verbs** | `menu` (preferred); `main` alias |
| **Handler** | `app_main_menu` |
| **Ship unit** | Implemented — `app_main` routes `menu` / `main` to `app_main_menu` |
| **Kept list** | `reviews/cli-routed-verb-table.md` |
| **N** | 4 |
| **Exit** | 9 |
| **Test-purpose (this product)** | `print-sudoers`, `print-sudoers-install-script`, `generate-sudoer-request`, `generate-sudoer-json` |

**Normative menu draft** (operational only; self-managed, diagnostics, and test-purpose omitted):

```text
1. action: Recursively take ownership of a named folder
2. list-folders: List folders this login may take ownership of
3. remove-project-sudoers: Remove the local grant draft only
4. submit-sudoer-request: Hand the JSON grant to the approval queue
9. Exit
```

**Invocation samples (CI-M1a):**

```text
take-ownership menu
take-ownership main
take-ownership menu --json
```

On a real terminal those three **MUST** show the list. Off-TTY, `take-ownership menu` **MUST** call help; `take-ownership menu --json` **MUST** call JSON help.

### 2.5 Why This Requirement Exists (CIAO)

- **Principle 2 – Intentional**: Empty argv stays help; the list has a named command.  
- **Principle 1 – Caution**: Scripts do not hang.  
- **Principle 16 – Interactive vs non-interactive**: TTY vs pipe is explicit.  
- **Principle 10 – Least privilege**: Install/uninstall, version/about, and test-purpose grant-emit verbs are not on the work list.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Do not steal empty argv; do not hang off-TTY.  
- **Intentional:** Case 3; labels from the kept list.  
- **Anti-fragile:** `main` may alias `menu`; Exit 9 when N=4.  
- **Over-protect:** Self-managed, diagnostics, and test-purpose verbs stay off the list even if they are live.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Attach this menu to empty argv while `requirement-shell-cli-zero-arguments` is Active.  
2. Invent menu labels instead of `command: what it does` from the kept list.  
3. Put `help`, `install`, `uninstall`, `where-is-me`, `version`, `about`, `setup`, `menu`, `main`, or a test-purpose verb (`print-sudoers`, `print-sudoers-install-script`, `generate-sudoer-request`, `generate-sudoer-json`) on the numbered list.  
4. Number Exit as 4 when N=3 (Exit **MUST** be 9).  
5. Draw the menu in non-interactive mode.  
6. Treat interactive `take-ownership menu --json` as JSON help.  
7. Claim the ship unit lacks the menu while `app_main` routes `menu` / `main`.  
8. Auto-write `/etc` from a menu choice (print/submit stay Type 0 drafts).

**Violating this rule is a critical dispatcher / hang / honesty regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Empty argv remains help |
| AC-2 | Case 3 recorded; `menu` / `main` named and routed |
| AC-3 | Interactive `menu` draws the three-row list + Exit 9 |
| AC-4 | Interactive `menu --json` still draws the list |
| AC-5 | Non-interactive `menu` is help; `--json` is JSON help |
| AC-6 | Numbered choices omit help, install, uninstall, where-is-me, version, about, setup, menu, main, and test-purpose (`print-sudoers`, `print-sudoers-install-script`, `generate-sudoer-request`, `generate-sudoer-json`) |
| AC-7 | Labels match kept-list human-readable `verb: explain` |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-cli-zero-arguments` | Empty argv stays help |
| `requirement-shell-cli-interface` | Dual mention: `menu` / `main` on the command table |
| `requirement-shell-interactive-vs-noninteractive` | `TTY`; no hang |
| `requirement-shell-output-requirements` | `out_*`; reuse `app_help` |
| `requirement-shell-local-self-management` | install/uninstall/where-is-me stay on help, not this list |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-CLI-07** | `tests/test_cli.sh` | **have** — empty argv still help (AC-1) |
| **TP-CLI-13** | `tests/test_cli.sh` | **todo** — interactive `menu` prints the three labels + `9. Exit` (AC-3) |
| **TP-CLI-14** | same | **have** — interactive `menu --json` still prints the list (AC-4) |
| **TP-CLI-15** | same | **have** — non-interactive `menu` is help; `--json` JSON help (AC-5) |
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

---

**Last Updated**: 2026-08-26  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
