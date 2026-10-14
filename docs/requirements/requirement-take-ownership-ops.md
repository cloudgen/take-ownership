**file**: docs/requirements/requirement-take-ownership-ops.md  
**Status**: Active (Version 1.6.0)  
**Area**: domain-ops  
**Key**: `requirement-take-ownership-ops`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **product Single Source of Truth** for **taking Unix ownership of a named folder**: collect `--path` and `--ownership`, validate, then recursively change owner and group **without following symlinks**.

It is **not** the domain four-pillar file (`requirement-domain-take-ownership`). Elevation and sudoers **files** live in `requirement-three-layer-privilege-model`. The JSON grant body lives in `requirement-sudoer-json-file`. In-tool `sudo` wrapping lives in `requirement-shell-sudo-command`.

### 1.1 Human-facing

**In one sentence:** You name a folder and a `user:group`; the program recursively gives that folder to that owner, and can later put it back to the saved original owner — it does not walk through symbolic links.

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
| Put it back | The tree becomes the saved `user:group` | `take-ownership --json return-original-owner --path /var/www/html` |
| Miss `--path` on a real terminal | Numbered list of allowed folders plus **0** Back. A bad number stays on the list. **0** leaves the list without an error | `1`, or `0` |
| Miss `--ownership` on a real terminal | Uses this login’s `user:group` (`id -un`:`id -gn`); **no prompt** | (none) |
| Miss a switch in a pipe | Stop; no hang | `take-ownership action --path /var/www/html` → error |
| Granted folder gone (ram-drive wiped) | Recreate the folder, then `action` — do not write a new grant | recreate the directory, then `take-ownership action --path …` |

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
| **Absolute path** | `--path` **MUST** be **one** absolute **directory** (recursive contents are **not** extra sudoers args). Relative paths and **files** fail closed |
| **Trailing slash** | Strip a single trailing `/` except for path `/` (which is refused anyway) |
| **Ownership grammar** | Exactly `user:group` (one colon, both sides non-empty). `user`, `user:`, `:group` fail closed |

Global `--json` / `--quiet` / `--debug` / `--force` stay on `requirement-shell-cli-interface`. `--json` **MUST** appear **before** `action` when used (matches the grant twin).

### 2.2 Guided input (Question 12b — both)

When **interactive** (`TTY=1`, not `--json`) and a field is missing:

| Field | MUST | MUST NOT |
|-------|------|----------|
| `path` | Print a **numbered list** of this login’s **existing** allowed folders, then **0** Back, and accept a **number** (or an exact listed live path). **0** / `back` / `q` / an empty line / EOF leaves the picker and returns success to the caller (the menu shows the front board again). An unknown token warns, names the token, and reprints the list. Empty live set → fail closed; if the grant still names a missing directory, next step is recreate-then-action (not generate) | Number a granted path that is not an existing directory; ask for a free-typed absolute path; hang; `out_die` on **0** or on an unknown token |
| `ownership` | Use this login’s current `user:group` (`id -un`:`id -gn`, or `SUDO_USER` after re-exec) with **no prompt** | Ask for `user:group`; use `*` |

Skip-if: `--path` / `--ownership` already set (including explicit flags and sudo re-exec argv).

When **non-interactive** (`TTY=0`, `--json`, pipes, CI) and a field is missing: **MUST** fail closed with operator-readable usage. **MUST NOT** hang. **MUST NOT** default ownership.

### 2.3 Path validation (fail closed)

Before any chown:

1. `--path` exists and is a **directory**.  
2. `--path` is **not** a symbolic link (fail closed; do not chown the target through a link).  
3. `--path` has no `..` component after normalization.  
4. `--path` is **not** in the closed refuse list (prefix match on the normalized path):

| Refused | Why |
|---------|-----|
| `/` `/boot` `/bin` `/sbin` `/usr` `/etc` `/lib` `/lib64` `/proc` `/sys` `/dev` `/run` `/root` | Host system trees |
| `/dev/shm` (the mount root, exact) | Whole tmpfs — not a project folder |

