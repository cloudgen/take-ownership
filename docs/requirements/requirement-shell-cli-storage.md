**file**: docs/requirements/requirement-shell-cli-storage.md  
**Status**: Active (Version 2.0.0)  
**Area**: shell  
**Key**: `requirement-shell-cli-storage`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for **shell CLI storage** of take-ownership. Storage means **both** of these families:

| Family | Role | Default path |
|--------|------|----------------|
| **Cache folder** | Volatile scratch (mktemp, grant convert scratch) | Preferred `/dev/shm/cache/cache-${APP_NAME}` |
| **Persistence storage** | Durable per-user app data | `${HOME}/.local/${APP_NAME}/` |

Used for temps and durable app-owned files. This product has **no** `/var/backup` deposit.

The preferred cache is **not** a ram-drive **project** tree (`/dev/shm/<project>`). It lives under `/dev/shm/cache/` so `about` and the filesystem do not look like a take-ownership workspace.

Persistence is **not** the user bin (`${HOME}/.local/bin`) and **not** config drafts (`${HOME}/.config/${APP_NAME}/` — those stay on privilege / JSON peers).

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Storage is two families

1. **MUST** treat **storage** as **cache folder + persistence storage**.  
2. **MUST NOT** collapse persist into cache, or cache into persist.  
3. **MUST NOT** use persist as `TMPDIR`.  
4. **MUST NOT** use cache for durable app data.  
5. **MUST NOT** use `${HOME}/.local/bin` as persist (that is `USER_BIN`).  
6. Config drafts (`sudoers.fragment-<user>`, `sudoer-request-<user>.json`) **MUST** remain under `${HOME}/.config/${APP_NAME}/` unless those peer requirements change.

| Family | Authoritative helper | Env (live) |
|--------|----------------------|------------|
| Cache folder | `util_resolve_storage` | `EFFECTIVE_STORAGE_DIR` / `TMPDIR` / `STORAGE_DIR` (fallback) |
| Persistence storage | `util_resolve_persist` | `PERSIST_DIR` |

### 2.2 Cache resolver SSOT

1. **MUST** keep **one** authoritative cache-resolve helper: **`util_resolve_storage`**.  
2. New code that needs a product scratch/cache **root** **MUST** call `util_resolve_storage` (or `mktemp` under a path it returned).  
3. Resolver **MUST** print the chosen directory path on **stdout** for `$(util_resolve_storage)` capture.  
4. User-visible failure about cache **MUST** use Output SSOT.

Preferred and fallback **path shapes** **MUST** be `util_preferred_cache_dir` and `util_fallback_cache_dir` (or the same literals those helpers print).

### 2.3 Cache live resolve priority

First match that can be created **and** is writable:

| Order | Condition | Path shape |
|-------|-----------|------------|
| 1 (preferred) | `/dev/shm` exists and is writable | `/dev/shm/cache/cache-${APP_NAME}` |
| 2 | `/tmp` is writable | `/tmp/cache/cache-${APP_NAME}` |
| 3 (fallback) | User cache | `STORAGE_DIR` (`${XDG_CACHE_HOME:-${HOME}/.cache}/cache-${APP_NAME}`, env-overridable) |

**Parent:** for shm/tmp tiers the resolver **MUST** create `/dev/shm/cache` or `/tmp/cache` (prefer mode **1777** when creating) so other logins can add sibling `cache-<app>` directories.

**Create before return:** for the **chosen** leaf, the resolver **MUST** `mkdir -p` it, confirm it is **writable**, then print the path. If create/write fails → try the next tier. If none work → **MUST** fail closed. **MUST NOT** return a path without creating it.

**MUST NOT** use these as cache:

| Forbidden cache path | Why |
|----------------------|-----|
| `/dev/shm/${APP_NAME}` | Looks like a ram-drive project folder |
| `/dev/shm/${APP_NAME}-${USERNAME}` | Same confusion; username in the shm leaf is withdrawn |
| `/dev/shm` or `/tmp` as a dump | No app-named cache leaf |
| `${HOME}/.local/${APP_NAME}` | That is persistence storage, not cache |

### 2.4 Cache isolation

1. Cache leaves **MUST** include **`cache-${APP_NAME}`** (app identity).  
2. Preferred shm path **MUST NOT** include `${USERNAME}` (that made the dest look like a ram-drive login folder). Isolation is: sticky `…/cache/` parent + this login’s leaf (if another owner holds the leaf, fall through) + fallback under this login’s `$HOME`.  
3. **MUST NOT** use a single shared world-writable directory for all apps.  
4. Live product **MUST** export `TMPDIR=${EFFECTIVE_STORAGE_DIR}` so `mktemp` inherits the isolated **cache** root.  
5. New scratch files **MUST** be created via **`util_mktemp`** (or `mktemp` under a path `util_resolve_storage` returned).  
6. **MUST NOT** use predictable `$$` names (forbidden: `/tmp/${APP_NAME}.$$`, `${EFFECTIVE_STORAGE_DIR}/${APP_NAME}.$$`).

