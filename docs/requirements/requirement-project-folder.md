**file**: docs/requirements/requirement-project-folder.md  
**Status**: Active (Version 2.1.0)  
**Area**: architecture  
**Key**: `requirement-project-folder`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

Define **project folder structure** and path ownership for the take-ownership CLI: source layout, install locations, scratch, and config drafts.

**Critical distinction:** CLI tool own paths vs target folders whose ownership is taken vs host `/etc/sudoers.d` (admin only).

### 1.1 Human-facing

**In one sentence:** The program lives under `src/`, installs into your bin or `/usr/local/bin`, and writes grant drafts under your config dir — it does not write `/etc`.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | User-bin install; config drafts | `${HOME}/.local/bin/take-ownership` |
| Admin / root | Global install | `/usr/local/bin/take-ownership` |
| Not this file | Recursive chown of a named folder | `requirement-take-ownership-ops` |

| Includes | Excludes |
|----------|----------|
| `src/`, bin paths, config drafts | `/var/backup` deposit (retired) |
| Per-user scratch | Type 0 write of `/etc` |

| Surface | What you open | What for |
|---------|---------------|----------|
| `src/take-ownership` | ship unit | live program |
| `${HOME}/.config/take-ownership/` | drafts | generate/print |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Place the program globally | Production grant path | `sudo sh src/take-ownership install` |

---

## 2. Core Rules (Mandatory)

### 2.1 Workspace source layout (developer tree)

| Path | Role |
|------|------|
| `src/take-ownership` | **Ship unit** — single POSIX shell executable source |
| `tests/` | CLI tests when present |
| `docs/requirements/` | Product law (this surface) |
| Product root README / CHANGELOG / LICENSE / SECURITY | Product user docs when specialized |

1. **MUST** keep the installable CLI under **`src/`** (not only repo root).  
2. **MUST** install the binary under a privilege-correct bin path (see §2.2).  
3. **MUST NOT** require online channel files (companion digest) for local install.

### 2.2 CLI tool install locations

| Mode | Binary path | Default |
|------|-------------|---------|
| **Per-user (normal)** | `${USER_BIN}/${APP_NAME}` | `${HOME}/.local/bin/take-ownership` |
| **Global (root)** | `${GLOBAL_BIN}/${APP_NAME}` | `/usr/local/bin/take-ownership` |

Rules:

1. Non-root **install** **MUST** target user bin.  
2. Root **install** **MUST** (for production elevation) target global bin.  
3. **Primary product story:** user bin for Type 0 day-to-day **without** sudoers; **global bin is required** before generate/submit (`requirement-three-layer-privilege-model`).  
4. Uninstall **MUST** remove only the managed binary path for the install mode used.  
5. Managed binary mode **MUST** be **`0755`** after install (see `requirement-shell-local-self-management` §2.3.1).

### 2.3 Scratch / cache / persist (CLI own paths)

| Purpose | Pattern |
|---------|---------|
| Preferred cache | `/dev/shm/cache/cache-take-ownership` (`requirement-shell-cli-storage`) |
| Fallback cache | `${XDG_CACHE_HOME}/cache-take-ownership` |
| Live cache root | From `util_resolve_storage` |
| Persistence storage | `${HOME}/.local/take-ownership` (`util_resolve_persist`) |
| Temps | `util_mktemp` under the cache root |
| Sudoers fragment draft | `${HOME}/.config/take-ownership/sudoers.fragment-<user>` |
| JSON grant draft | `${HOME}/.config/take-ownership/sudoer-request-<user>.json` |

Rules:

1. Preferred cache **MUST** be `/dev/shm/cache/cache-${APP_NAME}` — **MUST NOT** `/dev/shm/${APP_NAME}` or `/dev/shm/${APP_NAME}-${USERNAME}` (those look like ram-drive project folders).  
2. Fallback **MUST** be under this login’s XDG cache as `cache-${APP_NAME}`.  
3. Persistence **MUST** be `${HOME}/.local/${APP_NAME}` — **MUST NOT** `${HOME}/.local/bin` (that is `USER_BIN`).  
4. Temps **MUST** clean up (`trap`) after success/failure of an `action` run.  
5. **MUST NOT** auto-write `/etc/sudoers.d`.  
6. **No** durable `/var/backup` deposit on this product.

### 2.4 Target folders being taken

1. `--path` is a **user-supplied absolute directory** (ops operand), not an app system-user tree.  
2. Validation (exists, directory, not symlink, refuse-list) is **`requirement-take-ownership-ops`**.  
3. This file does **not** own chown semantics.

### 2.5 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **APP_NAME** | `take-ownership` |
| **Ship unit path** | `src/take-ownership` |
| **USER_BIN default** | `${HOME}/.local/bin` |
| **GLOBAL_BIN default** | `/usr/local/bin` |
| **Config dir** | `${HOME}/.config/take-ownership/` |
| **Persistence storage** | `${HOME}/.local/take-ownership/` |
| **No Type 2 app data tree** | No dedicated system app user |
| **No BACKUP_ROOT** | Retired with folder-backup domain |

### 2.6 Why This Requirement Exists (CIAO)

- **Principle 1 – Caution**: Separate install, drafts, and target folders.  
- **Principle 10 – Least privilege**: Global bin for elevation; Type 0 never writes `/etc`.  
- **Principle 11 – Temps**: Scratch is cleanup, not museum.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: Fail loud if global bin is missing when emitting grants.  
- **Intentional**: Path classes are documented and not mixed.  
- **Anti-fragile**: Per-user isolation under multi-user hosts.  
- **Over-protect**: Do not “simplify” by elevating USER_BIN.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Move the ship unit out of `src/` without updating this requirement and install paths.  
2. Make online channel paths required for install.  
3. Grant the product unrestricted write under `/var` or `/etc`.  
4. Treat `${USER_BIN}/take-ownership` as the production sudoers path.  
5. Restore `/var/backup` as a product deposit root without a new requirement.

**Violating this rule is a critical path/privilege regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Ship unit lives at `src/take-ownership` |
| AC-2 | Default user install path is `${HOME}/.local/bin/take-ownership` |
| AC-3 | Production elevation path is `/usr/local/bin/take-ownership` |
| AC-4 | No `/var/backup` product deposit |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-local-self-management` | Place/remove binary |
| `requirement-shell-cli-storage` | Cache + persist resolve |
| `requirement-domain-take-ownership` | Domain surface |
| `requirement-three-layer-privilege-model` | Elevation boundary |
| `docs/requirements/index.md` | Registry |

---

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active 1.0.0 | folder-backup layout + `/var/backup` |
| 2026-08-25 | Active 2.0.0 | take-ownership; drop backup deposit |
| 2026-08-30 | Active 2.0.1 | Preferred cache `/dev/shm/cache/cache-${APP_NAME}` |
| 2026-08-30 | Active 2.1.0 | Persistence storage `${HOME}/.local/${APP_NAME}/` |

---

**Last Updated**: 2026-08-30  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