**Ram-drive exception (sacred):** `--path` **MAY** be a project tree under **`/dev/shm/<project-basename>`** (and children of that folder). That path family is a **workspace root**, not a device node. **MUST still refuse** `/dev`, `/dev/shm` (the mount root), and other `/dev/*` that are **not** under `/dev/shm/<name>/`. Typical dest: `/dev/shm/genesis-template`.

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
5. `--force` does **not** bypass refuse-list, symlink, missing-identity, or allowed-folder checks.

### 2.5a Allowed folders (list-folders + action gate)

**Shared set:** folders this login may take ownership of. **`list-folders`** prints that set. **`action` MUST** confirm `--path` is in that set **before** any chown or already-matching success.

| Rule | Detail |
|------|--------|
| **Verb** | `list-folders` (no `--path`; Type 0; does not write `/etc`; does not chown) |
| **Subject** | Current login (`id -un`). After `sudo` re-exec, use `SUDO_USER` when euid is 0 |
| **Union sources** | Readable JSON grant `~/.config/take-ownership/sudoer-request-<user>.json`; readable sudoers draft `sudoers.fragment-<user>` (and unsuffixed legacy); readable installed fragment; `sudo -n -l` lines that name this program (only when `SUDOERS_D_DIR` is `/etc/sudoers.d`, so tests can isolate) |
| **Values** | Absolute `--path` tokens only (same normalize as `action`: strip trailing `/`, refuse `*`) |
| **Empty set** | `list-folders` exits 0 and says there are no folders. `action` **MUST** fail closed |
| **Granted but missing** | `list-folders` **MAY** still print the path, **marked missing**. TTY `action` pick **MUST NOT** number it. `action --path` **MUST** fail closed; next step is **recreate the folder, then `action`** — **MUST NOT** name `generate-sudoer-request` as the next command (INC-20260830-001) |
| **Not in set** | `action` **MUST** fail closed; next step `list-folders` or `generate-sudoer-request --path <folder> --ownership <user:group>` |
| **Exact match** | Grant folder is exact (not a parent prefix). `/var/www` does **not** authorize `/var/www/html` |
| **JSON** | `list-folders --json` reports `user`, `count`, `folders` (array) |

This gate is **in addition to** sudoers exact-argv at re-exec. Type 0 lists from artifacts this login can read so the operator sees the same set `action` and `return-original-owner` will accept.

### 2.5b Saved original owner (`return-original-owner`)

`return-original-owner` puts the folder back to **one** saved `user:group`. It is **not** backup or restore of file bytes, and it is **not** a per-inode journal. A mixed tree becomes that one pair.

**Record path:** `/var/take-ownership/original-owner/<sha256>`. The digest is SHA-256 of the normalized absolute path bytes with **no** added newline. The file name is 64 lowercase hex characters. Missing `sha256sum` fails closed.

**Record content:** one line `user:group` and a newline. The pair is the **directory inode** owner and group, observed **before** this `action` changes the tree. Return applies that pair with the same recursive walk as `action` (no `-L` / `-H`).

**When `action` writes** (after the allowed-folder gate, before already-matching success and before chown):

| Record file | What happens |
|-------------|----------------|
| Trusted regular file already there | Leave it. Do not replace it |
| Missing | Write the directory's current `user:group` |
| Present but not trusted (symlink, wrong owner, group or world writable, or not one valid `user:group` line when read) | Fail closed. Do not chown. Do not replace the file |

**Directory trust:** Root may create `/var/take-ownership` and `original-owner` only, mode **0755**, owner root, not a symlink, not group or world writable. **MUST NOT** change the mode of any other parent. The record file is mode **0644**, a regular file, not a symlink, not group or world writable, and root-owned when the writer is root. A new file is linked into place so an existing name is not replaced.

**Test directory:** `TO_ORIGINAL_OWNER_DIR` may name another absolute directory. A non-root process may use it only when it is not the default path, already exists, is owned by this login, is not a symlink, and is not group or world writable. Root requires that directory to be root-owned. In-tool `sudo` does not keep the caller's environment, so a production elevation uses `/var/take-ownership/original-owner`. An unprivileged `action` that cannot use the directory does not write it; the elevated re-exec records before it chowns.

