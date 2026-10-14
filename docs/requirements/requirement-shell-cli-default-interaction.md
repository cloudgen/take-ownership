**file**: docs/requirements/requirement-shell-cli-default-interaction.md  
**Status**: Active (Version 3.3.0)  
**Area**: shell  
**Key**: `requirement-shell-cli-default-interaction`  
**Optional RQ-ID**: `RQ-SHELL-CLI-DEFAULT-INTERACTION`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **product Single Source of Truth** for take-ownership’s **default interaction**: a **TTY numbered tree**. The front board is **1** `action`, **2** `return-original-owner`, **5** sudoers, **6** self-management, **7** language, **9** Exit. Child numbers **keep the parent prefix** and **never repeat** a parent integer, except the language block **70–89** under front **7**. **0** is Back on every submenu. **9** is Exit **only** on the front board.

take-ownership has `requirement-shell-cli-zero-arguments` (**case 3**): that REQ **defers TTY empty argv** to this menu and **owns off-TTY empty argv as Type O install-ensure**. The menu **MUST** also be the command **`menu`**. **`main` MAY** be accepted as the same handler.

On a **real terminal**, empty argv and `take-ownership menu` (or `main`) **MUST** show the front board. `menu`/`main` **MUST ignore `--json`**. Off-TTY, **`menu`/`main` MUST** print **help**, following `--json`. Off-TTY **empty argv** is **not** this file — it is Type O install-ensure on the zero-argument REQ. Command rows **MUST** be `command: what it does`. Category rows (`sudoers`, `self-management`) **MUST NOT** be live dispatcher commands.

Empty-argv type and the TTY vs off-TTY split for **no command token** stay on `requirement-shell-cli-zero-arguments`. Confirm / no-hang stays on `requirement-shell-interactive-vs-noninteractive`. Live command inventory stays dispatcher truth (`requirement-shell-cli-interface`). Lifecycle handlers stay on `requirement-shell-self-management`.

Child numbers keep the parent prefix. Front **5** is sudoers (**51–55**). Front **6** is self-management (**61–66**). Front **7** is language (block **70–89**, assigned **71–83**). Front **9** is Exit. Submenu **0** is Back. This product has no client-side board and no server-side board, so front **3**, **4**, and **8** are unused and **not** printed. Front **8** is not a row, because the language block occupies **80–83**. Front **1** is the daily leaf `action`, not a category. Front **2** is `return-original-owner`. Menu copy follows `requirement-shell-cli-language`.

### 1.1 Human-facing

**In one sentence:** At a real terminal, `take-ownership` shows **take-ownership**(*version*), then take-ownership, sudoers, self-management, and language; **0** walks back; **9** leaves.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Open the front board or pick a number | `take-ownership` then `1` (`action`) |
| The other role | Scripts and CI must not hang on that list | `take-ownership menu` in a pipe → help; bare empty argv off-TTY is install-ensure |
| Not this file | Off-TTY empty argv is Type O | `requirement-shell-cli-zero-arguments` |

| Includes | Excludes |
|----------|----------|
| Front **1** `action`, **2** `return-original-owner`, **5** sudoers, **6** self-management, **7** language, **9** Exit | Restarting a submenu at **1**; **9** as submenu Exit; Back **8**; front **8** as a row |
| Sudoers **51–55**; self-management **61–66**; **0** Back | `self-install` as a row (**67** reserved, not printed); `where-is-me` as a row |
| Default CLI main menu style (header `APP_NAME(APP_VERSION)`; TTY explain italic + light gray) | A bare `take-ownership` on that first line; color codes in a pipe |
| After a finished command, the front board again | `help`, `menu`/`main`, `list-folders`, `generate-sudoer-json` as numbered rows |

