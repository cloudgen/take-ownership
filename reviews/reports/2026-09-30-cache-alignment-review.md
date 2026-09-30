# Product review: take-ownership (cache folder)

**Date:** 2026-09-30  
**Reviewer:** implement pass (user ordered review, align, fix, docs, commit, push)  
**Product:** take-ownership `VERSION=3.0.1`  
**Ship unit:** `./take-ownership` (`src/take-ownership` is a symlink)  
**Scope:** cache folder and persistence, specialized from the sibling remover’s current storage contract. Product facts stay in this tree. The sibling tree was read only.  
**Method:** disk read of the storage requirement, ship unit, and CLI tests; `sh -n ./take-ownership`; `./tests/run.sh`  
**Baseline:** `./tests/run.sh` → PASS=348 FAIL=0 SKIP=1 (TP-CURL-09 optional public-network proof)

## Summary

The cache folder is now one leaf per login and per process, with a silent skip when a higher tier cannot be created. `about` names the folder that was used, the preferred folder, and this host’s fallbacks. Persistence is the fixed directory `~/.local/take-ownership`. Findings TO-STOR-01 through TO-STOR-05 are fixed in this run. World-writable parent directories under the ram drive and `/tmp` stay a watch item (L-STOR-01).

## Strengths

| Area | Notes |
|------|--------|
| Host chains | Linux, Git Bash, and macOS each have an explicit preferred path and fallbacks. Git Bash has no second fallback. |
| Isolation | The leaf is mode 0700. The directory name carries the login and the process id. Scratch names inside the leaf do not use `$$`. |
| Silence | A missed tier does not warn. Failure is loud only when every tier fails. |
| Proof | TP-CLI-06, TP-CLI-12, and TP-CLI-18 stay, and TP-CACHE-01, TP-CACHE-02, and TP-CACHE-03 cover the new contract. |
| Persistence | One resolver. The path is not the install bin and not the cache folder. |

## Findings

### TO-STOR-01 — Severity: P1 (high)

- **Area:** cache isolation
- **Status:** fixed
- **Location:** `util_resolve_storage` in `./take-ownership`; `requirement-shell-cli-storage.md` 2.1.1
- **Description:** The previous leaf was one shared `cache-${APP_NAME}` directory. Concurrent runs shared scratch, and the path did not name the login or the process.
- **Impact:** One login’s scratch was visible to later runs, and a ram-drive project shape was easy to confuse with the cache parent.
- **Suggestion:** Keep the per-login, per-process leaf. Do not restore a single shared leaf.
- **Cross-ref:** L-STOR-01 · TP-CLI-12 · TP-CACHE-02

### TO-STOR-02 — Severity: P2 (medium)

- **Area:** about labels
- **Status:** fixed
- **Location:** `app_about`
- **Description:** Human output used Storage (effective) / Storage (fallback). JSON used a retired persist key. A skipped preferred tier was not shown beside the folder that was actually used.
- **Impact:** Operators could not see which tier ran, and a warning on a normal skip looked like a fault.
- **Suggestion:** Keep the used / preferred / 1st fallback / 2nd fallback labels, and omit the 2nd line when the host has none.
- **Cross-ref:** TP-CLI-06 · TP-CACHE-01 · TP-CACHE-02

### TO-STOR-03 — Severity: P2 (medium)

- **Area:** scratch maker
- **Status:** fixed
- **Location:** `util_mktemp`, `util_mktemp_dir`
- **Description:** Scratch creation assumed `mktemp` existed. A host without that program could not stay inside the cache folder.
- **Impact:** Domain temps would fail or land outside the resolved root.
- **Suggestion:** Keep the absent-maker file (mode 0600) and directory (mode 0700) under the cache leaf, and keep the `$$` name refusal.
- **Cross-ref:** TP-CACHE-03

### TO-STOR-04 — Severity: P3 (low)

- **Area:** law mold
- **Status:** fixed
- **Location:** portable storage mold on disk (untracked; not in this commit)
- **Description:** The local mold lagged the sibling mold that describes an absent temp maker as a child of the resolved root.
- **Impact:** The next specialization could copy a looser mold. Product law 2.1.1 is the tighter contract for this product.
- **Suggestion:** Leave the mold untracked. Do not force-add it.
- **Cross-ref:** requirement-shell-cli-storage 2.1.1

### TO-STOR-05 — Severity: P1 (high)

- **Area:** grant path list
- **Status:** fixed
- **Location:** `to_list_grant_paths`, `to_emit_allowed_folders`, `to_sudoers_verify_sibling_convert`
- **Description:** Those functions return data on stdout and then remove a scratch file. A remover that prints a finished-remove line on stdout appended that sentence to the path list. The first suite run recorded two extra action lines (expected 2, actual 4, then 5).
- **Impact:** A generated grant could name a remover sentence as a `--path`.
- **Suggestion:** Keep scratch removal off the data stdout.
- **Cross-ref:** TP-TAKE-OWNERSHIP-33 · TP-TAKE-OWNERSHIP-33b

## Non-findings (explicitly OK)

| Check | Result |
|-------|--------|
| `sh -n ./take-ownership` | Pass |
| `./tests/run.sh` | PASS=348 FAIL=0 SKIP=1 |
| Preferred leaf is not `/dev/shm/${APP_NAME}` or `/dev/shm/${APP_NAME}-${login}` | Pass (TP-CLI-12, TP-CACHE-02) |
| Persistence is not `~/.local/bin` | Pass (TP-CLI-18, TP-CACHE-02) |
| `XDG_CACHE_HOME` is not the chain | Pass (no remaining reference in the ship unit) |
| Operator-readable cache failure | N/A for the happy path (silent skip). The all-tiers-fail line is `Cannot create cache folder` and exits 1. |
| Sibling tree | Read only. Not modified. |
| Law mold | Aligned on disk. Stays untracked. |

## Priority remediation order

1. TO-STOR-01 and TO-STOR-05 — done this run.
2. TO-STOR-02 and TO-STOR-03 — done this run.
3. TO-STOR-04 — mold aligned locally; do not version it.
4. Watch: parent directories `/dev/shm/cache` and `/tmp/cache` are mode 1777 when this program creates them. The leaf stays 0700.

## Related

| Artifact | Role |
|----------|------|
| `docs/requirements/requirement-shell-cli-storage.md` | Product law 2.1.1 |
| `docs/requirements/requirement-project-folder.md` | Path table 3.0.1 |
| `tests/test_cli.sh` | TP-CLI-06 / 12 / 18 and TP-CACHE-01..03 |
| `reviews/lessons.md` | L-STOR-01 |
| `README.md`, `CHANGELOG.md`, `SECURITY.md` | Version 3.0.1 |

**Written by:** implement pass, 2026-09-30  
**Review status:** closed this run (no open P0/P1)