**Return argv:**

```text
take-ownership return-original-owner --path <folder>
take-ownership --json return-original-owner --path <folder>
```

| Rule | Detail |
|------|--------|
| **No `--ownership`** | If the operator passed `--ownership`, fail closed. A leftover owner from an earlier menu `action` is not that flag |
| **Path checks** | Same absolute path, refuse-list, symlink, directory, and `list-folders` gate as `action` |
| **TTY** | Missing `--path` uses the same numbered folder list and **0** Back |
| **Read** | A missing file fails closed and names `action` as the next step. A file that is not trusted fails closed and is not replaced |
| **Already that owner** | Success no-op |
| **Not root** | Re-exec `sudo -n ${GLOBAL_BIN}/take-ownership return-original-owner --path <folder>` (and the `--json` form). **MUST NOT** `sudo /bin/chown` |

Menu front row **2** runs this verb. Help lists it. The dispatcher routes it.

### 2.6 Privilege split

| Who | What |
|-----|------|
| You (unprivileged) | Parse flags, guided input, validate path/owner **without** changing inodes that need root |
| Already root (`id -u` = 0) | Run recursive chown **directly** (no `sudo`) |
| Not root | Re-exec **`sudo -n ${GLOBAL_BIN}/take-ownership action --path <folder> --ownership <user:group>`** (same order), or **`sudo -n ${GLOBAL_BIN}/take-ownership return-original-owner --path <folder>`**. **MUST NOT** `sudo /bin/chown` |
| Missing grant / sudo | Fail closed; operator-readable next step: `generate-sudoer-request --path <folder> --ownership <user:group>` then `submit-sudoer-request` |

In-tool `sudo` **MUST** go through `requirement-shell-sudo-command` (`util_sudo`). Already-root **MUST NOT** wrap `sudo`.

The unprivileged process **MUST** invoke the **global** path `${GLOBAL_BIN}/take-ownership`, never `${USER_BIN}/take-ownership` and never `$0` when `$0` is user-writable.

Operator **MAY** type `sudo take-ownership action --path … --ownership …` themselves; that is the same grant.

### 2.7 What this is not

| Not | Owner / note |
|-----|----------------|
| Sudoers JSON body | `requirement-sudoer-json-file` |
| Submit / generate workflow | `requirement-three-layer-privilege-model` |
| Archive backup or per-file restore | **Absent.** `return-original-owner` is one saved directory `user:group`, applied recursively |
| OS-tool sudoers `chown` lines | **Forbidden** |

### 2.8 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `take-ownership` |
| **Handler** | `to_action` · `to_return_original_owner` · `to_list_folders` |
| **Original-owner directory** | `/var/take-ownership/original-owner` (`TO_ORIGINAL_OWNER_DIR` for a trusted test directory) |
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
- **Intentional:** `action` has two long flags in a fixed order. `return-original-owner` has `--path` only. Sudoers can match both.  
- **Anti-fragile:** Already-matching owner is success.  
- **Over-protect:** No short flags; no USER_BIN re-exec; no OS-tool sudoers.

## Under command line for normal user only

When this program runs on Termux, Git Bash, or Windows Command Prompt, it **MUST** stay on **your own login**. Admin privilege and a dedicated system account are **unused**.

| MUST | MUST NOT |
|------|----------|
| `action` as this login when you already own the tree | In-tool `sudo` / write `/etc` |
| Fail closed if the folder needs an admin grant | Recommend `sudo curl \| sh` |