| Surface | What you open | What for |
|---------|---------------|----------|
| `./src/take-ownership` | ship unit | live dispatch (empty argv / `menu` / `main`) |
| `take-ownership help` | command | listed verbs, including ones that are not numbered rows |
| `take-ownership` | no command | front board on a TTY |
| `take-ownership menu` | command | same tree |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Open the front board | Daily `action`, then sudoers, then self-management, then language. `--json` is ignored on a real terminal for `menu`/`main`. | `take-ownership` or `take-ownership menu` |
| Change the menu language | Language board **71** English through **83** Ελληνικά. The next run opens in that language. | `7`, then `73` |
| Take ownership | Choose `action`, then pick a numbered allowed folder. **0** Back returns to the front board. A bad number stays on that list. Ownership is this login’s `user:group` (no prompt). | `1`, then a folder number, or `0` |
| Open grant/drafts | Sudoers board **51–55** | `5` then `51` |
| Open install / version / update / remove | Self-management board **61–66** | `6` then `61` |
| Leave a side board | Back to the front board | `0` |
| Leave the program | Front Exit | `9` |
| Run menu in CI | No prompt. Human help, or JSON help with `--json` on the `menu` verb. | `take-ownership menu </dev/null` |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Claim and case

1. This product **claims** a default interactive main menu.  
2. **Case 3** applies: a specialized zero-argument requirement exists. Empty argv **MUST** follow `requirement-shell-cli-zero-arguments` (TTY → this menu; off-TTY → Type O).  
3. That zero-argument requirement **MUST** route empty argv to **this** menu handler (`app_main_menu`). **MUST NOT** keep empty argv as TTY help while this menu is claimed.  
4. The menu **MUST** also be routed-verb **`menu`**. **`main` MAY** call the same handler.  
5. `app_main` **MUST** route empty argv, `menu`, and `main` to `app_main_menu`.

### 2.2 Mode check (empty argv, `menu`, and `main`)

Measure interactive capability **outside functions** (`TTY=1` only when stdin and stdout are terminals). Helpers consume `TTY` (`requirement-shell-interactive-vs-noninteractive`).

| Invocation | Mode | `--json` | MUST | MUST NOT |
|------------|------|----------|------|----------|
| `take-ownership` (no args) | Interactive (`TTY=1`) | N/A (no flags) | Draw the front board | Treat as help; hang; install |
| `take-ownership` (no args) | Non-interactive (`TTY=0`) | N/A | **Type O** on the zero-argument REQ (not this file) | Draw the menu; hang; silent return; print help |
| `take-ownership menu` or `main` | Interactive (`TTY=1`) | **Ignore** | Draw the front board | Treat as JSON help; hang |
| same | Non-interactive (`TTY=0`) | **Follow** | **Help**: human when JSON=0; JSON help when JSON=1 | Draw the menu; hang; silent return |

`--quiet` off-TTY is still the help path (do not swallow help). Reuse `app_help` — **MUST NOT** invent a second JSON help catalog.

### 2.3 Front board

0. **Look (mandatory):** every numbered layer **MUST** use the default CLI main menu style. Header **MUST** print live `take-ownership(VERSION)` (no space; same Config scalars as `version`) then that layer’s title. On a TTY the name is **bold** and the version *italic*. Each numbered `explain` **MUST** be *italic* and light gray on a TTY (SGR 3 + 37). Number and command name stay unstyled. Off-TTY / JSON: **plain** — **MUST NOT** emit CSI. Typical helpers: `util_app_ident` then `out_menu_choice`. **MUST NOT** a bare `take-ownership` on that header. **MUST NOT** print `explain` unstyled on a TTY. **MUST NOT** freeze “numbered list of live work commands” as the header suffix.  
1. The front board **MUST** print the rows below, then read a choice in the current shell.  
2. **MUST NOT** list install, version, about, version-check, self-update, self-uninstall, uninstall, where-is-me, help, menu, main, list-folders, setup, or `generate-sudoer-json` on this board.  
3. Command-row text **MUST** be `command: what it does`. Category explain for **7** and **8** is this table.  
4. **`sudoers` is not a live CLI command.** **`self-management` is not a live CLI command.** `take-ownership sudoers` and `take-ownership self-management` **MUST** remain unknown.  
5. Choosing **5** / typing `language` (or the category short in §2.4.3) **MUST** open the language board. Choosing **7** / typing `sudoers` at this prompt **MUST** open §2.5. Choosing **8** / typing `self-management` (or that category’s displayed short) **MUST** open §2.6. Choosing **1** / typing `action` **MUST** run `action`. Choosing **2** / typing `return-original-owner` **MUST** run `return-original-owner`.  
6. Front leave tokens: **9**, `exit`, `quit`, an empty line, or EOF. Each returns 0. **0** is **not** a front-board row.  
7. A typed **live** verb at this prompt (including a verb that lives on a submenu) **MUST** run that handler, then follow §2.4.1.  
8. **Do not capture `read`:** the choice **MUST** be read in the **current shell**. Typical: `prompt_line "Choice"` then `_pick="${_prompt_line}"`. **MUST NOT** `_pick=$(prompt_line …)` / `_pick=$(prompt_ask …)` / `$()` / backticks of **any** function whose body contains `read`. stderr+$() is **not** a license.

