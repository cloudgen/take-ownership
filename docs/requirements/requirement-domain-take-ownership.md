**file**: docs/requirements/requirement-domain-take-ownership.md  
**Status**: Active (Version 1.2.0)  
**Area**: domain  
**Key**: `requirement-domain-take-ownership`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **domain surface Single Source of Truth** for take-ownership: which **specialized CLI verbs** exist, what **help** and **about** must show, and how domain routing is labeled.

**Operational chown behavior** (validate path, recursive take-ownership, fail-closed matrix) is **not** owned here — it is owned by **`requirement-take-ownership-ops`**.  
**Elevation and sudoers files** (emit / install / submit **workflow**, global-only grant path) are owned by **`requirement-three-layer-privilege-model`**.  
**JSON sudoer file body** (grant = **`take-ownership` only**; exact folder; any `user:group`) is owned by **`requirement-sudoer-json-file`**.

This file is the sole Active **`requirement-domain-*`** (four pillars). It **supersedes** `requirement-domain-folder-backup`.

Must-not-confuse: JSON field **`action`** means add vs update of a grant. CLI verb **`action`** means take ownership now.

### 1.1 Human-facing

**In one sentence:** You submit a grant for one folder; after an admin installs it, `take-ownership action --path <folder> --ownership user:group` recursively takes that folder’s ownership.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Generate and submit the grant; then run `action` | `take-ownership generate-sudoer-request --path /var/www/html` |
| Admin / sibling dest | Install the grant under `/etc/sudoers.d/` | sibling `sudoer-cli` approve, or admin script |
| Not this file | How `chown` walks the tree | `requirement-take-ownership-ops` |

| Includes | Excludes |
|----------|----------|
| Verb catalog, help, about | Backup / restore / `/var/backup` |
| Grant-emit listed apart from live work | Online install; dest approval inside this CLI |

| Surface | What you open | What for |
|---------|---------------|----------|
| `./src/take-ownership` | ship unit | live dispatch |
| `take-ownership help` | command | listed verbs |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Bind a folder into a grant you can read | Independent generate; no `/etc` write | `take-ownership generate-sudoer-request --path /var/www/html` |
| Take ownership after the grant is installed | Immediate recursive chown of that folder | `take-ownership action --path /var/www/html --ownership www-data:www-data` |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Pillar A — Specialized CLI subcommands

| Command | Operands / flags | Handler prefix | Behavior summary | Behavior SSOT |
|---------|------------------|----------------|------------------|---------------|
| `list-folders` | none | `to_*` | List folders this login may take ownership of (union of `--path` values from this login’s grant artifacts). Type 0; no `/etc` write | **`requirement-take-ownership-ops`** |
| `action` | `--path <folder>` **then** `--ownership <user:group>` (long flags only; that order) | `to_*` | Take ownership immediately (recursive chown; no symlink follow). **MUST** confirm `--path` is on the `list-folders` set first | **`requirement-take-ownership-ops`** |
| `print-sudoers` | optional output path; **`--path <folder>` required** | `to_*` | Emit **project-sudoers-file** (draft; no `/etc` write). **Fails closed** unless `${GLOBAL_BIN}/take-ownership` exists | **`requirement-three-layer-privilege-model`** |
| `print-sudoers-install-script` | optional script path; same `--path` and global-bin gate | `to_*` | Admin handoff script under `/dev/shm` or temp | **`requirement-three-layer-privilege-model`** |
| `remove-project-sudoers` | optional path; `--force` | `to_*` | Remove **project-sudoers-file** draft only (not `/etc`) | **`requirement-three-layer-privilege-model`** |
| `generate-sudoer-request` | **`--path <folder>` required**; optional dest path; `--update` / `--add` | `to_*` | Independent JSON grant to a dest **readable without sudo**. **Fails closed** unless global binary exists. No `/etc`; no inbound | workflow: **`requirement-three-layer-privilege-model`** · JSON body: **`requirement-sudoer-json-file`** |
| `generate-sudoer-json` | same as `generate-sudoer-request` | `to_*` | **Test-purpose alias** of generate-sudoer-request. Canonical JSON for tests: `--ownership` stays `*` (not a cwd listing) | same |
| `submit-sudoer-request` | **`--path <folder>`** when emitting; optional sudoers file; `--purpose`; `--update` / `--add` | `to_*` | Type 0 submitter into sibling public inbound. **Fails closed** unless global binary exists. Default **update** if this user’s host fragment exists, else add | workflow: **`requirement-three-layer-privilege-model`** · JSON body: **`requirement-sudoer-json-file`** |

**Purpose (this product):** `print-sudoers`, `print-sudoers-install-script`, `generate-sudoer-request`, and `generate-sudoer-json` are **test-purpose**. `list-folders`, `action`, `remove-project-sudoers`, and `submit-sudoer-request` are **operational**. Test-purpose verbs stay on `help` under a heading **apart** from operational work and **MUST NOT** appear on the numbered main menu (`requirement-shell-cli-default-interaction`).

