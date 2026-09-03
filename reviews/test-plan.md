# Test plan — take-ownership

Maps **TP-*** coverage to `tests/`.  
**Suite entry:** `./tests/run.sh`  
**Ship unit:** `src/take-ownership`  
**Product VERSION:** 2.7.0  
**Last plan update:** 2026-09-03  
**Last suite run:** `./tests/run.sh` (2.7.0: PASS=266 FAIL=0 SKIP=0 — family **sudoers** **TP-CLI-13/17/19**)

Status: **have** = automated today · **todo** = needed · **optional** · **n/a** · **skip** (environment)

---

## Baseline coverage

| Area | Status | Evidence |
|------|--------|----------|
| Syntax `sh -n` | have | TP-CLI-01 |
| version / help / about human + JSON | have | TP-CLI-02..06 |
| Type N empty argv (never install; off-TTY help; TTY menu) | have | TP-CLI-07, **13**, **15** |
| empty argv / `menu`/`main` TTY list / off-TTY help | have | TP-CLI-13..16 |
| TTY main-menu look (nametag + gray italic explain) | have | TP-CLI-19 |
| Unknown + quiet + set -u HOME | have | TP-CLI-08..11 |
| Storage isolation | have | TP-CLI-12 |
| No online verbs / no SCRIPT_URL UX | have | TP-CLI-04, TP-CLI-10 |
| Local install / idempotent / uninstall / mode 0755 | have | TP-LC-01..10 |
| Help lists sudoers verbs (print / install-script / remove draft / **generate** / submit + public inbound) | have | TP-CLI-04 |
| Independent generate dest readable without sudo | have | TP-FOLDER-BACKUP-24/24b/24c/24d |
| Operator-readable inbound-fidelity `[ERROR]` | have | TP-FOLDER-BACKUP-25/25b/25c |
| Submit detect: public inbound first; env override; no Type 0 mkdir | have | TP-FOLDER-BACKUP-19/20/21/21b |
| JSON sudoer file is `folder-backup` backup/restore only (no OS tools / path / filename) | have | TP-FOLDER-BACKUP-22/22b/22c |
| Pretty emit + inbound body keep both verbs (sibling re-encode fidelity) | have | TP-FOLDER-BACKUP-22e/22f |
| Submit action: host `/etc/sudoers.d` fragment → update; else add | have | TP-FOLDER-BACKUP-23/23b/23c |
| Domain surface: print-sudoers allowlist + test-mode gate | have | TP-FOLDER-BACKUP-01, 01b, 01c, 02 |
| Admin install-script handoff (project-sudoers-file) | have | TP-FOLDER-BACKUP-14 |
| Remove project-sudoers draft only | have | TP-FOLDER-BACKUP-15 |
| Multi-draft remove choose / path-required | have | TP-FOLDER-BACKUP-15b |
| Per-user draft + installed sudoers basename | have | TP-FOLDER-BACKUP-14 · 15 |
| Backup ops (name, fail-closed, verify) | have | TP-FOLDER-BACKUP-03..06 · **requirement-folder-archive-backup** |
| Elevated deposit + next-N + verify | have (root **or** allowlisted `sudo -n`) | TP-FOLDER-BACKUP-07/08 |
| Restore (explicit + hard-disk default) | have | TP-FOLDER-BACKUP-11..13 |
| Online curl / companion checksum | n/a | Local-only product |

---

## TP rows