Normative **front** order:

| # | Token | Label | Runs |
|---|-------|-------|------|
| *(header)* | — | `take-ownership(VERSION) — Take Unix ownership of a named folder with a narrow global-only sudo grant` | — |
| **1** | `action` | `action: Recursively take ownership of a named folder` | `action` |
| **2** | `return-original-owner` | `return-original-owner: Put the folder back to the saved original owner` | `return-original-owner` |
| **5** | category `sudoers` | `sudoers: Grant and drafts` | §2.5 |
| **6** | category `self-management` | `self-management: This CLI install, version, update, uninstall` | §2.6 |
| **7** | category `language` | `language: display language for this menu` | §2.4.3 |
| **9** | **Exit** | leave the program | return 0 |

Unused integers **3**, **4**, and **8** are omitted. They are not client-side or server-side rows. Front **8** is not the language row. Front **2** is `return-original-owner`.

### 2.4 Numbering

1. A command number appears **once** in the whole tree.  
2. A child number **starts with its parent’s digits** (**51…** under **5**, **61…** under **6**). The language board is the exception: front **7** reserves **70** through **89** and no other row uses those numbers.  
3. Every submenu prints **0** Back (return to the front board). An empty line on a submenu **MUST** mean Back.  
4. A reserved hidden number stays reserved. Picking it is an invalid choice (§2.4.2). **MUST NOT** compact the remaining rows into the hole.  
5. The allowed-folder list inside `action` is a data picker: item indexes **1…N** plus **0** Back. Print `0. Back` on that list. **0** / `back` / `q` / an empty line / EOF leaves the picker and returns to the parent. When `action` was opened from this menu, the parent is the front board. A direct `action` returns 0. That **0** is not front Exit. The front board itself does **not** print **0** Back; **0** there is an invalid choice (§2.4.2). An invalid folder token warns, names the token, reprints this picker, and reads again. **MUST NOT** `out_die` for Back or for that invalid token. An empty allowed set still fails closed (that is not a choice). The same Back / invalid-choice rule applies to the draft list inside `remove-project-sudoers` when several drafts are present. Numbering of the folder rows stays on `requirement-take-ownership-ops`. This file **MUST NOT** renumber those rows.

**MUST NOT** restart a submenu at **1**. **MUST NOT** use **9** as submenu Exit. **0** is not a command.

### 2.4.1 After a finished command

After a **valid leaf** finishes (numbered command, or a typed live verb), the handler **MUST** return and this menu **MUST** redisplay the **front board**. **MUST NOT** redisplay the submenu that launched that command. **MUST NOT** leave the program only because the command finished.

**MUST NOT** treat that return as an invalid choice. **0** / empty / EOF on a submenu still means Back. Front **9** / empty / EOF still leaves. A typed leaf on the front board also redisplays the front board (it does not exit).

### 2.4.2 Invalid choice

An invalid choice is any input that is not a listed number, not a listed name, and not this layer’s leave or back token. A hidden reserved number (**67**, front **3** / **4** / **8**, language **70** and **84** through **89**, and **5** when §2.7 hides sudoers) is an invalid choice on that layer.

**MUST:** print a warning that names the token and tells the operator to choose a listed number or command name (`out_warn`), reprint **this** layer, and read again in the current shell.

**MUST NOT** `out_die` for that pick. **MUST NOT** exit non-zero solely for that pick. **MUST NOT** treat the pick as an unknown command-line verb. EOF / a failed `read` leaves this layer without spinning (front → return 0; submenu → parent).

### 2.4.3 Language board (parent **7**)

