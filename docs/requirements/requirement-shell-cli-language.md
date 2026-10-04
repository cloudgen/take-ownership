**file**: docs/requirements/requirement-shell-cli-language.md
**Status**: Active (Version 1.0.0)
**Area**: shell
**Key**: `requirement-shell-cli-language`
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the product law for **menu language** on take-ownership. The thirteen codes and the order **51–63** match the sibling shell language block used by grok-cli and sshd-cli: English, Simplified Chinese, Traditional Chinese, Spanish, Arabic, French, Portuguese, Russian, German, Japanese, Korean, Dutch, and Greek. It owns the language codes, the saved file, which boards follow the code, and the words those boards print.

Which row is **5**, and how Back and Exit behave on the numbered tree, stays owned by `requirement-shell-cli-default-interaction`. The persistence directory stays owned by `requirement-shell-cli-storage`. This file owns the `language` leaf and the copy.

On this product, **9** leaves only from the front board. The language board is a submenu: it prints **0** Back and does not print **9** Exit. That leave rule is this product’s menu law. It is not the grok-cli submenu rule, where **9** on a submenu leaves the program.

### 1.1 Human-facing

**In one sentence:** Menu **5** chooses one of thirteen languages, **51** English through **63** Ελληνικά, for the numbered menu, for human `help`, and for human `about`, and the next run opens in that language.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Pick a language and the next run opens in it | `5` then `53` |
| Scripts / CI | The override does not write the file | `TAKE_OWNERSHIP_LANG=ja take-ownership help` |
| Not this file | Which row is **5**, and that **9** leaves only from the front board | `requirement-shell-cli-default-interaction` |

| Includes | Excludes |
|----------|----------|
| Codes `en`, `zh-Hans`, `zh-Hant`, `es`, `ar`, `fr`, `pt`, `ru`, `de`, `ja`, `ko`, `nl`, and `el`; front **5** / block **50–69** (assigned **51–63**); human `help` and human `about` | Translating command output, argv `version`, JSON about fields, or operational error text |
| File `${HOME}/.local/${APP_NAME}/language` | Putting that file in the cache folder or under `/var` |

| Surface | What you open | What for |
|---------|---------------|----------|
| `./src/take-ownership` | ship unit | live menu, help, and about |
| `take-ownership` | no command, on a terminal | front board, including row **5** |
| `take-ownership help` | command | human help in the saved language |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Change the menu language | The language board lists **51** through **63**. The choice is saved. The front board comes back in that language. | `5`, then `51` through `63` |
| Leave the language board | Back does not write the file. **9** on that board is not Exit. | `0` |
| One run in another language | The env wins for this process and does not write the file. | `TAKE_OWNERSHIP_LANG=ja take-ownership menu` |

## 2. Core Rules / Requirements (Mandatory)

**Claimed:** yes. Default language is English so an existing menu test keeps matching English words.

### 2.1 Languages

| Code | Name on the language board | Number | Default |
|------|----------------------------|--------|---------|
| `en` | English | **51** | yes |
| `zh-Hans` | 简体中文 | **52** | no |
| `zh-Hant` | 繁體中文 | **53** | no |
| `es` | Español | **54** | no |
| `ar` | العربية | **55** | no |
| `fr` | Français | **56** | no |
| `pt` | Português | **57** | no |
| `ru` | Русский | **58** | no |
| `de` | Deutsch | **59** | no |
| `ja` | 日本語 | **60** | no |
| `ko` | 한국어 | **61** | no |
| `nl` | Nederlands | **62** | no |
| `el` | Ελληνικά | **63** | no |

**MUST** accept only these thirteen codes in this version. **MUST** treat a missing file, an empty file, or any other first line as English for this process. **MUST NOT** rewrite a file whose first line is not one of these codes. **MUST NOT** add a fourteenth code without a new revision of this file. Numbers **50** through **69** are the only language rows (not more than 20 languages). **50** and **64** through **69** are reserved and are not printed.

The short names **English**, **简体中文**, **繁體中文**, **Español**, **العربية**, **Français**, **Português**, **Русский**, **Deutsch**, **日本語**, **한국어**, **Nederlands**, and **Ελληνικά** are the same words in every language (each language’s own name).