### TP-CLI (CLI surface)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-CLI-01 | `sh -n` ship unit | `tests/test_cli.sh` | requirement-shell-cli-interface | **have** |
| TP-CLI-02 | version human | test_cli | requirement-shell-cli-interface | **have** |
| TP-CLI-03 | version JSON | test_cli | requirement-shell-output-requirements | **have** |
| TP-CLI-04 | help local verbs; print-sudoers + install-script + remove-project-sudoers + generate-sudoer-request + submit-sudoer-request; no online | test_cli | requirement-shell-cli-interface · domain | **have** |
| TP-CLI-05 | help JSON short | test_cli | requirement-shell-output-requirements | **have** |
| TP-CLI-06 | about JSON `cache_preferred`/`cache_fallback`/`persist_dir`; human Cache folder + Persistence storage | test_cli | requirement-shell-cli-storage · domain | **have** |
| TP-CLI-07 | empty argv Type N never install; off-TTY help | test_cli | requirement-shell-cli-zero-arguments | **have** |
| TP-CLI-08 | unknown fail-closed | test_cli | requirement-shell-cli-interface | **have** |
| TP-CLI-09 | quiet suppresses version | test_cli | requirement-shell-output-requirements | **have** |
| TP-CLI-10 | online verbs rejected | test_cli | requirement-bootstrap-chain | **have** |
| TP-CLI-11 | env -u HOME version | test_cli | class / defensive | **have** |
| TP-CLI-12 | preferred cache `/dev/shm/cache/cache-${APP_NAME}`; live dir exists; not APP-USERNAME shape | test_cli | requirement-shell-cli-storage | **have** |
| TP-CLI-13 | interactive `menu` **and** empty argv print `action` + family `sudoers` + `9. Exit`; submenu Back/Exit; `sudoers` unknown | test_cli | **shell-cli-default-interaction** AC-3 / AC-10 / AC-11 | **have** |
| TP-CLI-14 | interactive `menu --json` still prints the list | test_cli | **shell-cli-default-interaction** AC-4 | **have** |
| TP-CLI-15 | non-interactive `menu` and empty argv are help; `--json` JSON help | test_cli | **shell-cli-default-interaction** AC-5 | **have** |
| TP-CLI-16 | numbered list omits help/install/uninstall/where-is-me/version/about/test-purpose/menu/`list-folders`; no `$()` of prompt helpers | test_cli | **shell-cli-default-interaction** AC-6 / AC-9 | **have** |
| TP-CLI-17 | help lists test-purpose `generate-sudoer-json` under a heading apart from operational | test_cli | **shell-cli-interface** AC-9 | **have** |
| TP-CLI-18 | persist `${HOME}/.local/${APP_NAME}` exists; not USER_BIN; not live cache | test_cli | requirement-shell-cli-storage | **have** |
| TP-CLI-19 | default CLI main menu style: header `APP_NAME(VERSION)` bold/italic; numbered explain italic + light gray; no CSI off-TTY (portable **TP-CLI-17** alias) | test_cli | **shell-cli-default-interaction** AC-8 · **shell-output-requirements** AC-5 | **have** |

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
| TP-LC-09 | installed mode is `0755` (readable+executable) | test_local_lifecycle | local self-management §2.3.1 | **have** |
| TP-LC-10 | reinstall without force heals `0711` → `0755` | test_local_lifecycle | local self-management §2.3.1 | **have** |

