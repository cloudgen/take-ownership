**file**: docs/requirements/requirement-take-ownership-ops.md  
**Status**: Active (Version 1.0.0)  
**Area**: domain-ops  
**Key**: `requirement-take-ownership-ops`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **product Single Source of Truth** for **taking Unix ownership of a named folder**: collect `--path` and `--ownership`, validate, then recursively change owner and group **without following symlinks**.

It is **not** the domain four-pillar file (`requirement-domain-take-ownership`). Elevation and sudoers **files** live in `requirement-three-layer-privilege-model`. The JSON grant body lives in `requirement-sudoer-json-file`. In-tool `sudo` wrapping lives in `requirement-shell-sudo-command`.

### 1.1 Human-facing

**In one sentence:** You name a folder and a `user:group`; the program recursively gives that folder to that owner — it does not walk through symbolic links.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Run `action` with both switches | `take-ownership action --path /var/www/html --ownership www-data:www-data` |
| The computer (after grant) | Passwordless re-exec of the **global** binary | `sudo -n /usr/local/bin/take-ownership action --path /var/www/html --ownership www-data:www-data` |
| Not this file | How the grant is queued | `requirement-three-layer-privilege-model` |

| Includes | Excludes |
|----------|----------|
| Recursive `chown` of the directory tree | Following symlinks (`-L` / `-H`) |
| Fail closed on missing user/group or refuse-list paths | Backup, tar, `/var/backup` |
| Idempotent success when already matching | Granting `/bin/chown` in sudoers |

| Surface | What you open | What for |
|---------|---------------|----------|
| `take-ownership action` | command | live take-ownership |
| `take-ownership help` | command | operand reminder |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Take a web root | The tree becomes `www-data:www-data` | `take-ownership action --path /var/www/html --ownership www-data:www-data` |
| Miss a switch on a real terminal | The program asks **one field at a time** | answer folder, then `user:group` |
| Miss a switch in a pipe | Fail closed; no hang | `take-ownership action --path /var/www/html` → error |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Invocation shape (sacred)

Canonical argv (also the sudoers match):

```text
take-ownership action --path <folder> --ownership <user:group>
take-ownership --json action --path <folder> --ownership <user:group>
```

| Rule | Detail |
|------|--------|
| **Verb** | `action` only for this ops path |
| **Long flags only** | `--path` and `--ownership`. **MUST NOT** accept `-p` / `-o` on this verb (sudoers would miss) |
| **Order** | `--path` **then** `--ownership`. Swapped order **MUST** fail closed (same reason) |
| **Absolute path** | `--path` **MUST** be an absolute directory path. Relative paths fail closed |
| **Trailing slash** | Strip a single trailing `/` except for path `/` (which is refused anyway) |
| **Ownership grammar** | Exactly `user:group` (one colon, both sides non-empty). `user`, `user:`, `:group` fail closed |

Global `--json` / `--quiet` / `--debug` / `--force` stay on `requirement-shell-cli-interface`. `--json` **MUST** appear **before** `action` when used (matches the grant twin).

### 2.2 Guided input (Question 12b — both)

When **interactive** (`TTY=1`) and a field is missing, **MUST** prompt **one field at a time** (`prompt_ask`):

| Field | Secret? | Prompt label | Default | Skip-if |
|-------|---------|--------------|---------|---------|
| `path` | no | Folder whose ownership to take (absolute path) | none | `--path` already set |
| `ownership` | no | Unix user:group for the new owner (example `www-data:www-data`) | none | `--ownership` already set |

Intention: the operator is not forced to assemble the flag list from memory.

When **non-interactive** (`TTY=0`, `--json`, pipes, CI) and a field is missing: **MUST** fail closed with operator-readable usage. **MUST NOT** hang.

### 2.3 Path validation (fail closed)

Before any chown:

1. `--path` exists and is a **directory**.  
2. `--path` is **not** a symbolic link (fail closed; do not chown the target through a link).  
3. `--path` has no `..` component after normalization.  
4. `--path` is **not** in the closed refuse list (prefix match on the normalized path):

| Refused | Why |
|---------|-----|
| `/` `/boot` `/bin` `/sbin` `/usr` `/etc` `/lib` `/lib64` `/proc` `/sys` `/dev` `/run` `/root` | Host system trees |

5. When `realpath` (or equivalent) is available, the **physical** path **MUST** also fail the same refuse list.  
6. **MUST NOT** follow directory symlinks while walking (`chown -R` without `-L` / `-H`; physical walk).

### 2.4 Owner validation (fail closed)

1. User **MUST** exist on the host (`id -u <user>` or `getent passwd`).  
2. Group **MUST** exist on the host (`getent group` or `id -g` equivalent).  
3. Any existing host user:group is allowed (including not-self and service accounts such as `www-data:www-data`, including `root:root`).  
4. Missing user or group → fail closed; do not create accounts.

### 2.5 Recursion and idempotency