**Routing:** Dispatcher in `app_main` **MUST** route these verbs; unknown operands fail closed.

**Reserved tokens:** `help`, `install`, `uninstall`, `where-is-me`, `version`, `about`, `menu`, `main`, and the grant verbs above. A bare path as argv0 after flags **MUST NOT** be treated as `action` (use the `action` verb).

**Non-goals as subcommands:** backup, restore, retention, remote sync, schedule daemon, dest approve/reject.

### 2.2 Pillar B — Specialized features (surface map only)

| Feature area | Domain role | Full law |
|--------------|-------------|----------|
| List grant folders | Expose `list-folders` | `requirement-take-ownership-ops` |
| Take ownership of a folder | Expose `action` verb + `--path` / `--ownership`; confirm against `list-folders` | `requirement-take-ownership-ops` |
| Elevated chown | Product uses a Type 1 re-exec of the **global** binary | `requirement-three-layer-privilege-model` + ops REQ |
| Sudoers draft print | Expose `print-sudoers` | `requirement-three-layer-privilege-model` |
| Admin sudoers install script | Expose `print-sudoers-install-script` | `requirement-three-layer-privilege-model` |
| Remove project-sudoers draft | Expose `remove-project-sudoers` | `requirement-three-layer-privilege-model` |
| Generate sudoer file | Expose `generate-sudoer-request` / `generate-sudoer-json` — JSON grant for **one exact folder**, ownership wildcard | workflow + `requirement-sudoer-json-file` |
| Submit sudoers for approval | Expose `submit-sudoer-request` — JSON request into sibling public inbound | workflow + `requirement-sudoer-json-file` |
| Global-only grant path | Emit/submit **MUST** name only `${GLOBAL_BIN}/take-ownership` | `requirement-sudoer-json-file` · privilege trust tiers |

Domain **MUST NOT** restate full chown or sudoers-body rules in a second competing SSOT.

#### Filename grammar (queued artifact — sibling allocates `n`)

```text
sudoer-{{YYYYMMDD}}-take-ownership-{{username}}-{{action}}-{{n}}.json
```

**Worked sample basename (add):** `sudoer-20260825-take-ownership-alice-add-1.json`  
**Worked sample basename (update):** `sudoer-20260825-take-ownership-alice-update-1.json`

Complete JSON bodies live on `requirement-sudoer-json-file` (add = one folder; update **MAY** append another folder).

### 2.3 Pillar C — Specialized project help items

`help` **MUST** show domain rows (in addition to Type 0 lifecycle). **Operational** rows and **test-purpose** rows **MUST** be listed **apart**.

**Operational:**

| Help row | Text intent |
|----------|-------------|
| `list-folders` | List folders this login may take ownership of |
| `action --path <folder> --ownership <user:group>` | Recursively take ownership of that folder (no symlink follow). Confirms `--path` is on `list-folders` first. |
| `remove-project-sudoers [path]` | Delete project-sudoers-file draft only (not `/etc`) |
| `submit-sudoer-request [--path <folder>] [file]` | Queue a JSON grant for that folder via sudoer-cli (default **update** if this user’s host fragment exists) |

**Test-purpose** (grant-emit testers; **not** on the main menu):

| Help row | Text intent |
|----------|-------------|
| `print-sudoers --path <folder>` | Emit **project-sudoers-file** (draft) for admin install. Requires global install. |
| `print-sudoers-install-script --path <folder>` | Write admin script for sudo install/uninstall/replace |
| `generate-sudoer-request --path <folder> [dest]` | Independently write a JSON grant you can read; no `/etc`; no inbound |
| `generate-sudoer-json --path <folder> [dest]` | Same dest; canonical JSON for tests (`"--ownership","*"`) |

Help **MUST** state: JSON field `action` (add/update) is **not** the CLI verb `action`.

Examples in help **SHOULD** include:

```text
take-ownership install
sudo take-ownership install
take-ownership generate-sudoer-request --path /var/www/html
take-ownership generate-sudoer-json --path /var/www/html /tmp/gold-sudoer.json
take-ownership submit-sudoer-request --path /var/www/html
take-ownership list-folders
take-ownership action --path /var/www/html --ownership www-data:www-data
```

### 2.4 Pillar D — Specialized project about items

`about` **MUST** include domain diagnostics (in addition to Type 0):

| Field / line | Content |
|--------------|---------|
| Global binary | `${GLOBAL_BIN}/take-ownership` present or `not_found` (drives grant-emit gate) |
| sudoer-cli | Detected path or `not_found` |
| sudoer-adm | Detected login or `absent` |
| sudoer inbound | Detected inbound dir or `not_found`; plus writable flag. Preferred: `/var/sudoer-cli/sudoer-request` |
| Host sudoers fragment | `host_sudoers_present` / `host_sudoers_path` — this user’s `/etc/sudoers.d/take-ownership-<user>` |
| Domain version note | Product `VERSION` remains local version SSOT |