Choosing front **7** / `language` (or the displayed category short from `requirement-shell-cli-language`) **MUST** print the language board. Header **MUST** use the same nametag, then ` — language` in English, or the category short in another language. **71** through **83** are the only printed rows, then **0** Back. **70** and **84** through **89** are not printed. **9** is not printed.

| # | Name | English long |
|---|------|----------------|
| **71** | English | `use English for this menu` |
| **72** | 简体中文 | `use Simplified Chinese for this menu` |
| **73** | 繁體中文 | `use Traditional Chinese for this menu` |
| **74** | Español | `use Spanish for this menu` |
| **75** | العربية | `use Arabic for this menu` |
| **76** | Français | `use French for this menu` |
| **77** | Português | `use Portuguese for this menu` |
| **78** | Русский | `use Russian for this menu` |
| **79** | Deutsch | `use German for this menu` |
| **80** | 日本語 | `use Japanese for this menu` |
| **81** | 한국어 | `use Korean for this menu` |
| **82** | Nederlands | `use Dutch for this menu` |
| **83** | Ελληνικά | `use Greek for this menu` |
| **0** | **Back** | return to the front board; do not write the file |

- **0** / `back` / `q` / empty / EOF returns to the front board and does not write the file.
- **9** on this board is an invalid choice. It does not leave the program.
- **71** through **83** save that code, print the saved line in the new language, then §2.4.1 redisplays the front board in that language.
- Codes, the file, and the copy are `requirement-shell-cli-language`. This file owns the row numbers.

### 2.5 Sudoers submenu (parent **5**)

Choosing front **5** / `sudoers` **MUST** print this second numbered list. Header **MUST** use the same `APP_NAME(APP_VERSION)` nametag, then ` — sudoers (grant and drafts)`. Explain text **MUST** follow the same default CLI main menu style. **MUST NOT** hang off-TTY (the submenu exists only on the interactive menu path).

| # | Command | Label |
|---|---------|-------|
| **51** | `generate-sudoer-request` | `generate-sudoer-request: Write a JSON grant you can read` |
| **52** | `submit-sudoer-request` | `submit-sudoer-request: Queue the JSON grant inbound` |
| **53** | `print-sudoers` | `print-sudoers: Emit sudoers draft` |
| **54** | `print-sudoers-install-script` | `print-sudoers-install-script: Write admin install script` |
| **55** | `remove-project-sudoers` | `remove-project-sudoers: Remove sudoers draft only` |
| **0** | **Back** | return to the front board |

- **0** / `back` / `Back` / `q` / empty line / EOF returns to the front board.  
- **9** on this board is an invalid choice (§2.4.2). It does **not** leave the program.  
- A listed number or listed verb runs that handler, then §2.4.1.  
- All five grouped verbs **MUST** appear here. **MUST NOT** put install, version, about, help, setup, or `generate-sudoer-json` on this list.

The five grouped verbs **MUST** remain live dispatcher commands (`requirement-shell-cli-interface`). Opening them from this submenu **MUST** call the same handlers as typing `take-ownership generate-sudoer-request` (and the other four). **MUST NOT** add a live `sudoers` token to `app_main`.

### 2.6 Self-management submenu (parent **6**)

Choosing front **6** / `self-management` **MUST** print this list. Header **MUST** use the same nametag, then ` — self-management (this CLI)`. Same ink rules as §2.3.

| # | Command | Label | TTY runs |
|---|---------|-------|----------|
| **61** | `install` | `install: Ensure this program from the channel` | `inst_perform_install` |
| **62** | `version` | `version: Show the local version` | `app_version` |
| **63** | `about` | `about: Show diagnostics including global-bin presence` | `app_about` |
| **64** | `version-check` | `version-check: Compare local version to the channel` | `ver_check` |
| **65** | `self-update` | `self-update: Update this program when the channel is newer` | `inst_self_update` |
| **66** | `self-uninstall` | `self-uninstall: Remove the managed binary (not the host grant)` | `inst_self_uninstall` |
| **0** | **Back** | return to the front board | — |