1. Take-ownership **MUST** apply to the directory inode **and** its contents (recursive).  
2. **MUST NOT** follow symlinks (chown the symlink inode if the tool chowns links; **MUST NOT** chown the link target).  
3. If every walked inode already has the requested owner and group → **success no-op** (idempotent).  
4. Partial failure (unreadable child, I/O error) → **non-zero**; do not claim success.  
5. `--force` does **not** bypass refuse-list, symlink, or missing-identity checks.

### 2.6 Privilege split

| Who | What |
|-----|------|
| You (unprivileged) | Parse flags, guided input, validate path/owner **without** changing inodes that need root |
| Already root (`id -u` = 0) | Run recursive chown **directly** (no `sudo`) |
| Not root | Re-exec **`sudo -n ${GLOBAL_BIN}/take-ownership action --path <folder> --ownership <user:group>`** (same order). **MUST NOT** `sudo /bin/chown` |
| Missing grant / sudo | Fail closed; operator-readable next step: `generate-sudoer-request --path <folder>` then `submit-sudoer-request` |

In-tool `sudo` **MUST** go through `requirement-shell-sudo-command` (`util_sudo`). Already-root **MUST NOT** wrap `sudo`.

The unprivileged process **MUST** invoke the **global** path `${GLOBAL_BIN}/take-ownership`, never `${USER_BIN}/take-ownership` and never `$0` when `$0` is user-writable.

Operator **MAY** type `sudo take-ownership action --path … --ownership …` themselves; that is the same grant.

### 2.7 What this is not

| Not | Owner / note |
|-----|----------------|
| Sudoers JSON body | `requirement-sudoer-json-file` |
| Submit / generate workflow | `requirement-three-layer-privilege-model` |
| Archive backup | **Absent** (retired with folder-backup domain) |
| OS-tool sudoers `chown` lines | **Forbidden** |

### 2.8 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `take-ownership` |
| **Handler** | `to_action` |
| **Chown implementation** | POSIX `chown -R` **without** `-L`/`-H` (or equivalent walk that does not follow links) |
| **GLOBAL_BIN** | `/usr/local/bin` |
| **Worked path** | `/var/www/html` |
| **Worked ownership** | `www-data:www-data` |
| **Worked refuse** | `/etc`, `/usr` |
| **Domain prefix** | `to_` |

### 2.9 Why This Requirement Exists (CIAO)

- **Principle 10 – Least privilege**: Elevate the product binary for one folder, not `/bin/chown` on `*`.  
- **Principle 1 – Caution**: Refuse system roots and symlink follow.  
- **Principle 16 – Interactive vs non-interactive**: TTY walk; pipes never hang.  
- **Principle 3 – Anti-fragile**: Idempotent when already matching.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Fail closed on bad path/owner; never follow links into a grant hole.  
- **Intentional:** One verb, two long flags, fixed order — sudoers can match.  
- **Anti-fragile:** Already-matching owner is success.  
- **Over-protect:** No short flags; no USER_BIN re-exec; no OS-tool sudoers.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Put `/bin/chown` (or `chown`) in the sudoers grant.  
2. Follow symlinks (`chown -R -L` or equivalent).  
3. Accept relative `--path` or `-p`/`-o` short flags.  
4. Re-exec `${USER_BIN}/take-ownership` or a user-writable `$0`.  
5. Hang in CI waiting for `--path` / `--ownership`.  
6. Treat refuse-list paths as “the user asked for it.”  
7. Claim success when any walked inode failed.  
8. Restore backup/restore as this file’s job.

**Violating this rule is a critical ownership / privilege regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Canonical argv is `action --path F --ownership U:G` |
| AC-2 | Recursive chown; no symlink follow |
| AC-3 | Missing user/group / missing dir / refuse-list → fail closed |
| AC-4 | Already matching → success no-op |
| AC-5 | Non-root re-execs **global** binary via `sudo -n`; already-root does not sudo |
| AC-6 | TTY missing fields → one-at-a-time prompts; non-TTY missing fields → fail, no hang |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-domain-take-ownership` | Verb catalog / help / about |
| `requirement-three-layer-privilege-model` | Elevation workflow |
| `requirement-sudoer-json-file` | Grant argv shape |
| `requirement-shell-sudo-command` | `util_sudo` / check before sudo |
| `requirement-shell-interactive-vs-noninteractive` | TTY / no hang |
| `requirement-operator-readable-error` | Fatal copy |
| `docs/requirements/index.md` | Registry |
| `./src/take-ownership` | Implementation under test |

---

## Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-TAKE-OWNERSHIP-10** | `tests/test_domain_take_ownership.sh` | **todo** — recursive chown, no follow |
| **TP-TAKE-OWNERSHIP-11** | same | **todo** — refuse `/etc` and symlink `--path` |
| **TP-TAKE-OWNERSHIP-12** | same | **todo** — missing owner:group fail closed |
| **TP-TAKE-OWNERSHIP-13** | same | **todo** — already matching is success |
| **TP-TAKE-OWNERSHIP-14** | same | **todo** — non-TTY missing flag does not hang |
| **TP-TAKE-OWNERSHIP-15** | same | **todo** — swapped flag order fail closed |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-25 | Active 1.0.0 | Ops SSOT for take-ownership; replaces folder-archive-backup on this product |

---

**Last Updated**: 2026-08-25  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