**About is not** a remote version-check and **must not** advertise online install channels.

### 2.5 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product / APP_NAME** | `take-ownership` |
| **Domain prefix** | `to_` |
| **Ship unit** | `src/take-ownership` |
| **VERSION** | ship unit SSOT (see `src/take-ownership`) |
| **Primary user install** | `${HOME}/.local/bin/take-ownership` (Type 0 only; **not** a sudoers path) |
| **Production binary** | `/usr/local/bin/take-ownership` |
| **Ops SSOT** | `requirement-take-ownership-ops` |
| **Privilege / sudoers SSOT** | `requirement-three-layer-privilege-model` (workflow) · `requirement-sudoer-json-file` (JSON grant body) |
| **Submit verb** | `submit-sudoer-request` → `to_submit_sudoer_request` |
| **Generate verb** | `generate-sudoer-request` → `to_generate_sudoer_request` |
| **Generate JSON alias** | `generate-sudoer-json` → `to_generate_sudoer_request` |
| **Action verb** | `action` → `to_action` |
| **Public inbound (sibling)** | `/var/sudoer-cli/sudoer-request` (3773) |
| **Worked queued basename** | `sudoer-20260825-take-ownership-alice-add-1.json` |
| **Bootstrap** | Specialized from **folder-backup** (itself from **cli-template**); backup domain retired |

### 2.6 Why This Requirement Exists (CIAO)

- **Principle 2 – Intentional**: Domain surface is explicit (four pillars) and not mixed with full ops law.  
- **Principle 5 – Output SSOT**: Help/about domain rows via product output system.  
- **Principle 9 – Three Types of Commands**: Domain labels verbs that invoke Type 1 re-exec under peer REQs.  
- **Principle 10 – Least privilege**: Grant is one folder, not the whole host.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Do not invent a second chown SSOT in domain.  
- **Intentional:** Pillars A–D only; ops in take-ownership-ops.  
- **Anti-fragile:** Clear ownership boundaries reduce drift.  
- **Over-protect:** Keep sole Active domain file; supersede before replace.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Duplicate full chown/validate law here once `requirement-take-ownership-ops` is Active.  
2. Add online install or backup/restore as silent domain behavior.  
3. Put domain law into bootstrap parent `folder-backup` or `cli-template`.  
4. Create a second Active `requirement-domain-*` without superseding this one.  
5. Let Type 0 `mkdir` `/var/sudoer-cli/sudoer-request`.  
6. Mix test-purpose grant-emit verbs into operational help grouping, or put them on the numbered main menu.  
7. Elevate `${USER_BIN}/take-ownership` or treat local install as a production grant path.  
8. Collapse JSON field `action` (add/update) with CLI verb `action`.  
9. Reintroduce `backup` / `restore` as live domain verbs.

**Violating this rule is a critical domain regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Four pillars present (subcommands, feature map, help, about) |
| AC-2 | `list-folders`, `action`, grant-emit, remove, and submit listed with peer SSOT pointers |
| AC-3 | Help lists test-purpose grant-emit verbs **apart** from operational |
| AC-4 | About lists global-bin presence + sudoer-cli / sudoer-adm / inbound + host fragment |
| AC-5 | Registered as sole Active domain SSOT |
| AC-6 | No competing full ops body (defers to take-ownership-ops) |
| AC-7 | `action` uses `--path` then `--ownership`; no short flags on the granted argv |
| AC-8 | Grant-emit verbs fail closed when the global binary is missing |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-take-ownership-ops` | **Operational take-ownership SSOT** |
| `requirement-three-layer-privilege-model` | Elevation + sudoers workflow |
| `requirement-sudoer-json-file` | JSON sudoer file body (`take-ownership` only) |
| `requirement-shell-cli-interface` | Routes domain verbs; help purpose split |
| `requirement-shell-cli-default-interaction` | Main menu omits test-purpose grant-emit verbs |
| `requirement-bootstrap-chain` | Domain replace from folder-backup |
| `docs/requirements/index.md` | Registry |
| `./src/take-ownership` | Implementation under test |

---

## Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-TAKE-OWNERSHIP-01** | `tests/test_domain_take_ownership.sh` | **todo** — `action` routed; `--path` then `--ownership` |
| **TP-TAKE-OWNERSHIP-02** | same | **todo** — help lists test-purpose grant-emit apart |
| **TP-TAKE-OWNERSHIP-03** | same | **todo** — generate/submit refuse when global binary missing |
| **TP-TAKE-OWNERSHIP-27,27b,28** | same | **have** — `generate-sudoer-json` dirty cwd; globbed submit fail-closed |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-25 | Active 1.0.0 | Domain SSOT for take-ownership; supersedes folder-backup domain |
| 2026-08-26 | Active 1.2.0 | `generate-sudoer-json` test-purpose alias; canonical JSON for tests |

---

**Last Updated**: 2026-08-26  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
