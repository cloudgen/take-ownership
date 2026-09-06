# Test plan — take-ownership

Maps **TP-*** coverage to `tests/`.  
**Suite entry:** `./tests/run.sh`  
**Ship unit:** `src/take-ownership`  
**Product VERSION:** 2.7.1  
**Last plan update:** 2026-09-06  
**Last suite run:** `./tests/run.sh` (2.7.1: PASS=277 FAIL=0 SKIP=0 — **TP-TAKE-OWNERSHIP-44** granted-missing · **TP-CLI-20**)

Status: **have** = automated today · **todo** = needed · **optional** · **n/a** · **skip** (environment)

---

## Baseline coverage

| Area | Status | Evidence |
|------|--------|----------|
| Syntax `sh -n` | have | TP-CLI-01 |
| version / help / about human + JSON | have | TP-CLI-02..06 |
| Empty argv never install; off-TTY help; TTY menu | have | TP-CLI-07, **13**, **15** |
| empty argv / `menu`/`main` TTY list / off-TTY help | have | TP-CLI-13..16 |
| TTY main-menu look (nametag + gray italic explain) | have | TP-CLI-19 |
| Unknown + quiet + set -u HOME | have | TP-CLI-08..11 |
| Storage isolation | have | TP-CLI-12, **18** |
| No online verbs / no SCRIPT_URL UX | have | TP-CLI-04, TP-CLI-10 |
| Command line for normal user only (Git Bash still Type 0) | have | TP-CLI-20 |
| Local install / idempotent / uninstall / mode 0755 | have | TP-LC-01..10 |
| Grant emit requires global binary | have | TP-TAKE-OWNERSHIP-03, **30** |
| JSON grant `action --path` `--ownership user:group` | have | TP-TAKE-OWNERSHIP-20..22, **27**, **31** |
| Ownership fence (`*` / glob / missing) | have | TP-TAKE-OWNERSHIP-28, **29** |
| list-folders + action gate | have | TP-TAKE-OWNERSHIP-17, **40**, **41** |
| TTY numbered pick + current `user:group` | have | TP-TAKE-OWNERSHIP-42, **43** |
| Granted-missing dir not a live pick; recreate-then-action | have | TP-TAKE-OWNERSHIP-**44** |
| Ram-drive `--path` exception | have | TP-TAKE-OWNERSHIP-11b, **16** |
| Online curl / companion checksum | n/a | Local-only product |
| Backup / restore / retention | n/a | Retired with folder-backup domain |

---

## TP rows

### TP-CLI (CLI surface)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-CLI-01 | `sh -n` ship unit | `tests/test_cli.sh` | requirement-shell-cli-interface | **have** |
| TP-CLI-02 | version human | test_cli | requirement-shell-cli-interface | **have** |
| TP-CLI-03 | version JSON | test_cli | requirement-shell-output-requirements | **have** |
| TP-CLI-04 | help local verbs; no online; no backup/restore | test_cli | requirement-shell-cli-interface · domain | **have** |
| TP-CLI-05 | help JSON short | test_cli | requirement-shell-output-requirements | **have** |
| TP-CLI-06 | about JSON cache + persist | test_cli | requirement-shell-cli-storage · domain | **have** |
| TP-CLI-07 | empty argv never install; off-TTY help | test_cli | requirement-shell-cli-zero-arguments | **have** |
| TP-CLI-08 | unknown fail-closed | test_cli | requirement-shell-cli-interface | **have** |
| TP-CLI-09 | quiet suppresses version | test_cli | requirement-shell-output-requirements | **have** |
| TP-CLI-10 | online verbs rejected; backup/restore unknown | test_cli | requirement-bootstrap-chain | **have** |
| TP-CLI-11 | env -u HOME version | test_cli | class / defensive | **have** |
| TP-CLI-12 | preferred cache `/dev/shm/cache/cache-${APP_NAME}` | test_cli | requirement-shell-cli-storage | **have** |
| TP-CLI-13 | interactive `menu` **and** empty argv print `action` + family `sudoers` + `9. Exit` | test_cli | shell-cli-default-interaction | **have** |
| TP-CLI-14 | interactive `menu --json` still prints the list | test_cli | shell-cli-default-interaction | **have** |
| TP-CLI-15 | non-interactive `menu` and empty argv are help | test_cli | shell-cli-default-interaction | **have** |
| TP-CLI-16 | numbered list omits help/install/version/about/test-purpose/`list-folders` | test_cli | shell-cli-default-interaction | **have** |
| TP-CLI-17 | help lists test-purpose `generate-sudoer-json` apart | test_cli | shell-cli-interface | **have** |
| TP-CLI-18 | persist `${HOME}/.local/${APP_NAME}` | test_cli | requirement-shell-cli-storage | **have** |
| TP-CLI-19 | default CLI main menu style | test_cli | shell-cli-default-interaction · output | **have** |
| TP-CLI-20 | Git Bash (`MSYSTEM`) still runs Type 0 `version` | test_cli | shell-sudo-command · command line for normal user only | **have** |

### TP-LC (local lifecycle)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-LC-01 | install → USER_BIN | test_local_lifecycle | requirement-shell-local-self-management | **have** |
| TP-LC-02 | installed binary version | test_local_lifecycle | local self-management | **have** |
| TP-LC-03 | reinstall already-installed | test_local_lifecycle | requirement-shell-idempotency | **have** |
| TP-LC-04 | where-is-me | test_local_lifecycle | local self-management | **have** |
| TP-LC-05 | uninstall JSON no force fail-closed | test_local_lifecycle | interactive-vs-noninteractive | **have** |
| TP-LC-06 | uninstall --force removes | test_local_lifecycle | local self-management | **have** |
| TP-LC-07 | uninstall absent no-op | test_local_lifecycle | idempotency | **have** |
| TP-LC-08 | about shows installed | test_local_lifecycle | local self-management | **have** |
| TP-LC-09 | installed mode is `0755` | test_local_lifecycle | local self-management | **have** |
| TP-LC-10 | reinstall without force heals `0711` → `0755` | test_local_lifecycle | local self-management | **have** |