### TP-FOLDER-BACKUP (domain + privilege)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-FOLDER-BACKUP-01 | print-sudoers with allow; TEST MODE banner; no Type 0 `/etc` write; tar -tzf | test_domain | three-layer §2.3.1a/§2.3.3 · domain | **have** |
| TP-FOLDER-BACKUP-01b | refuse print-sudoers without `--allow-test-local` when not production | test_domain | three-layer trust tier **S13** | **have** |
| TP-FOLDER-BACKUP-01c | print-sudoers text dual includes project **restore** verb | test_domain | three-layer · folder-archive-backup | **have** |
| TP-FOLDER-BACKUP-02 | print-sudoers to path; narrow; per-user stage; test mode in file | test_domain | three-layer privilege | **have** |
| TP-FOLDER-BACKUP-03 | backup missing operand | test_domain | **folder-archive-backup** | **have** |
| TP-FOLDER-BACKUP-04 | backup missing dir | test_domain | **folder-archive-backup** | **have** |
| TP-FOLDER-BACKUP-05 | deposit fail-closed without working sudo | test_domain | folder-archive-backup · three-layer | **have** |
| TP-FOLDER-BACKUP-06 | archive name YYYYMMDD + tar.gz | test_domain | **folder-archive-backup** · idempotency | **have** |
| TP-FOLDER-BACKUP-07 | elevated deposit + verify counts (root or sudo -n) | test_domain | **folder-archive-backup** · three-layer | **have** (host sudoers or root) |
| TP-FOLDER-BACKUP-08 | same-day next-N no overwrite | test_domain | **folder-archive-backup** · idempotency | **have** (host sudoers or root) |
| TP-FOLDER-BACKUP-09 | about domain diagnostics | test_domain | domain about pillar | **have** |
| TP-FOLDER-BACKUP-10 | leaf basename in archive name | test_domain | **folder-archive-backup** | **have** |
| TP-FOLDER-BACKUP-11 | restore missing archive fail-closed | test_domain | **folder-archive-backup** | **have** |
| TP-FOLDER-BACKUP-12 | restore to explicit dest + verify | test_domain | **folder-archive-backup** | **have** |
| TP-FOLDER-BACKUP-13 | restore default host hard-disk + non-empty refuse | test_domain | **folder-archive-backup** | **have** |
| TP-FOLDER-BACKUP-14 | print-sudoers-install-script: draft + admin script; sh -n; root required for install | test_domain | three-layer §2.3.3a · project-sudoers-file | **have** |
| TP-FOLDER-BACKUP-19 | submit-sudoer-request fail-closed when sudoer-cli missing | test_domain | three-layer §2.3.3c | **have** |
| TP-FOLDER-BACKUP-20 | submit-sudoer-request via stub cli writes inbound file | test_domain | three-layer §2.3.3c | **have** |
| TP-FOLDER-BACKUP-21 | submit detect prefers public inbound over leftover `sudoer-approving`; no Type 0 mkdir | test_domain | three-layer §2.3.3c AC-16/17 | **have** |
| TP-FOLDER-BACKUP-21b | `SUDOER_QUEUE_INBOUND` wins over public inbound | test_domain | three-layer §2.3.3c detect priority 1 | **have** |
| TP-FOLDER-BACKUP-22 | JSON sudoer file `path` is only `/usr/local/bin/folder-backup` | test_domain | **sudoer-json-file** AC-1 | **have** |
| TP-FOLDER-BACKUP-22b | JSON sudoer file contains no mkdir/cp/tar/rm/install/chmod | test_domain | **sudoer-json-file** AC-4 | **have** |
| TP-FOLDER-BACKUP-22c | JSON sudoer file contains no deposit/stage path and no `*.tar.gz` | test_domain | **sudoer-json-file** AC-5 | **have** |
| TP-FOLDER-BACKUP-22d | submit refuses OS-tool grant file | test_domain | **sudoer-json-file** AC-7 | **have** |
| TP-FOLDER-BACKUP-22e | pretty emit through real sudoer-cli keeps backup **and** restore (convert + submit) | test_domain | **sudoer-json-file** AC-9 · three-layer AC-21 | **have** |
| TP-FOLDER-BACKUP-22f | stub inbound **body** still contains both verbs (not file-count only) | test_domain | **sudoer-json-file** AC-9 | **have** |
| TP-FOLDER-BACKUP-23 | this-user host fragment under `SUDOERS_D_DIR` → default submit **update** | test_domain | three-layer AC-22 | **have** |
| TP-FOLDER-BACKUP-23b | `--add` overrides host-present default | test_domain | three-layer AC-22 | **have** |
| TP-FOLDER-BACKUP-23c | other-user host fragment does not flip this user to **update** | test_domain | three-layer AC-22 | **have** |
| TP-FOLDER-BACKUP-24 | generate-sudoer-request writes compact JSON with both verbs | test_domain | three-layer §2.3.3d AC-23 | **have** |
| TP-FOLDER-BACKUP-24b | generate explicit path; refuse `/etc` | test_domain | three-layer AC-23 | **have** |
| TP-FOLDER-BACKUP-24c | generated file through real sudoer-cli convert keeps both verbs | test_domain | three-layer AC-23 · sudoer-json-file AC-9 | **have** |
| TP-FOLDER-BACKUP-24d | generate dest is readable without sudo; suite `cat`s body | test_domain | three-layer §2.3.2a AC-24 · sudoer-json-file AC-10 | **have** |
| TP-TAKE-OWNERSHIP-27 | `generate-sudoer-json` from dirty cwd (AGENTS.md/docs/src) still emits `"--ownership","<user:group>"` (not `"*"`) | test_domain | sudoer-json-file AC-10 · incorrect-ownership AC-3 · INC-20260823-002 | **have** |
| TP-TAKE-OWNERSHIP-27b | same dest has no cwd names | test_domain | sudoer-json-file AC-10 | **have** |
| TP-TAKE-OWNERSHIP-28 | submit of globbed `--ownership` listing fails closed; names generate-sudoer-json | test_domain | sudoer-json-file AC-11 · operator-readable-error AC-2 | **have** |
| TP-TAKE-OWNERSHIP-42 | TTY `action` without `--path` prints numbered allowed folders | test_domain | take-ownership-ops AC-6 | **have** |
| TP-TAKE-OWNERSHIP-43 | TTY pick uses current `user:group` with no ownership prompt | test_domain | take-ownership-ops AC-6 | **have** |
| TP-TAKE-OWNERSHIP-44 | Granted `--path` whose directory is missing is not a live TTY `action` row; `action --path` fail-closed names recreate-then-action (not generate) | test_domain | take-ownership-ops §2.2/§2.5a · operator-readable-error · INC-20260830-001 · L-OPS-01 | **todo** |
| TP-FOLDER-BACKUP-25 | inbound-fidelity error names incompleteness in operator words | test_domain | operator-readable-error AC-1 | **have** |
| TP-FOLDER-BACKUP-25b | same error names `generate-sudoer-request` | test_domain | operator-readable-error AC-2 | **have** |
| TP-FOLDER-BACKUP-25c | same error does not contain `sibling re-encode` | test_domain | operator-readable-error AC-3 | **have** |
| TP-FOLDER-BACKUP-26 | print-sudoers text + JSON emit `backup *` / `restore *`; verb-only **Fail** | test_domain | three-layer AC-25 · **sudoer-json-file** AC-3/AC-8 · INC-20260823-001 | **have** |
| TP-FOLDER-BACKUP-26b | generate compact JSON `args` include `*` after each verb | test_domain | **sudoer-json-file** AC-3 · three-layer AC-25 | **have** |
| TP-FOLDER-BACKUP-15 | remove-project-sudoers: force remove draft; refuse `/etc`; already absent; host elev probe | test_domain | three-layer §2.3.3b · project-sudoers-file | **have** |
| TP-FOLDER-BACKUP-15b | multi-draft: list + non-interactive requires path; explicit path removes one only | test_domain | three-layer AC-15 · L-SUDOERS-04 | **have** |
| TP-FOLDER-BACKUP-16 | restore dest whitelist: refuse `/etc/passwd` + exact `/etc` + `/etc/<other>`; W-ETC-USER `/etc/{{username}}` gate allow | test_domain | **folder-archive-backup** §2.6b.2a · INC-20260812-001 | **have** |
| TP-FOLDER-BACKUP-17 | total retention: after deposit, prune oldest until ≤30 per basename | test_domain | **retention-total** | **have** |
| TP-FOLDER-BACKUP-17b | total retention: no cross-basename delete | test_domain | **retention-total** | **have** |
| TP-FOLDER-BACKUP-17c | failed backup does not prune prior total archives | test_domain | **retention-total** AC-5 | **have** |
| TP-FOLDER-BACKUP-18 | daily retention: same-day prune lowest N until ≤5 | test_domain | **retention-daily** | **have** |
| TP-FOLDER-BACKUP-18b | daily retention: does not delete other days / other basename | test_domain | **retention-daily** | **have** |
| TP-FOLDER-BACKUP-18c | failed backup does not prune prior same-day archives | test_domain | **retention-daily** AC-5 | **have** |