**Complete `util_mktemp` sample:**

```sh
util_mktemp() {
    : "${APP_NAME:=take-ownership}"
    : "${EFFECTIVE_STORAGE_DIR:=}"
    _suffix="${1:-tmp}"
    case "${_suffix}" in
        *\$\$*) out_die "util_mktemp: refuse predictable \$\$ name template" ;;
    esac
    if [ -z "${EFFECTIVE_STORAGE_DIR}" ]; then
        EFFECTIVE_STORAGE_DIR=$(util_resolve_storage)
        export EFFECTIVE_STORAGE_DIR
    fi
    mktemp "${EFFECTIVE_STORAGE_DIR}/${APP_NAME}.${_suffix}.XXXXXX" \
        || mktemp
}
```

### 2.5 Persistence storage SSOT

1. **MUST** keep **one** authoritative persist-resolve helper: **`util_resolve_persist`**.  
2. Default path **MUST** be **`${HOME}/.local/${APP_NAME}`** (trailing directory, not the `bin` sibling file). Env **`PERSIST_DIR`** may override the path; the resolver still **MUST** create it.  
3. Path shape **MUST** be `util_persist_dir` (or the same literal that helper prints).  
4. Resolver **MUST** `mkdir -p` the leaf, confirm it is **writable**, then print the path on **stdout** for `$(util_resolve_persist)` capture.  
5. Prefer mode **0700** on the persist **leaf** (do **not** chmod `${HOME}/.local`).  
6. If create/write fails → **MUST** fail closed. **MUST NOT** return a path without creating it.  
7. User-visible failure about persist **MUST** use Output SSOT.

**MUST NOT** use these as persistence storage:

| Forbidden persist path | Why |
|------------------------|-----|
| `${HOME}/.local/bin` or `${USER_BIN}` | User-bin install path |
| `${USER_BIN}/${APP_NAME}` | Managed binary file |
| `/dev/shm/…` or `/tmp/cache/…` | Cache / volatile |
| `/var/backup` | Retired deposit |
| `${HOME}/.config/${APP_NAME}` | Config drafts (peer SSOT) |

### 2.6 Persistence isolation

1. Persist **MUST** live under this login’s `$HOME` (or an explicit `PERSIST_DIR` override that this login can create).  
2. **MUST NOT** share one world-writable persist directory for all apps or all users.  
3. Live product **MUST** export `PERSIST_DIR` after resolve.  
4. New durable app-owned files (not config drafts, not the binary, not temps) **MUST** be created under `PERSIST_DIR`.  
5. **MUST NOT** export `TMPDIR=${PERSIST_DIR}`.

### 2.7 Wire and diagnostics

| Surface | Requirement |
|---------|-------------|
| `app_main` | Resolve **both** early: `EFFECTIVE_STORAGE_DIR=$(util_resolve_storage)`; `PERSIST_DIR=$(util_resolve_persist)`; export `EFFECTIVE_STORAGE_DIR`, `STORAGE_DIR`, `TMPDIR` (cache), `PERSIST_DIR` |
| `app_about` human | **MUST** print **`Cache folder (preferred):`** then `/dev/shm/cache/cache-${APP_NAME}`; **MUST** print **`Cache folder (fallback):`** then the XDG `cache-${APP_NAME}` path; **MUST** print **`Persistence storage:`** then `${HOME}/.local/${APP_NAME}` (live `PERSIST_DIR`). **MUST NOT** label cache lines **Storage (effective)** or **Storage (fallback)** |
| `app_about` JSON | **MUST** include `cache_preferred`, `cache_fallback`, live cache root as `effective_storage` (plus `storage_dir` = cache fallback), and live persist as `persist_dir`. **MUST NOT** include `CHECKSUM` |
| Domain `action` | Temps under effective **cache**; clean up on exit |

### 2.8 Temp rules for take-ownership

1. Create temps under `EFFECTIVE_STORAGE_DIR` via `util_mktemp`.  
2. Use restrictive modes appropriate for user data (prefer not world-readable when content may be sensitive).  
3. **MUST** remove temps via `trap` on success and failure of `action` / grant-emit.  
4. This product has **no** durable `/var/backup` deposit root.