### TP-TAKE-OWNERSHIP (domain + privilege)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-TAKE-OWNERSHIP-01 | action missing flags fail, no hang | test_domain | take-ownership-ops | **have** |
| TP-TAKE-OWNERSHIP-03 | generate without global binary fail-closed | test_domain | three-layer | **have** |
| TP-TAKE-OWNERSHIP-11 | refuse `/etc`, relative, symlink `--path` | test_domain | take-ownership-ops | **have** |
| TP-TAKE-OWNERSHIP-11b | refuse `/dev` and `/dev/shm` mount root | test_domain | take-ownership-ops | **have** |
| TP-TAKE-OWNERSHIP-12 | missing user:group fail-closed | test_domain | take-ownership-ops | **have** |
| TP-TAKE-OWNERSHIP-13 | already matching is success | test_domain | take-ownership-ops · idempotency | **have** |
| TP-TAKE-OWNERSHIP-14 | non-TTY missing ownership does not hang | test_domain | take-ownership-ops | **have** |
| TP-TAKE-OWNERSHIP-15 | swapped flag order fail-closed | test_domain | take-ownership-ops | **have** |
| TP-TAKE-OWNERSHIP-16 | ram-drive `/dev/shm/<project>` allowed | test_domain | take-ownership-ops | **have** |
| TP-TAKE-OWNERSHIP-17 | `--path` not in list-folders fail-closed | test_domain | take-ownership-ops | **have** |
| TP-TAKE-OWNERSHIP-20 | generate JSON grant global path + action args | test_domain | sudoer-json-file | **have** |
| TP-TAKE-OWNERSHIP-21 | grant has no `/bin/chown` / mkdir | test_domain | sudoer-json-file | **have** |
| TP-TAKE-OWNERSHIP-22 | `--ownership user:group`; no `"*"`; `--json` twin | test_domain | sudoer-json-file | **have** |
| TP-TAKE-OWNERSHIP-24 | generate dest exists (readable without sudo) | test_domain | three-layer | **have** |
| TP-TAKE-OWNERSHIP-27 | dirty cwd still emits `user:group` (not `*`) | test_domain | sudoer-json-file · incorrect-ownership | **have** |
| TP-TAKE-OWNERSHIP-27b | dest has no cwd names | test_domain | sudoer-json-file | **have** |
| TP-TAKE-OWNERSHIP-28 | globbed `--ownership` submit fail-closed | test_domain | sudoer-json-file · operator-readable-error | **have** |
| TP-TAKE-OWNERSHIP-28b | star-grant submit fail-closed | test_domain | incorrect-ownership | **have** |
| TP-TAKE-OWNERSHIP-29 | generate `*` ownership fail-closed | test_domain | incorrect-ownership | **have** |
| TP-TAKE-OWNERSHIP-29b | generate missing `--ownership` | test_domain | incorrect-ownership | **have** |
| TP-TAKE-OWNERSHIP-29c | action `*` ownership fail-closed | test_domain | incorrect-ownership | **have** |
| TP-TAKE-OWNERSHIP-30 | print-sudoers without global fail-closed | test_domain | three-layer | **have** |
| TP-TAKE-OWNERSHIP-31 | print-sudoers text dual `user\:group` | test_domain | sudoer-json-file | **have** |
| TP-TAKE-OWNERSHIP-32 | print-sudoers does not write `/etc` | test_domain | three-layer | **have** |
| TP-TAKE-OWNERSHIP-33 | later folder is replacement union (two lines) | test_domain | sudoer-json-file | **have** |
| TP-TAKE-OWNERSHIP-33b | duplicate folder does not add a line | test_domain | sudoer-json-file | **have** |
| TP-TAKE-OWNERSHIP-34 | `--path` file not folder fail-closed | test_domain | sudoer-json-file | **have** |
| TP-TAKE-OWNERSHIP-40 | list-folders prints grant path | test_domain | take-ownership-ops | **have** |
| TP-TAKE-OWNERSHIP-41 | list-folders JSON | test_domain | take-ownership-ops | **have** |
| TP-TAKE-OWNERSHIP-42 | TTY `action` numbered allowed folders | test_domain | take-ownership-ops | **have** |
| TP-TAKE-OWNERSHIP-43 | TTY pick uses current `user:group` | test_domain | take-ownership-ops | **have** |
| TP-TAKE-OWNERSHIP-44 | Granted-missing dir not a live pick; recreate-then-action | test_domain | take-ownership-ops · operator-readable-error · L-OPS-01 | **have** |

---

## Lineage (not Core)

`TP-FOLDER-BACKUP-*` rows (backup, restore, retention, `--allow-test-local`) are **retired**. They are not in `tests/`. Do not mark them **have** for take-ownership.

---

## Rules

1. Closing a **bug** finding updates the matching TP to **have**.  
2. Do not mark TP **have** without a suite assertion (or honest skip/n/a).  
3. Do not reintroduce online TP-CURL/TP-CSUM as Core without product-mode change.  
4. Do not reintroduce backup/restore TPs as Core.  
5. JSON grant / submit reviews require **TP-TAKE-OWNERSHIP-27/28** stay **have**.  
