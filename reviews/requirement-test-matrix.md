# Requirement ↔ test matrix — take-ownership

**Updated:** 2026-10-14  
**Product VERSION:** 3.3.0  
**Suite:** `tests/run.sh` on 2026-10-14 — **PASS=517 FAIL=0 SKIP=1** (TP-CURL-09 optional online; menu **5 / 6 / 7** **TP-CLI-13** · **TP-CLI-32**; return **TP-TAKE-OWNERSHIP-47..52**)

| Requirement key | Area | TP families | Coverage notes |
|-----------------|------|-------------|----------------|
| requirement-class-software-dev | class | TP-CLI-01, TP-CLI-11 | Syntax + stack residual |
| requirement-bootstrap-chain | architecture | TP-CLI-04, TP-CLI-10 | Online surface absent; backup/restore unknown |
| requirement-project-folder | architecture | TP-LC-01 | src ship unit |
| requirement-three-layer-privilege-model | architecture | TP-TAKE-OWNERSHIP-**03**, **20**, **24**, **30**, **31**, **32**, **51** | Global-only grant; return lines have no `--ownership`; no `/etc` write; print-sudoers text dual |
| requirement-sudoer-json-file | architecture | TP-TAKE-OWNERSHIP-**20**, **21**, **22**, **24**, **27**, **27b**, **28**, **28b**, **31**, **33**, **33b**, **34**, **51** | Four objects per folder: `action` plus `--json` twin, and `return-original-owner --path` plus `--json` twin; never `"*"` |
| requirement-incorrect-ownership-parameter | architecture | TP-TAKE-OWNERSHIP-**29**, **29b**, **29c**, **27**, **28**, **28b**, **31**, **50**, **52** | Fence: generate/action refuse `*`; return refuses `--ownership`; a bad saved line is not applied |
| requirement-take-ownership-ops | domain-ops | TP-TAKE-OWNERSHIP-**11**, **11b**, **13**, **14**, **15**, **16**, **17**, **40**, **41**, **42**, **43**, **44**, **47**, **48**, **49**, **50**, **52** | Recursive chown; saved directory owner; return; ram-drive exception; list-folders gate |
| requirement-shell-cli-interface | shell | TP-CLI-* | Commands, flags, dispatch; **menu/main** TP-CLI-13..16 and **32**; `language` is not dispatched; test-purpose `generate-sudoer-json` apart (**TP-CLI-17**) |
| requirement-shell-cli-zero-arguments | shell | TP-CLI-07, **13**, **15** | TTY menu; off-TTY Type O install-ensure |
| requirement-shell-cli-default-interaction | shell | TP-CLI-07, **13**, **14**, **15**, **16**, **19**, **21–26**, **32** | Front **1 / 2 / 5 / 6 / 7 / 9**; sudoers **51–55**; self-management **61–66**; language **71–83**; **0** Back |
| requirement-shell-cli-language | shell | TP-CLI-**13**, **32** | Thirteen codes; front **2** and **5**; leaf shorts `action` and `return-original-owner` stay English; human help and about; JSON stays English |
| requirement-shell-local-self-management | shell | TP-LC-* (incl. **09/10** mode) | install/uninstall/where-is-me; **0755** |
| requirement-shell-output-requirements | shell | TP-CLI-03,05,08,09, **19** | JSON / quiet / errors |
| requirement-operator-readable-error | shell | TP-TAKE-OWNERSHIP-**28**, **44** | Operator-facing `[ERROR]`; granted-missing recreate |
| requirement-shell-modular-function-design | shell | (indirect) | `to_*` domain prefix |
| requirement-shell-idempotency | shell | TP-LC-03,07 · TP-TAKE-OWNERSHIP-13, **48**, **50** | Re-install; already-matching action and return; a trusted saved line stays |
| requirement-shell-interactive-vs-noninteractive | shell | TP-LC-05 · TP-TAKE-OWNERSHIP-14, **42**, **43** | Uninstall confirm; TTY `action` |
| requirement-shell-cli-storage | shell | TP-CLI-**06**, **12**, **18**, **32** · TP-CACHE-**01**, **02**, **03** | Per-login per-process cache; silent miss; fixed persistence path; `language` leaf is not cache |
| requirement-domain-take-ownership | domain | TP-CLI-04 · TP-TAKE-OWNERSHIP-20, **40**, **50** | Surface verbs/help/about; `return-original-owner` |
| requirement-shell-script-coding | shell | TP-CLI-01 | POSIX `/bin/sh` |
| requirement-shell-sudo-command | shell | TP-TAKE-OWNERSHIP-13, **50** · TP-CLI-20 | `util_sudo`; return re-exec has no `--ownership`; command line for normal user only |

**Superseded (not live law, no Core TP):** `requirement-domain-folder-backup`, `requirement-folder-archive-backup`, retention-total, retention-daily.

**Absent by design (no TP Core):** backup/restore, `--allow-test-local`. `return-original-owner` is one saved directory `user:group` applied to the tree. It is not restore. Online `curl | sh` is **TP-CURL-*** (public network stays **TP-CURL-09** skip unless opted in).