### 2.9 Implementation Notes (this project)

| Item | Live value |
|------|------------|
| **Product / binary** | `take-ownership` |
| **Cache resolver** | `util_resolve_storage` in `src/take-ownership` |
| **Preferred cache** | `/dev/shm/cache/cache-take-ownership` |
| **Fallback cache** | `${XDG_CACHE_HOME}/cache-take-ownership` |
| **Persist resolver** | `util_resolve_persist` in `src/take-ownership` |
| **Persistence storage** | `${HOME}/.local/take-ownership` |
| **Call sites** | `app_main`, `app_about`, domain temps (cache) |
| **Not used for** | Durable `/var/backup` (retired); ram-drive project dests; `USER_BIN`; config drafts |

### 2.10 Why This Requirement Exists (CIAO)

- **Caution:** Multi-user isolation without looking like a project tree on tmpfs; persist stays under this login’s home, not in cache.  
- **Intentional:** Storage means cache **and** persist; about says **cache folder** and **persistence storage**.  
- **Anti-fragile:** Missing `/dev/shm` still works for scratch; persist create fail-closed.  
- **Principle 11 – Temps:** Cleanup, not museum copies of staging.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- Volatile cache first, user cache last for scratch.  
- Persist is durable and home-scoped; cache is throwaway.  
- Isolation before convenience.  
- Create fail-closed in both resolvers.  
- Cache path family is distinct from ram-drive **project** folders and from `${HOME}/.local/${APP_NAME}`.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Restore `/dev/shm/${APP_NAME}` or `/dev/shm/${APP_NAME}-${USERNAME}` as the preferred cache.  
2. Label about cache lines **Storage (effective)** / **Storage (fallback)** instead of **Cache folder (preferred)** / **Cache folder (fallback)**.  
3. Drop **Persistence storage** / `persist_dir` from about, or treat persist as optional commentary.  
4. Point persist at `${HOME}/.local/bin`, cache, `/dev/shm`, or `/var/backup`.  
5. Export persist as `TMPDIR` or write temps into persist.  
6. Replace either fallback/create chain with a shared world-writable dump.  
7. Scatter hard-coded `/tmp/take-ownership` roots outside the cache resolver.  
8. Leave either resolver dead with no call sites while claiming storage is product law.  
9. Echo a tier/persist path without creating it.  
10. Use predictable `$$` scratch names instead of `util_mktemp` / `mktemp` XXXXXX.

**Violating this rule is a critical storage isolation / honesty regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Exactly one authoritative cache resolver creates and returns the cache root |
| AC-2 | Preferred cache leaf is `/dev/shm/cache/cache-${APP_NAME}` when shm is usable |
| AC-3 | `app_main` sets `EFFECTIVE_STORAGE_DIR` / `TMPDIR` (cache) and `PERSIST_DIR` early |
| AC-4 | `about` human uses Cache folder (preferred)/(fallback) plus Persistence storage; JSON has `cache_preferred` / `cache_fallback` / `persist_dir` |
| AC-5 | Scratch files use `util_mktemp` / `mktemp` XXXXXX; no `$$` names |
| AC-6 | Live cache path is not `/dev/shm/${APP_NAME}-${USERNAME}` |
| AC-7 | Exactly one persist resolver creates `${HOME}/.local/${APP_NAME}` (or `PERSIST_DIR` override) |
| AC-8 | Persist path is not `USER_BIN` and not the live cache root |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-project-folder` | Path classes (bin, config drafts, cache, persist) |
| `requirement-domain-take-ownership` | Staging use |
| `requirement-shell-cli-interface` | About fields |
| `requirement-shell-local-self-management` | `USER_BIN` is not persist |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-CLI-06** | `tests/test_cli.sh` | **have** — about JSON cache + persist fields + human labels |
| **TP-CLI-12** | same | **have** — preferred cache `/dev/shm/cache/cache-${APP_NAME}`; live dir exists; not APP-USERNAME shape |
| **TP-CLI-18** | same | **have** — persist `${HOME}/.local/${APP_NAME}` exists; not USER_BIN; not cache |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active | Storage resolve for take-ownership staging |
| 2026-08-15 | Active | `util_mktemp` sample; forbid `$$` scratch names |
| 2026-08-30 | Active 1.1.0 | Preferred `/dev/shm/cache/cache-${APP_NAME}`; about Cache folder labels |
| 2026-08-30 | Active 2.0.0 | Storage = cache folder **and** persistence `${HOME}/.local/${APP_NAME}/` |

---

**Last Updated**: 2026-08-30  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