- **0** / `back` / `Back` / `q` / empty line / EOF returns to the front board.  
- **9** on this board is an invalid choice.  
- A listed number or listed verb runs that handler, then §2.4.1.  
- Typing `uninstall` at this prompt **MUST** run the same handler as **66** (argv alias). It is **not** a second row.  
- **67** `self-install` is **not** a live token. The number stays **reserved** and **MUST NOT** be printed. Picking **67** is an invalid choice. This product’s channel place verb is **61** `install`. There is no payload installer and no separate CLI-place token.  
- `where-is-me` stays a live help/argv command and **MUST NOT** be a numbered row. Typing it at a menu prompt is a live-verb shortcut (§2.3 item 7), then §2.4.1.  
- **MUST NOT** put `help`, `menu`, `main`, `setup`, `list-folders`, or `generate-sudoer-json` on this list.

These six verbs **MUST** remain live dispatcher commands. **MUST NOT** add a live `self-management` token to `app_main`.

### 2.7 Menu-hidden message

A **menu-hidden message** is the line that names why rows of **this** layer are omitted. Print it after that layer’s header and **before** the first numbered item. One cause, one message. Reprint it when invalid-choice retry reprints the layer. The message is not a numbered row.

| Layer | Cause | Message before the numbers |
|-------|--------|----------------------------|
| Front | Termux, Git Bash, or Windows cmd omits **5** sudoers | `sudoers not available for termux` / `gitbash` / `windows-cmd` |

On that class, row **5** is omitted and the number stays reserved. Picking **5** is an invalid choice. Language **7**, self-management **61–66**, and front **1** / **6** / **9** stay. **MUST NOT** wrap `sudo` to unhide **5**. **MUST NOT** renumber **6** into the hole. **MUST NOT** hide **7**.

The ship unit omits row **5** on that class and prints the reason line before the numbers.

### 2.8 Implementation Notes (this product)

| Item | Value |
|------|--------|
| **Product** | `take-ownership` |
| **Claimed** | yes |
| **Case** | **3** (zero-arg REQ exists; online-installable; that REQ routes TTY empty argv **to this handler**) |
| **Empty argv owner** | `requirement-shell-cli-zero-arguments` (TTY menu; off-TTY Type O) |
| **Menu verbs** | `menu` (preferred); `main` alias; empty argv same handler |
| **Handler** | `app_main_menu` (front loop, language loop, sudoers loop, self-management loop) |
| **Ship unit** | `app_main` routes empty argv, `menu`, and `main` to `app_main_menu`. That function draws front **1 / 2 / 5 / 6 / 7 / 9**, sudoers **51–55**, self-management **61–66**, language **71–83**, and **0** Back. |
| **Category rows** | `language`, `sudoers`, `self-management` — menu-only; **not** dispatched |
| **Label source** | `reviews/cli-routed-verb-table.md` **human-readable** for command rows; category explain is this file |
| **Look** | Default CLI main menu style — header `take-ownership(VERSION)` then the layer title; TTY italic + light-gray explain; `out_menu_choice` / `util_app_ident` |
| **Choice read** | Current-shell `prompt_line` → `_prompt_line` (not `$()`) |
| **Front** | **1** / **2** / **5** / **6** / **7** / **9** |
| **Sudoers** | **51–55**, **0** Back |
| **Self-management** | **61–66**, **0** Back; **67** reserved |
| **Language** | **71–83**, **0** Back; **70** and **84–89** reserved |
| **Exit** | **9** on the front board only |
| **Back** | **0** on every submenu and data picker; not on the front board |
| **Test-purpose (this product)** | `generate-sudoer-json` (off every numbered list; stays on `help` apart) |
| **README capture** | Product README shows this front board, the language board, and the two other submenus. |

**Normative front draft** (plain glyphs; the live TTY uses SGR):

```text
[INFO] take-ownership(VERSION) — Take Unix ownership of a named folder with a narrow global-only sudo grant
1. action: Recursively take ownership of a named folder
2. return-original-owner: Put the folder back to the saved original owner
5. sudoers: Grant and drafts
6. self-management: This CLI install, version, update, uninstall
7. language: display language for this menu
9. Exit
Choice:
```

**Normative language draft:**

