# Requirement ↔ test matrix — folder-backup

**Updated:** 2026-09-03 (take-ownership 2.7.0; folder-backup rows are lineage)  
**Product VERSION:** 2.7.0  
**Suite:** `tests/run.sh` (PASS=266 FAIL=0 SKIP=0)

| Requirement key | Area | TP families | Coverage notes |
|-----------------|------|-------------|----------------|
| requirement-class-software-dev | class | TP-CLI-01, TP-CLI-11 | Syntax + stack residual; no online package |
| requirement-bootstrap-chain | architecture | TP-CLI-04, TP-CLI-10 | Online surface absent |
| requirement-project-folder | architecture | TP-LC-01, TP-FOLDER-BACKUP-06 | src ship unit; deposit path naming |
| requirement-three-layer-privilege-model | architecture | TP-FOLDER-BACKUP-01, **01b**, 01c, 02, 05, **14**, **15**, **15b**, **19**, **20**, **21**, **21b**, **22e**, **23**, **23b**, **23c**, **24**, **24b**, **24c**, **24d**, **26**, **26b** | Trust tiers **S13**; submit workflow AC-16–22; independent generate AC-23/24; inbound fidelity; host-probe add/update; other-user dest ignored; **backup \*** emit AC-25 |
| requirement-sudoer-json-file | architecture | TP-TAKE-OWNERSHIP-**20**, **21**, **22**, **24**, **27**, **27b**, **28**, **28b**, **31**, **33**, **33b**, **34** | JSON grant is `take-ownership` `action --path F --ownership user:group` plus `--json` twin; never `"*"`; dirty cwd keeps `user:group`; globbed/`*` submit fail-closed; text dual `user\:group`; one folder per line |
| requirement-incorrect-ownership-parameter | architecture | TP-TAKE-OWNERSHIP-**29**, **29b**, **29c**, **27**, **28**, **28b**, **31** | Fence: generate/action refuse `*`; missing `--ownership` fail-closed; gold JSON is `user:group`; globbed inbound fail-closed |
| requirement-take-ownership-ops | domain-ops | TP-TAKE-OWNERSHIP-**11b**, **16**, **17**, **40**, **41**, **42**, **43**, **44** | Recursive chown; ram-drive exception; list-folders gate; TTY numbered pick + current `user:group`; **TP-44 todo** — granted-but-missing dir is not a live pick (INC-20260830-001) |
| requirement-folder-archive-backup | backup | TP-FOLDER-BACKUP-03..08, 10..13, **16** | Source/name/deposit/verify/next-N/**restore** + dest whitelist W-ETC-USER (ops SSOT) |
| requirement-folder-archive-backup-retention-total | backup | TP-FOLDER-BACKUP-17, 17b, **17c** | Max **30** per basename; oldest-first prune; failed backup does not prune |
| requirement-folder-archive-backup-retention-daily | backup | TP-FOLDER-BACKUP-18, 18b, **18c** | Max **5** per basename per day; lowest-`N` same-day prune; failed backup does not prune |
| requirement-shell-cli-interface | shell | TP-CLI-* | Commands, flags, dispatch (five sudoers verbs live; `sudoers` unknown); **menu/main** TP-CLI-13..16; test-purpose `generate-sudoer-json` apart (**TP-CLI-17**) |
| requirement-shell-cli-zero-arguments | shell | TP-CLI-07, **13**, **15** | Type N never install; empty argv → `app_main_menu` (TTY list / off-TTY help) |
| requirement-shell-cli-default-interaction | shell | TP-CLI-07, **13**, **14**, **15**, **16**, **19** | Case 3 empty argv + `menu`/`main`; family **sudoers** + submenu; default CLI main menu style; version/about/self-managed/test-purpose omitted |
| requirement-shell-local-self-management | shell | TP-LC-* (incl. **09/10** mode) | install/uninstall/where-is-me; **0755** multi-user; global preferred for elev |
| requirement-shell-output-requirements | shell | TP-CLI-03,05,08,09, **19** | JSON / quiet / errors; identity token + numbered-row ink |
| requirement-operator-readable-error | shell | TP-FOLDER-BACKUP-**25**, **25b**, **25c** · TP-TAKE-OWNERSHIP-**44** (todo) | Operator-facing `[ERROR]` wording (what happened / next step / no jargon-only); missing-dir copy must name recreate-then-action when grant already exists |
| requirement-shell-modular-function-design | shell | (indirect) | `fb_print_sudoers*`, `fb_remove_project_sudoers`, deposit/restore |
| requirement-shell-idempotency | shell | TP-LC-03,07 · TP-FOLDER-BACKUP-06,08 | Re-install; next-N |
| requirement-shell-interactive-vs-noninteractive | shell | TP-LC-05 · TP-FOLDER-BACKUP-15 · **15b** | Uninstall / remove-project-sudoers confirm; multi-draft non-interactive path required |
| requirement-shell-cli-storage | shell | TP-CLI-**06**, **12**, **18** | Cache `/dev/shm/cache/cache-${APP_NAME}` + persist `${HOME}/.local/${APP_NAME}`; about Cache folder + Persistence storage |
| requirement-domain-folder-backup | domain | TP-FOLDER-BACKUP-01,02,09,14,15,19,20,**21**,**21b**,**23**,**23b**,**24** · TP-CLI-04,06 | Surface verbs/help/about; submit public inbound; generate-sudoer-request; host-probe add/update |

**Checklist / mold (harness, not product suite):** **S11–S12** elev tables (when claimed); **S13** trust tier; **S14** emit; **S15** convert/inbound; **S16** independent generate dest — agent path `SK-CREATE-SUDOERS-FILE` / `CL-CREATE-SUDOERS-SECURITY`. Operator errors: `SK-OPERATOR-READABLE-ERROR` / `CL-OPERATOR-READABLE-ERROR`.

**Absent by design (no TP Core):** online-install, remote self-management, automatic channel checksum.