---

## Privilege / sudoers coverage map (reviewer quick ref)

| Behavior | TP | Law |
|----------|----|-----|
| User detection for fragment = `id -un` | implicit (fragment User lines in 01/02/14) | three-layer · skill SK-CREATE-SUDOERS-FILE |
| Trust tier test_local refuse without allow | 01b | §2.3.1a · **S13** |
| TEST MODE banner + uninstall soon | 01, 02 | §2.3.3 |
| Project-sudoers-file draft write | 02, 14 | term project-sudoers-file |
| Admin install script (no Type 0 `/etc`) | 14 | §2.3.3a |
| Remove draft only | 15 | §2.3.3b |
| Deposit fail-closed | 05 | §2.3.7 |
| Elev Tables S11–S12 | n/a automated (agent/harness) | mold + checklist; product OS-tool deposit |
| JSON emit identity (no OS-tool / path hardcode) | 22 / 22b / 22c / 22d | **sudoer-json-file** AC-1..7 |
| Pretty emit + real sibling convert/submit keeps both verbs | **22e** | **sudoer-json-file** AC-9 · three-layer AC-21 · **JR-3/JR-4** |
| Stub inbound **body** still has both verbs | **22f** | AC-9 · **JR-6** (not file-count only) |
| Independent generate dest (compact + readable) | **24 / 24d** | three-layer AC-23/24 · **JR-9** · **S16** |
| Operator-readable inbound-fidelity error | **25 / 25b / 25c** | operator-readable-error AC-1..3 · **L-OUTPUT-01** |
| Review gate JSON re-encode | n/a automated | `what-to-review` **JR-1..9** · **S15** / **S16** · INC-20260817-001 |

---

## Optional / host-only (not Core CI blockers)

| Item | Status | Notes |
|------|--------|--------|
| Admin script `install` on live host | optional | Requires sudo account; suite only checks root gate |
| Global install → production trust tier | optional | Host: `sudo sh src/folder-backup install` then print-sudoers without allow |
| Fragment drift vs installed `/etc/sudoers.d` | optional | Security review host gate |

---

## Rules

1. Closing a **bug** finding updates the matching TP to **have**.  
2. Do not mark TP **have** without a suite assertion (or honest skip/n/a).  
3. Do not reintroduce online TP-CURL/TP-CSUM as Core without product-mode change.  
4. Trust-tier and project-sudoers-file changes require TP-FOLDER-BACKUP-01b/14/15 (or successors) stay **have**.  
5. JSON grant / submit reviews require **TP-FOLDER-BACKUP-22e/22f** stay **have**. Do not mark re-encode fidelity **have** from emit-only 22/22b/22c or stub-`cp` 20.  
6. Closing INC-20260817-001 host queue still needs a live inbound that lists both verbs (product/suite ≠ approved host file).  