Detect (typical): Termux — `PREFIX` contains `com.termux`, `TERMUX_VERSION` set, or `/data/data/com.termux/files/usr` exists. Git Bash — `MSYSTEM` is `MINGW*` / `MSYS*`. Windows cmd — `OS=Windows_NT` after excluding Git Bash / WSL.

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
9. Run `action` without confirming `--path` against the `list-folders` set.  
10. Treat a parent directory grant as covering a child path.  
11. Put `--ownership` on `return-original-owner`.  
12. Replace a saved original-owner file that is already there.  
13. Chown when that file is missing on return, or when it is not a trusted regular file.  
14. Change the mode of `/var` or any parent other than `/var/take-ownership`.

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
| AC-6 | TTY missing `--path` → numbered **existing** allowed-folder list; TTY missing `--ownership` → current `user:group` with no prompt; non-TTY missing fields → fail, no hang |
| AC-7 | `/dev/shm/<project>` ram-drive trees are **not** refuse-list; `/dev` and `/dev/shm` (mount root) **are** |
| AC-8 | `list-folders` prints this login’s allowed `--path` set (empty set is success with a next step); granted-missing paths are marked, not omitted from the grant list |
| AC-9 | `action` fails closed when `--path` is missing from that set, including already-matching trees |
| AC-10 | Granted `--path` that is not an existing directory is not a live TTY pick; `action --path` names recreate-then-action and **MUST NOT** name `generate-sudoer-request` |
| AC-11 | TTY folder picker prints **0** Back; **0** / `q` leaves without `[ERROR]`; an unknown token reprints the list and does not exit |
| AC-12 | The first `action` that can write the record stores the directory inode `user:group` before chown. A later `action` does not replace a trusted file |
| AC-13 | A symlink or group/world-writable record fails closed and is not replaced |
| AC-14 | `return-original-owner --path F` reads that line and succeeds when the tree already has it. `--ownership` on that verb fails closed |
| AC-15 | A missing record fails closed and names `action` as the next step |
| AC-16 | Return is not backup or restore of bytes, and not a per-file owner journal |

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
| **TP-TAKE-OWNERSHIP-11** | `tests/test_domain_take_ownership.sh` | **have** — refuse `/etc` and symlink `--path` |
| **TP-TAKE-OWNERSHIP-12** | same | **have** — missing owner:group fail closed |
| **TP-TAKE-OWNERSHIP-13** | same | **have** — already matching is success |
| **TP-TAKE-OWNERSHIP-14** | same | **have** — non-TTY missing flag does not hang |
| **TP-TAKE-OWNERSHIP-15** | same | **have** — swapped flag order fail closed |
| **TP-TAKE-OWNERSHIP-42** | same | **have** — TTY `action` without `--path` prints numbered allowed folders |
| **TP-TAKE-OWNERSHIP-43** | same | **have** — TTY pick uses current `user:group` with no ownership prompt |
| **TP-TAKE-OWNERSHIP-44** | same | **have** — granted-missing dir is not a live pick; recreate-then-action |
| **TP-TAKE-OWNERSHIP-45** | same | **have** — TTY picker **0** Back; unknown token reprints; menu **1** then **0** returns to the front board |
| **TP-TAKE-OWNERSHIP-46** | same | **have** — multi-draft remove list **0** Back; unknown token reprints |
| **TP-TAKE-OWNERSHIP-47** | same | **have** — first `action` writes the directory `user:group` |
| **TP-TAKE-OWNERSHIP-48** | same | **have** — a trusted record is not replaced |
| **TP-TAKE-OWNERSHIP-49** | same | **have** — return with no record fails closed |
| **TP-TAKE-OWNERSHIP-50** | same | **have** — return uses the saved line and refuses `--ownership` |
| **TP-TAKE-OWNERSHIP-52** | same | **have** — symlink or group-writable record fails closed |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-25 | Active 1.0.0 | Ops SSOT for take-ownership; replaces folder-archive-backup on this product |
| 2026-08-30 | Active 1.3.0 | Interactive `action`: numbered allowed-folder pick; current `user:group` with no prompt |
| 2026-09-06 | Active 1.4.0 | Granted-missing dir is not a live TTY pick; recreate-then-action (INC-20260830-001) |
| 2026-09-30 | Active 1.5.0 | TTY folder picker prints **0** Back. Back and an unknown token do not exit. **TP-TAKE-OWNERSHIP-45** / **46** |
| 2026-10-14 | Active 1.6.0 | `return-original-owner` reads one saved directory `user:group`. The first recording `action` writes it and does not replace it later. Not backup or restore |

---

**Last Updated**: 2026-10-14  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