```text
[INFO] take-ownership(VERSION) — language
71. English: use English for this menu
72. 简体中文: use Simplified Chinese for this menu
73. 繁體中文: use Traditional Chinese for this menu
74. Español: use Spanish for this menu
75. العربية: use Arabic for this menu
76. Français: use French for this menu
77. Português: use Portuguese for this menu
78. Русский: use Russian for this menu
79. Deutsch: use German for this menu
80. 日本語: use Japanese for this menu
81. 한국어: use Korean for this menu
82. Nederlands: use Dutch for this menu
83. Ελληνικά: use Greek for this menu
0. Back
Choice:
```

Choosing **1** with no `--path` opens the allowed-folder picker. **0** returns to the front board. A token that is not on the list warns and prints the list again.

```text
[INFO] Folders this login may take ownership of (1):
1. /var/www/html
0. Back
Choice:
```

**Normative sudoers draft:**

```text
[INFO] take-ownership(VERSION) — sudoers (grant and drafts)
51. generate-sudoer-request: Write a JSON grant you can read
52. submit-sudoer-request: Queue the JSON grant inbound
53. print-sudoers: Emit sudoers draft
54. print-sudoers-install-script: Write admin install script
55. remove-project-sudoers: Remove sudoers draft only
0. Back
Choice:
```

**Normative self-management draft:**

```text
[INFO] take-ownership(VERSION) — self-management (this CLI)
61. install: Ensure this program from the channel
62. version: Show the local version
63. about: Show diagnostics including global-bin presence
64. version-check: Compare local version to the channel
65. self-update: Update this program when the channel is newer
66. self-uninstall: Remove the managed binary (not the host grant)
0. Back
Choice:
```

**Invocation samples:**

```text
take-ownership
take-ownership menu
take-ownership main
take-ownership menu --json
```

On a real terminal those four **MUST** show the front board (`--json` is ignored for `menu`/`main` on TTY; empty argv has no flags). Off-TTY, `take-ownership` is Type O on the zero-argument REQ. Off-TTY, `take-ownership menu` **MUST** call help; `take-ownership menu --json` **MUST** call JSON help.

### 2.9 Why This Requirement Exists (CIAO)

- **Principle 2 – Intentional**: Daily `action` stays one pick. Grant/draft commands share **5**. Install, version, update, and remove share **6**.  
- **Principle 1 – Caution**: Scripts do not hang. An unknown menu number warns and reprints. It does not kill the process.  
- **Principle 16 – Interactive vs non-interactive**: TTY vs pipe is explicit.  
- **Principle 5 – Single source of output**: Rows go through `out_menu_choice`.  
- **Principle 10 – Least privilege**: `sudoers` and `self-management` are not dispatcher tokens. Test-purpose `generate-sudoer-json` is not on any numbered list. Row **5** stays hidden where this login cannot use sudoers.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Do not hang off-TTY. Do not steal Type O install-ensure. Do not `out_die` on a bad menu number.  
- **Intentional:** Case 3. Empty argv and `menu`/`main` share one handler. Child numbers keep the parent prefix.  
- **Anti-fragile:** Reserved holes stay reserved (**3**, **4**, **8**, **70**, **84–89**, **67**, hidden **5**). Front **2** is `return-original-owner`. After a command, the front board returns.  
- **Over-protect:** **9** leaves only from the front board. **0** is Back. Lifecycle verbs stay off the front board and on **61–66**.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Route interactive empty argv to help while this menu is claimed and `requirement-shell-cli-zero-arguments` says empty argv uses `app_main_menu`.  
2. Invent command-row labels instead of `command: what it does` from the kept list (category explain is this file).  
3. Put `help`, `menu`, `main`, `list-folders`, `where-is-me`, `setup`, or `generate-sudoer-json` on any numbered list.  
4. Put install, version, about, version-check, self-update, or self-uninstall on the **front** board.  
5. Drop a grouped sudoers verb from **51–55**, or drop a live self-management verb from **61–66**.  
6. Restart a submenu at **1**, number sudoers as front **2**, or use Back **8**.  
7. Use **9** as submenu Exit, or number front Exit as **3** or **4**.  
8. Print **67** `self-install`, or compact **66** into that hole.  
9. Wire `sudoers` or `self-management` as a live `app_main` command.  
10. Draw the menu in non-interactive mode, or hang a pipe on empty argv / `menu` / `main`.  
11. Treat interactive `take-ownership menu --json` as JSON help.  
12. Claim a ship unit draws **5 / 6 / 51 / 61 / 0** while `app_main_menu` still draws the previous tree.  
13. Auto-write `/etc` from a menu choice (print/submit stay Type 0 drafts).  
14. Turn TTY empty argv into install-ensure.  
15. Print the header as a bare `take-ownership` without the live version, or emit CSI off-TTY.  
16. Print TTY `explain` unstyled, or bypass `out_menu_choice` for numbered-choice rows.  
17. Capture the menu choice with `$()` / backticks of a `read` helper.  
18. `out_die` for an unknown menu number.  
19. Stay on the submenu after a finished command.  
20. Show row **5** on Termux, Git Bash, or Windows cmd without the menu-hidden message, once this tree is implemented.  
21. Print the generic board title “numbered list of live work commands” instead of Config `SHORT_DESCRIPTION` / `APP_DESC` on the front board.
22. Omit front **7**, print front **8** as language, or print **70** or **84** through **89**.
23. Dispatch `language` as a live `app_main` command.
24. Hide front **7** on Termux, Git Bash, or Windows cmd.

