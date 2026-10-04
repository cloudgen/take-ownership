# Filled run: language menu 5 — take-ownership 3.1.0

**Date:** 2026-10-04
**Checklist:** `docs/checklists/2026-10-04-checklist-menu-language.md` (local; not on the git surface)
**Product:** take-ownership **3.1.0**
**Law:** `requirement-shell-cli-language` **1.0.0** · `requirement-shell-cli-default-interaction` **3.1.0** · `requirement-shell-cli-interface` **3.2.0** · `requirement-shell-cli-storage` **2.2.0**
**Proof:** **TP-CLI-32** · **TP-CLI-13** · **TP-CLI-25** (`tests/test_cli.sh`)
**Suite:** PASS=479 FAIL=0 SKIP=1 (`sh tests/run.sh`, 2026-10-04). The skip is **TP-CURL-09** (optional public network).

## Verdict

- [x] **Pass** — front **5** language; block **50–69**; thirteen assigned rows **51–63**
- [ ] **Revise**
- [ ] **Block**

Reviewer / role: Implement + Review (this change)
Date: 2026-10-04

## Checklist

- [x] Front row is **5** language on every host, including Termux / Git Bash / Windows cmd
- [x] Language rows are reserved **50–69** (twenty numbers, not more than 20 languages)
- [x] Assigned rows are **51** English, **52** 简体中文, **53** 繁體中文, **54** Español, **55** العربية, **56** Français, **57** Português, **58** Русский, **59** Deutsch, **60** 日本語, **61** 한국어, **62** Nederlands, **63** Ελληνικά
- [x] **50** and **64–69** are not printed; choosing **50**, **64**, or **69** warns with `Not a menu choice:` and does not write `language`
- [x] Front **6** is not a row; choosing **6** warns and does not open **51**
- [x] **9** leaves only from the front board. On the language board, **9** warns and the board stays. **0** Back does not write the file
- [x] Requirements, review matrix, test plan, and **TP-CLI-32** name the same numbers
- [x] `take-ownership.sha256` is the bare hex of `take-ownership`

## 1. Membership and Exit

- [x] English front literals stay (`5. language: display language for this menu`, `Choice: `, `Not a menu choice:`, `9. Exit`, `0. Back`)
- [x] Leaf shorts stay the English verb. The sudoers short stays `sudoers`
- [x] Category shorts `language` and `self-management` follow `APP_LANG`
- [x] Invalid choice uses a warning and reprints that layer. It is not `[ERROR]`

## 2. Do not capture `read`

- [x] Language choice is current-shell `read` inside `app_menu_read` / `app_main_menu_language_loop`
- [x] `app_menu_text` does not call `read`

## 3. Save and override

- [x] **53** writes `zh-Hant` and mode **0600**, then the front board shows `5. 語言:`
- [x] The next run keeps that file
- [x] `TAKE_OWNERSHIP_LANG=ja` shows `5. 言語:` and does not rewrite the file
- [x] **63** saves Greek. Typed `arabic` saves Arabic
- [x] A missing or unknown file stays English and is not rewritten

## 4. Help, about, and argv

- [x] Japanese help prints `使い方:` and keeps the token `install` and the name `TAKE_OWNERSHIP_LANG`
- [x] Greek help prints `Χρήση:`
- [x] Japanese about prints `概要 / 診断` and `使用中のキャッシュフォルダ:`
- [x] JSON about keeps `"cache_used"` and does not print the Japanese title
- [x] `take-ownership language` is an unknown command

## Scope

| Field | Value |
|-------|--------|
| Script / ship unit | `take-ownership` 3.1.0 (`src/take-ownership` is a symlink) |
| Digest | `4bf1bde774bfe46da2cab2c140ab732b8872020bc60b350c6d3d35646ba54718` |
| Related requirements | language 1.0.0, default-interaction 3.1.0, interface 3.2.0, storage 2.2.0 |
| Change type | menu language, thirteen codes, persistence leaf |

## Non-findings

Operational command text, argv `version`, and JSON keys stay English. The language file is under the persistence directory, not the cache folder.