### 2.2 Where the choice is stored

1. The leaf is `${HOME}/.local/${APP_NAME}/language`, inside the persistence directory from `requirement-shell-cli-storage`. **MUST NOT** put it in the cache folder. **MUST NOT** put it under `/var`.
2. The file is one line, one of the thirteen codes, then a newline. Mode **0600**. A trailing CR is ignored. Only the first line is read.
3. `app_lang_load` sets `APP_LANG` once, at the start of `app_main`, after persistence is resolved and before argv dispatch. Human `help`, human `about`, and the menu all see that value. **MUST NOT** call it again in that same process. A later call would let `TAKE_OWNERSHIP_LANG` cover a pick just saved.
4. When `TAKE_OWNERSHIP_LANG` is one of those thirteen codes, that value wins over the file at process start. It does not write the file. A menu pick still writes the file and sets `APP_LANG` for the rest of that process.
5. `app_lang_save` writes the line and sets `APP_LANG` only after the write succeeds. A code outside the thirteen returns failure and leaves `APP_LANG` unchanged.

### 2.3 Menu numbers

Front **5** opens the language board on every host, including Termux, Git Bash, and Windows cmd. It is not a hide cause. Front **2**, **3**, **4**, and **6** are not rows. Choosing **6** warns and does not open the language board and does not write the file. **51** saves `en`. **52** saves `zh-Hans`. **53** saves `zh-Hant`. **54** saves `es`. **55** saves `ar`. **56** saves `fr`. **57** saves `pt`. **58** saves `ru`. **59** saves `de`. **60** saves `ja`. **61** saves `ko`. **62** saves `nl`. **63** saves `el`. Each is a valid leaf: an info line names the language, then the front board redisplays in that language.

**0** / `q` / empty / `back` is Back and does not write the file. **9** on this board is an invalid choice. It does not leave the program. EOF returns to the front board and does not write the file. An invalid choice, including **50** and **64** through **69**, warns and reprints this board. **MUST NOT** `out_die`.

`language` is not an argv verb. Typed `language`, `語言`, `语言`, `idioma`, `langue`, `Sprache`, `sprache`, `言語`, `언어`, `لغة`, `язык`, `taal`, and `γλώσσα` on the front board open it when row **5** is listed (it always is).

The language board also accepts:

| Row | Typed tokens |
|-----|----------------|
| **51** | `english`, `en`, `English` |
| **52** | `simplified-chinese`, `zh-hans`, `zh-Hans`, `简体中文` |
| **53** | `traditional-chinese`, `zh-hant`, `zh-Hant`, `繁體中文` |
| **54** | `spanish`, `es`, `Español`, `español` |
| **55** | `arabic`, `ar`, `العربية`, `عربي` |
| **56** | `french`, `fr`, `Français`, `français` |
| **57** | `portuguese`, `pt`, `Português`, `português`, `portugues` |
| **58** | `russian`, `ru`, `Русский`, `русский` |
| **59** | `german`, `de`, `Deutsch`, `deutsch` |
| **60** | `japanese`, `ja`, `日本語` |
| **61** | `korean`, `ko`, `한국어` |
| **62** | `dutch`, `nl`, `Nederlands`, `nederlands` |
| **63** | `greek`, `el`, `Ελληνικά`, `ελληνικά` |

The front board also accepts the displayed category short for self-management: `self-management`, `自我管理`, `autogestión`, `autogestion`, `Selbstverwaltung`, `selbstverwaltung`, `自己管理`, `자기관리`, `إدارة-ذاتية`, `autogestão`, `самоуправление`, `zelfbeheer`, `αυτοδιαχείριση`. The sudoers short stays `sudoers` in every language. The leaf short `action` stays `action` in every language.

### 2.4 What follows the saved language

**MUST** follow `APP_LANG` on these boards: front, language, self-management, and sudoers. That covers the layer title, the category shorts, every long description, Back, Exit, the choose-prompt, the unknown-choice line, and the menu-hidden sentence. The allowed-folder picker and the multi-draft list use the same Back word and the same choose-prompt. Their item paths stay as paths.

**MUST** keep each leaf short as the English verb in every language (`action`, `install`, `generate-sudoer-request`, and the other leaf tokens). The sudoers category short stays `sudoers` in every language.