**Violating this rule is a critical dispatcher / hang / honesty regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | TTY empty argv uses `app_main_menu`; off-TTY empty argv stays Type O on the zero-argument REQ |
| AC-2 | Case 3 recorded; empty argv, `menu`, and `main` named and routed |
| AC-3 | Interactive `menu` and interactive empty argv draw front **1** `action`, **2** `return-original-owner`, **5** `sudoers`, **6** `self-management`, **7** `language`, **9** Exit |
| AC-4 | Interactive `menu --json` still draws the front board |
| AC-5 | Non-interactive `menu` is help; `menu --json` is JSON help |
| AC-6 | Front board omits help, install, version, about, version-check, self-update, self-uninstall, where-is-me, setup, menu, main, list-folders, and `generate-sudoer-json` |
| AC-7 | Command labels match kept-list human-readable `verb: explain`; category explain is this file |
| AC-8 | Header is live `take-ownership(VERSION)` (bold name, italic version on TTY) then the layer title; numbered `explain` is italic + light gray on TTY; no CSI off-TTY |
| AC-9 | Menu choice is read in the current shell; **MUST NOT** `$()` a `read` helper |
| AC-10 | Choosing **5** / `sudoers` opens **51–55** with **0** Back and **no** Exit **9** |
| AC-11 | `take-ownership sudoers` and `take-ownership self-management` are unknown |
| AC-12 | Submenu member verbs remain live CLI commands and share the same handlers as the typed verbs |
| AC-13 | Choosing **6** opens **61–66** with **0** Back; **67** is not printed |
| AC-14 | After a valid leaf returns, the front board is shown again |
| AC-15 | An unknown menu token warns and reprints **this** layer; it does not `out_die` |
| AC-16 | On Termux, Git Bash, or Windows cmd, front **5** is omitted and the menu-hidden message is printed before the numbers |
| AC-17 | The allowed-folder picker prints **0** Back; **0** returns to the parent without `[ERROR]`; an unknown token reprints that picker. The front board has no **0** Back row; **0** there warns and reprints the front board |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-cli-zero-arguments` | Empty argv: TTY this handler; off-TTY Type O |
| `requirement-shell-cli-interface` | Dual mention: empty argv + `menu` / `main`; five sudoers verbs and six self-management verbs routed; `language` is not dispatched |
| `requirement-shell-cli-language` | Codes, file, and copy; front **7** / **71–83** |
| `requirement-shell-interactive-vs-noninteractive` | `TTY`; no hang |
| `requirement-shell-output-requirements` | `out_*` / `util_app_ident` / `out_menu_choice`; reuse `app_help` |
| `requirement-shell-self-management` | Handlers for **61–66** |
| `requirement-domain-take-ownership` | `action` and the five grant/draft verbs |
| `requirement-take-ownership-ops` | Allowed-folder picker inside `action` (item indexes, **0** leaves that picker) |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-CLI-07** | `tests/test_cli.sh` | **have** — off-TTY empty argv is not the numbered list (AC-1) |
| **TP-CLI-13** | same | **have** — front **1 / 2 / 5 / 6 / 7 / 9** on `menu` and empty argv (AC-3) |
| **TP-CLI-32** | same | **have** — language **71–83**; front **8** does not open the board (AC-3) |
| **TP-CLI-14** | same | **have** — interactive `menu --json` still prints the front board (AC-4) |
| **TP-CLI-15** | same | **have** — non-interactive `menu` is help; `--json` JSON help (AC-5) |
| **TP-CLI-16** | same | **have** — install/version/about stay off the front board and appear as **61–63** (AC-6, AC-13) |
| **TP-CLI-19** | same | **have** — default CLI main menu style (AC-8; product alias of portable **TP-CLI-17**) |
| **TP-CLI-21** | same | **have** — front **1 / 5 / 6 / 7 / 9**; `sudoers` and `self-management` unknown as argv (AC-3, AC-11) |
| **TP-CLI-22** | same | **have** — sudoers **51–55**, **0** Back, no submenu **9** (AC-10) |
| **TP-CLI-23** | same | **have** — self-management **61–66**, **0** Back, **67** absent, `where-is-me` not a row (AC-13) |
| **TP-CLI-24** | same | **have** — after a leaf, front board returns; unknown token reprints this layer (AC-14, AC-15) |
| **TP-CLI-25** | same | **have** — Termux / Git Bash / Windows cmd omits **5** and prints the menu-hidden message (AC-16) |
| **TP-CLI-26** | same | **have** — front **0** warns and reprints; it does not leave (AC-17) |
| **TP-TAKE-OWNERSHIP-45** | `tests/test_domain_take_ownership.sh` | **have** — folder picker **0** Back; invalid token reprints (AC-17) |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## Under command line for normal user only

When this program runs on Termux, Git Bash, or Windows Command Prompt, it **MUST** stay on **your own login**. Admin privilege and a dedicated system account are **unused**. This menu **MUST NOT** wrap `sudo` on that class.

**This requirement:** front **5** sudoers is omitted and the menu-hidden message in §2.7 is printed before the front numbers. Front **1**, front **2**, front **6**, front **7**, front **9**, and self-management **61–66** stay. Those lifecycle rows are your own login. Row **7** is not a hide cause.

Detect (typical): Termux — `PREFIX` contains `com.termux`; Git Bash — `MSYSTEM` is `MINGW*` / `MSYS*`; Windows cmd — `OS=Windows_NT` after excluding Git Bash / WSL.

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
| 2026-09-08 | Active 2.5.0 | Registry aligned with 2.4.0 tree |
| 2026-09-30 | Active 3.0.0 | Sibling sshd-cli numbering: front **1** `action` / **7** sudoers / **8** self-management / **9** Exit; sudoers **71–75**; self-management **81–86**; **0** Back; **87** reserved. Ship unit still on the 2.4.0 tree at that writing. |
| 2026-09-30 | Active 3.0.1 | Ship unit draws this tree. **TP-CLI-13**, **TP-CLI-16**, and **TP-CLI-21** through **TP-CLI-25** are **have**. |
| 2026-09-30 | Active 3.0.2 | Allowed-folder picker and the multi-draft list print **0** Back. Back and an invalid token do not `out_die`. Front **0** stays an invalid choice. **TP-CLI-26** and **TP-TAKE-OWNERSHIP-45** are **have**. |
| 2026-10-04 | Active 3.1.0 | Front **5** language. Block **50–69**, assigned **51–63**. Front **6** is not a row. Copy follows `requirement-shell-cli-language` **1.0.0**. **TP-CLI-32** is **have**. |
| 2026-10-14 | Active 3.2.0 | Front **2** is `return-original-owner`. Front **3**, **4**, and **6** stay reserved. **TP-CLI-13** includes row **2**. |
| 2026-10-14 | Active 3.3.0 | Front **5** sudoers (**51–55**), **6** self-management (**61–66**, **67** reserved), **7** language (block **70–89**, assigned **71–83**). Front **8** is not a row. Termux, Git Bash, and Windows cmd omit **5**. |

---

**Last Updated**: 2026-10-14  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
