# What to review — take-ownership

**Living checklist** (review plan). Product: **take-ownership** local self-managed CLI + recursive folder ownership + narrow sudo grant.  
**Class:** software-development · domain SSOT present · online `curl | sh` install (live since 3.0.0).  
**Always load first:** `reviews/lessons.md`

**Last plan update:** 2026-09-30  
**Ship unit VERSION:** 3.0.2  
**Suite baseline:** see `reviews/test-plan.md`

---

## Pre-flight

| # | Check | Notes |
|---|--------|--------|
| P1 | Read `docs/requirements/index.md` | Class + architecture + shell + domain + three-layer |
| P2 | Confirm ship unit `src/take-ownership` | `APP_NAME` / `VERSION` hard-assign |
| P3 | Load `reviews/lessons.md` and re-check every open L-* | Mandatory (esp. **L-SUDOERS-02** · **L-OPS-01** · **L-MAP-01** · **L-OUTPUT-01**) |
| P4 | Run `./tests/run.sh` | Record PASS/FAIL/SKIP; **TP-TAKE-OWNERSHIP-*** (not folder-backup backup/restore) |
| P5 | Confirm install **channel** is online `curl \| sh` | Config `SCRIPT_URL` + companion digest; local HTTP proof is **TP-CURL-*** |
| P6 | Privilege law | three-layer global-only; sudoer-json `action --path` `--ownership user:group`; operator-readable-error |
| P7 | Host elev posture (if reviewing runtime) | Global vs local binary; `/etc/sudoers.d/take-ownership-<user>` |
| P8 | **JSON grant / inbound fidelity** | `action --path F --ownership user:group` plus `--json` twin; never `"*"` |
| P9 | **Host fragment → submit update** | This user’s `/etc/sudoers.d` dest present → default **update** |
| P10 | **Independent generate dest** | `generate-sudoer-request` writes a dest tests/review can `cat` without sudo |
| P11 | **Operator-readable errors** | Blocking `[ERROR]` has what-happened + next step; granted-missing dir names recreate-then-action |
| P12 | **README people-and-folders voice** | No Type-N lead; no backup/restore leftover; live main-menu capture after install |

---

## Product law surfaces

| Surface | Path | Review focus |
|---------|------|--------------|
| Class | `requirement-class-software-dev.md` | posix-sh |
| Bootstrap chain | `requirement-bootstrap-chain.md` | A0=cli-template → A1=folder-backup → B take-ownership |
| Project folder | `requirement-project-folder.md` | `src/`, bins; **no** `/var/backup` |
| **Privilege / sudoers** | `requirement-three-layer-privilege-model.md` | Global-only grant; no `--allow-test-local`; print-sudoers; install-script; generate/submit |
| **JSON sudoer file** | `requirement-sudoer-json-file.md` | `action --path F --ownership user:group` plus `--json` twin; never `"*"` |
| **Incorrect ownership** | `requirement-incorrect-ownership-parameter.md` | no `*`; no cwd listings |
| **Operator-readable error** | `requirement-operator-readable-error.md` | Blocking `[ERROR]` what-happened + next step; granted-missing recreate |
| CLI interface | `requirement-shell-cli-interface.md` | Commands, flags; five sudoers verbs live; `sudoers` unknown |
| Default interaction | `requirement-shell-cli-default-interaction.md` | Front **1 / 7 / 8 / 9**; sudoers **71–75**; self-management **81–86**; **0** Back |
| Empty argv | `requirement-shell-cli-zero-arguments.md` | TTY menu; off-TTY Type O install-ensure |
| Local self-management | `requirement-shell-local-self-management.md` | install/uninstall; **0755**; global preferred for elev |
| Output | `requirement-shell-output-requirements.md` | `out_*`; JSON errors |
| Modular design | `requirement-shell-modular-function-design.md` | `to_*` domain prefix |
| Idempotency | `requirement-shell-idempotency.md` | Re-install; already-matching `action` |
| Interactive modes | `requirement-shell-interactive-vs-noninteractive.md` | Uninstall / TTY `action` walk |
| CLI storage | `requirement-shell-cli-storage.md` | Per-login per-process cache; silent tier miss; fixed persistence path |
| Domain | `requirement-domain-take-ownership.md` | Four pillars; ops deferred |
| Ops | `requirement-take-ownership-ops.md` | Recursive chown; TTY live pick; granted-missing |

**Intentionally absent (do not “restore” without owner order):** backup/restore, `--allow-test-local`. Online `curl | sh` and the companion digest are live (3.0.0).

---

## High-risk paths (ship unit)

| Path / symbol | Risk | Lesson / TP |
|--------------|------|-------------|
| Empty argv branch | Parent empty-argv install leak | L-TYPE-N-01 · TP-CLI-07 |
| Online command names | Half-live channel | L-ONLINE-01 · TP-CLI-04/10 |
| `inst_local_uninstall` | Fake success without force | L-UNIN-01 · TP-LC-05 |
| `inst_local_install` | Mode `0711` (non-owners cannot run shell unit) | L-INST-MODE-01 · TP-LC-09/10 |
| `to_print_sudoers` | Broad sudoers; write `/etc`; local=production | L-SUDOERS-01/02 · TP-TAKE-OWNERSHIP-03/30/31 |
| `to_action` TTY pick | Numbers a granted path that is not a directory | L-OPS-01 · TP-TAKE-OWNERSHIP-44 |
| `util_resolve_storage` / `util_resolve_persistent_storage` | Shared leaf, silent-miss warning, or persist override | L-STOR-01 · TP-CLI-06 · TP-CLI-12 · TP-CLI-18 · TP-CACHE-01..03 |
| Config `HOME` under `set -u` | nounset crash | L-SETU-01 · TP-CLI-11 |

---

## Tests surface

| Check | Path |
|-------|------|
| Suite entry | `tests/run.sh` |
| CLI | `tests/test_cli.sh` |
| Local lifecycle | `tests/test_local_lifecycle.sh` |
| Domain + privilege | `tests/test_domain_take_ownership.sh` |
| TP map | `reviews/test-plan.md` |
| REQ ↔ TP matrix | `reviews/requirement-test-matrix.md` |

---

## Product user docs

| Check | Path |
|-------|------|
| README install + sudoers handoff honesty | `README.md` |
| SECURITY global-only; no folder-backup leftover | `SECURITY.md` |
| CHANGELOG current VERSION | `CHANGELOG.md` |

---

## Explicit non-goals for default review

- Treating the live `curl | sh` channel or companion digest as absent (both shipped in 3.0.0)
- Backup / restore / `/var/backup`  
- Auto-writing `/etc/sudoers.d` from a normal login  
- `--allow-test-local` / USER_BIN in sudoers  