English (`APP_LANG=en`, or unset) **MUST** keep these literals so the existing menu tests still match: `Choice: ` (trailing space), `Not a menu choice:`, `Choose a listed number or command name.`, `9. Exit`, `0. Back`, `1. action: Recursively take ownership of a named folder`, `5. language: display language for this menu`, `7. sudoers: Grant and drafts`, `8. self-management: This CLI install, version, update, uninstall`, `sudoers not available for `, and the front title `Take Unix ownership of a named folder with a narrow global-only sudo grant`.

Category shorts:

| Token | en | zh-Hans | zh-Hant | es | ar | fr | pt |
|-------|----|---------|---------|----|----|----|-----|
| language | language | 语言 | 語言 | idioma | لغة | langue | idioma |
| self-management | self-management | 自我管理 | 自我管理 | autogestión | إدارة-ذاتية | autogestion | autogestão |
| sudoers | sudoers | sudoers | sudoers | sudoers | sudoers | sudoers | sudoers |
| action | action | action | action | action | action | action | action |

| Token | ru | de | ja | ko | nl | el |
|-------|----|----|----|----|----|-----|
| language | язык | Sprache | 言語 | 언어 | taal | γλώσσα |
| self-management | самоуправление | Selbstverwaltung | 自己管理 | 자기관리 | zelfbeheer | αυτοδιαχείριση |
| sudoers | sudoers | sudoers | sudoers | sudoers | sudoers | sudoers |
| action | action | action | action | action | action | action |

English front longs: action `Recursively take ownership of a named folder`; language `display language for this menu`; sudoers `Grant and drafts`; self-management `This CLI install, version, update, uninstall`. The other twelve languages use the same meaning through `app_menu_text`.

Language-board longs (English): `use English for this menu`, `use Simplified Chinese for this menu`, `use Traditional Chinese for this menu`, `use Spanish for this menu`, `use Arabic for this menu`, `use French for this menu`, `use Portuguese for this menu`, `use Russian for this menu`, `use German for this menu`, `use Japanese for this menu`, `use Korean for this menu`, `use Dutch for this menu`, `use Greek for this menu`.

Back / Exit: en `Back` / `Exit`; zh-Hans `返回` / `离开`; zh-Hant `返回` / `離開`; es `Atrás` / `Salir`; ar `رجوع` / `خروج`; fr `Retour` / `Quitter`; pt `Voltar` / `Sair`; ru `Назад` / `Выход`; de `Zurück` / `Beenden`; ja `戻る` / `終了`; ko `뒤로` / `종료`; nl `Terug` / `Afsluiten`; el `Πίσω` / `Έξοδος`.

After a successful save the info line is printed in the new language:

| Code | Saved |
|------|--------|
| `en` | `Menu language is English` |
| `zh-Hans` | `菜单语言是简体中文` |
| `zh-Hant` | `選單語言是繁體中文` |
| `es` | `El idioma del menú es español` |
| `ar` | `لغة القائمة هي العربية` |
| `fr` | `La langue du menu est le français` |
| `pt` | `O idioma do menu é português` |
| `ru` | `Язык меню — русский` |
| `de` | `Die Menüsprache ist Deutsch` |
| `ja` | `メニューの言語は日本語` |
| `ko` | `메뉴 언어는 한국어` |
| `nl` | `Menutaal is Nederlands` |
| `el` | `Η γλώσσα του μενού είναι ελληνικά` |

A failed write warns in the language that was current before the failed write, leaves `APP_LANG` unchanged, and still returns to the front board. English failure text is `Could not save the menu language`.

**MUST** follow `APP_LANG` on human `help` and human `about`. Section headings follow the code. The command token, the flag, the path, and the env name stay the Latin spelling (`install`, `action`, `--json`, `SCRIPT_URL`, `TAKE_OWNERSHIP_LANG`). English `help` still prints `Usage:` and `Grant testers (test-purpose`. English `about` still prints `About / Diagnostics` and `Cache folder used:`. Japanese help prints `使い方:`. Japanese about prints `概要 / 診断` and `使用中のキャッシュフォルダ:`. Korean about prints `개요 / 진단` and `사용 중인 캐시 폴더:`. Greek help prints `Χρήση:`.

**Stays English in this version:** argv `version`, operational command output, JSON about keys and JSON values, and JSON help.

`app_menu_text` prints the chosen string on stdout. The caller passes that string to `out_*`. The operator sees `out_*`. `app_menu_text` is pure data: it **MUST NOT** call `read`.

### 2.5 Implementation Notes (this product)

| Item | Value |
|------|--------|
| **Product** | `take-ownership` |
| **Env** | `TAKE_OWNERSHIP_LANG` |
| **Leaf** | `${HOME}/.local/take-ownership/language` mode **0600** |
| **Load / save** | `app_lang_load` once in `app_main`; `app_lang_save` from the language board |
| **Copy** | `app_menu_text` |
| **Boards** | `app_main_menu_print`, `app_main_menu_print_language`, `app_main_menu_print_sudoers`, `app_main_menu_print_self` |
| **Front row** | **5** (every host) |
| **Assigned rows** | **51–63** |
| **Reserved, not printed** | **50**, **64–69**; front **2**, **3**, **4**, **6** |
| **Not an argv verb** | `language` |

### 2.6 Why this requirement exists

- **CIAO Principle 2 – Intentional**: One saved language, named codes, and a fixed row. The next run does not guess.
- **CIAO Principle 5 – Single source of output**: Menu words go through `app_menu_text` into `out_*`.
- **CIAO Principle 1 – Caution**: A bad code and a failed write do not clobber the file or `APP_LANG`.

## Under command line for normal user only

When this program runs on Termux, Git Bash, or Windows Command Prompt, it **MUST** stay on **your own login**. Admin privilege and a dedicated system account are **unused**.

**This requirement:** front **5** language stays on that class. The language file stays under this login’s persistence directory. Saving a language does not wrap `sudo` and does not write `/etc`.

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Do not rewrite a file that is not one of the thirteen codes. Do not `out_die` for a bad language pick.
- **Intentional:** Thirteen codes, row **5**, block **50–69**, env override that does not write.
- **Anti-fragile:** Missing, empty, or unknown file means English for this process only.
- **Over-protect:** Leaf mode **0600**. JSON and argv `version` stay English. `language` is not a dispatcher token.

## 4. Protection Rule (Sacred)

**Future AI assistants or maintainers MUST NOT**:

1. Add a fourteenth language code without a new revision of this file.
2. Print **50** or **64** through **69**, or print front **6** as the language row.
3. Put the language file in the cache folder or under `/var`.
4. Call `app_lang_load` again after a menu pick in the same process.
5. Let `TAKE_OWNERSHIP_LANG` write the file.
6. Dispatch `language` as an argv verb.
7. Translate JSON about keys, JSON help, or argv `version`.
8. Change the English menu literals named in §2.4.
9. Hide row **5** on Termux, Git Bash, or Windows cmd.
10. Use **9** on the language board as Exit.

## 5. Related artifacts

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Registry |
| `docs/requirements/requirement-shell-cli-default-interaction.md` | Front **5**; Back and Exit |
| `docs/requirements/requirement-shell-cli-storage.md` | Persistence directory |
| `docs/requirements/requirement-shell-cli-interface.md` | `language` is not dispatched |
| `./src/take-ownership` | Ship unit |

## 6. Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-CLI-32** | `tests/test_cli.sh` | have (front **5** / block **50–69**, assigned **51–63**, **50** and **64–69** unprinted, front **6** does not open the board, save mode 0600, `TAKE_OWNERSHIP_LANG` override, Back does not write, next run uses the file, help and about follow the code) |
| **TP-CLI-13** · **TP-CLI-25** · **TP-CLI-26** | `tests/test_cli.sh` | have (English front still matches; **5** is language; Termux still prints **5** and still hides **7**) |

**Matrix:** `reviews/requirement-test-matrix.md`
**Map:** `reviews/test-plan.md`

---

**Last Updated**: 2026-10-04
**Owner**: product
**Alignment**: `requirement-shell-cli-default-interaction` · `requirement-shell-cli-storage` · `requirement-shell-cli-interface` · CIAO / CIAO-Lite
