**file**: docs/requirements/requirement-sudoer-json-file.md  
**Status**: Active (Version 2.4.0)  
**Area**: architecture  
**Key**: `requirement-sudoer-json-file`  
**Optional RQ-ID**: `RQ-SUDOER-JSON-FILE`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **product Single Source of Truth** for the **JSON-type sudoer file**: the machine encoding of this product’s elevation grant (the body a Type 0 submit hands to the sibling allocator, or an equivalent JSON dual of that grant).

The grant **MUST** name only the project command **`take-ownership`**. It **MUST NOT** allowlist other shell or OS tools (`cp`, `mkdir`, `install`, `chmod`, `chown`, `tar`, `rm`, shells, …). Those extra tools **increase design complexity and thereby weaken security**.

**Command identity (this product):** only the **managed global** binary. Local `${USER_BIN}/take-ownership` in `commands[].path` is a **security leak** (the user can rewrite the file). Generate and submit **MUST** fail closed unless `${GLOBAL_BIN}/take-ownership` exists.

**Grant width (this product):** **exact folder**, **exact** `user:group`. Each grant line binds `--path` to one absolute directory and `--ownership` to one existing host identity. Wildcard `*` is **not** allowed.

Must-not-confuse: JSON field **`action`** is `add` or `update` of the grant. CLI verb **`action`** is the take-ownership command. They are different words.

This file does **not** own:

| Concern | Owner |
|---------|--------|
| Type 0/1/2 map, `print-sudoers` emit, admin install, submit **workflow**, global-bin gate | `requirement-three-layer-privilege-model` |
| Domain verb catalog / help / about | `requirement-domain-take-ownership` |
| Recursive chown / refuse-list | `requirement-take-ownership-ops` |

Queued **basename** allocation remains sibling-owned. This requirement owns **command identity and JSON body shape**.

### 1.1 Human-facing

**In one sentence:** The JSON grant says this login may run `take-ownership action --path /that/folder --ownership user:group` as root of the **global** binary — one recursive folder per sudoers line.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | The username in the JSON | live emit uses `id -un` |
| The grant | Global binary + `action` + exact `--path` + `--ownership user:group` | `args: ["action","--path","/var/www/html","--ownership","www-data:www-data"]` |
| Not this file | How to install the fragment | `requirement-three-layer-privilege-model` |

| Includes | Excludes |
|----------|----------|
| One **folder** per sudoers **line** (verb + `--json` twin) | Files as args; two folders on **one** line; `--path *`; `--ownership *` |
| Replacement JSON: unique prior folders + this `--path` | Repeating a folder that is already granted |
| `/usr/local/bin/take-ownership` only | `${HOME}/.local/bin/take-ownership`; `/bin/chown` |

| Surface | What you open | What for |
|---------|---------------|----------|
| `take-ownership generate-sudoer-json --path /var/www/html --ownership www-data:www-data` | command | Canonical JSON grant on a readable dest (test-purpose alias of generate-sudoer-request) |
| `./src/take-ownership` | ship unit | emit |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Generate the JSON grant for one folder | You can `cat` the dest without sudo. One line per unique folder. | `take-ownership generate-sudoer-json --path /var/www/html --ownership www-data:www-data` |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 What a JSON sudoer file is

1. A JSON sudoer file is a **closed-schema object** that states: who may elevate, which **product** the grant is for, add vs update, and a **commands** list.  
2. It is **not** `sudoers(5)` text. It is **not** this product’s `--json` CLI status.  
3. Sibling approval software **MAY** convert a text dual into this JSON. Conversion **MUST NOT** invent OS-tool commands that this requirement forbids.  
4. If both a text fragment and a JSON sudoer file represent the **same** grant, they **MUST** be equivalent: both elevate **`take-ownership` only**. A text file that allowlists `chown`/`mkdir`/`cp` **MUST NOT** be treated as a valid dual.  
5. Pretty-printed JSON is a **legal** encoding. Compact one-line JSON is also legal. A decoder **MUST** accept both.

### 2.2 Command identity — `take-ownership` global only (sacred)

| Rule | Detail |
|------|--------|
| **Identity** | Every `commands[].path` **MUST** be `/usr/local/bin/take-ownership` (`{{GLOBAL_BIN}}/{{PRJ_NAME}}`) |
| **Basename** | `basename(path)` **MUST** equal `take-ownership` |
| **One program** | The grant **MUST NOT** list any other executable |
| **No local binary** | **MUST NOT** elevate `${USER_BIN}/take-ownership` |
| **No OS tools** | **MUST NOT** list `cp`, `mkdir`, `install`, `chmod`, `chown`, `tar`, `rm`, `ln`, `mv`, `dd`, or any shell |
| **No ALL** | **MUST NOT** use `ALL`, `NOPASSWD: ALL`, or an empty/unrestricted command set |
| **Global must exist** | Generate / submit / print-sudoers **MUST** fail closed if `/usr/local/bin/take-ownership` is missing or not executable. **No** `--allow-test-local` |

Elevating **`take-ownership`** once is the smaller F6: after the grant, the ship unit performs `chown` **internally**. `/bin/chown` is **not** a sudoers catalog.

### 2.3 Arguments — exact folder, exact ownership (sacred)

1. Each elev object’s `commands[].args` **MUST** be exactly:

```text
["action", "--path", "<absolute-folder>", "--ownership", "<user:group>"]
```

or the `--json` twin:

```text
["--json", "action", "--path", "<absolute-folder>", "--ownership", "<user:group>"]
```

2. `<absolute-folder>` **MUST** be **one** absolute **directory** (recursive take-ownership). It is **not** `*`, **not** a file, and **not** a list of files.  
3. `<user:group>` **MUST** be an existing host identity. **MUST NOT** be `*`. **MUST NOT** be extra cwd names (`AGENTS.md`, `docs`, `src`, …). Peer fence: `requirement-incorrect-ownership-parameter`.  
4. `--json` **MUST** be a **separate** `commands[]` object with `--json` as the **first** arg (twin **line** for the **same** folder).  
5. Generate / print / submit emit **MUST** require `--ownership` (same operand `action` will use).  
6. **MUST NOT** grant `install`, `uninstall`, `print-sudoers`, `print-sudoers-install-script`, `remove-project-sudoers`, `generate-sudoer-request`, `generate-sudoer-json`, or `submit-sudoer-request` as elevated commands.  
7. **MUST NOT** grant the binary with **no** verb.  
8. **MUST NOT** emit short flags (`-p`, `-o`) or swapped `--ownership` before `--path`.  
9. **One line, one folder.** **MUST NOT** put two folders or any files on **one** `commands[].args` array / one sudoers Cmnd line.  
10. **Next folder = next submission.** Generate **MUST** read the existing unique `--path` list first, **skip** a folder that is already present, then emit a **replacement** body: one action line (+ `--json` twin) per unique folder (1 folder → 1 line, 2 folders → 2 lines, …). JSON field `"action": "update"` marks that replacement. **MUST NOT** use `--path *` to “cover all folders.”

### 2.4 Closed schema (normative)

| Field | Type | Required | Rule |
|-------|------|----------|------|
| `schema_version` | integer | yes | `1` |
| `purpose` | string | yes | Human purpose; no secrets |
| `username` | string | yes | Target login (submitter); not `ALL` |
| `service` | string | yes | **MUST** equal `take-ownership` |
| `action` | string | yes | `add` or `update` only (**not** the CLI verb) |
| `commands` | array | yes | Non-empty; every element obeys §2.2–2.3 |
| `commands[].runas` | string | yes | `root` |
| `commands[].tags` | array | yes | `NOPASSWD` **MAY** appear |
| `commands[].path` | string | yes | `/usr/local/bin/take-ownership` only |
| `commands[].args` | array of strings | yes | §2.3 shape |

**MUST NOT** add undeclared privilege fields. Unknown sibling metadata **MUST NOT** widen `commands`.

### 2.5 Filename grammar (queued artifact — sibling allocator)

```text
sudoer-{{YYYYMMDD}}-take-ownership-{{username}}-{{action}}-{{n}}.json
```

**Worked sample basename (add):** `sudoer-20260825-take-ownership-alice-add-1.json`  
**Worked sample basename (update):** `sudoer-20260825-take-ownership-alice-update-1.json`

Live emit uses `id -un` for `{{username}}`. Worked samples use `alice` (illustrative, not a host login freeze).

### 2.6 Complete sample bodies (add vs update)

**Add** — one folder:

```json
{
  "schema_version": 1,
  "purpose": "Allow alice to take ownership of /var/www/html.",
  "username": "alice",
  "service": "take-ownership",
  "action": "add",
  "commands": [
    {"runas": "root", "tags": ["NOPASSWD"], "path": "/usr/local/bin/take-ownership", "args": ["action", "--path", "/var/www/html", "--ownership", "www-data:www-data"]},
    {"runas": "root", "tags": ["NOPASSWD"], "path": "/usr/local/bin/take-ownership", "args": ["--json", "action", "--path", "/var/www/html", "--ownership", "www-data:www-data"]}
  ]
}
```

**Update** — **replacement** after a **second submission** (second unique folder = second line, not a second operand on the first line):

```json
{
  "schema_version": 1,
  "purpose": "Allow alice to take ownership of /var/www/html and /srv/data.",
  "username": "alice",
  "service": "take-ownership",
  "action": "update",
  "commands": [
    {"runas": "root", "tags": ["NOPASSWD"], "path": "/usr/local/bin/take-ownership", "args": ["action", "--path", "/var/www/html", "--ownership", "www-data:www-data"]},
    {"runas": "root", "tags": ["NOPASSWD"], "path": "/usr/local/bin/take-ownership", "args": ["--json", "action", "--path", "/var/www/html", "--ownership", "www-data:www-data"]},
    {"runas": "root", "tags": ["NOPASSWD"], "path": "/usr/local/bin/take-ownership", "args": ["action", "--path", "/srv/data", "--ownership", "www-data:www-data"]},
    {"runas": "root", "tags": ["NOPASSWD"], "path": "/usr/local/bin/take-ownership", "args": ["--json", "action", "--path", "/srv/data", "--ownership", "www-data:www-data"]}
  ]
}
```

Equivalent **text dual** of the add grant (`:` in `user:group` **MUST** be `\:` in sudoers text — visudo treats a raw colon after `NOPASSWD:` as another tag. JSON `args` stay `"www-data:www-data"` so they match the live argv):

```text
# Purpose: Allow alice to take ownership of /var/www/html.
alice ALL=(root) NOPASSWD: /usr/local/bin/take-ownership action --path /var/www/html --ownership www-data\:www-data
alice ALL=(root) NOPASSWD: /usr/local/bin/take-ownership --json action --path /var/www/html --ownership www-data\:www-data
```

`--ownership` is an existing `user:group`. Wildcard `*` and cwd listings are **incorrect**. **MUST NOT** copy folder-backup `backup *` onto this product’s ownership operand.

**Withdrawn (forbidden)** encodings — do not copy:

```json
{"path": "/bin/chown", "args": ["-R", "/var/www/html"]}
```

```json
{"path": "/usr/local/bin/take-ownership", "args": ["action", "--path", "*", "--ownership", "*"]}
```

```json
{"path": "${HOME}/.local/bin/take-ownership", "args": ["action", "--path", "/var/www/html", "--ownership", "*"]}
```

### 2.7 Submit / emit honesty

1. When `submit-sudoer-request`, `generate-sudoer-request`, or `generate-sudoer-json` builds a JSON sudoer file, the body **MUST** satisfy §2.2–2.4.  
2. **MUST** fail closed if `commands` contain a forbidden path, USER_BIN path, OS-tool basename, or `--path *`.  
3. **MUST** fail closed if `commands[].args` after `--ownership` are extra tokens (cwd names such as `AGENTS.md`, `docs`, `src`) **or** if the ownership operand is JSON `"*"` (INC-20260823-002 class: unquoted `*` glob-expands; this product does **not** use `"*"` as a sudoers wildcard for ownership — peer `requirement-incorrect-ownership-parameter`).  
4. **MUST NOT** “fix” a forbidden file by submitting it anyway.  
5. Independent generate dest **MUST** be invoking-user readable. Workflow: `requirement-three-layer-privilege-model`. The test-purpose verb **`generate-sudoer-json`** is an alias of `generate-sudoer-request` (same handler, same dest rules) so the suite can lock the canonical body.  
6. Re-encode / convert **MUST** preserve **every** `commands[]` object (pretty and compact). Silent drop of a folder pair is a different grant — fail closed.  
7. When a queued inbound file is readable, submit **MUST** apply the same exact-args check. A body whose `--ownership` operand is a directory listing **MUST** fail closed: do not approve; next command is `generate-sudoer-json`.

### 2.8 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **`{{PRJ_NAME}}` / `APP_NAME`** | `take-ownership` |
| **`{{GLOBAL_BIN}}`** | `/usr/local/bin` |
| **Elevated path** | `/usr/local/bin/take-ownership` |
| **Allowed args** | `["action","--path","<folder>","--ownership","<user:group>"]` and `--json` twin; **one folder per line** |
| **Forbidden paths (examples)** | `/usr/bin/chown`, `/bin/chown`, `/usr/bin/mkdir`, `${HOME}/.local/bin/take-ownership` |
| **Ship unit** | `src/take-ownership` |
| **Submit verb** | `submit-sudoer-request` → `to_submit_sudoer_request` |
| **Generate verb** | `generate-sudoer-request` → `to_generate_sudoer_request` |
| **Generate JSON alias (tests)** | `generate-sudoer-json` → `to_generate_sudoer_request` (same handler) |
| **Generate dest (default)** | `${HOME}/.config/take-ownership/sudoer-request-<user>.json` |
| **Service field** | `take-ownership` |
| **Worked user in samples** | `alice` (illustrative; live emit uses `id -un`) |
| **Privilege / workflow peer** | `requirement-three-layer-privilege-model` |
| **Ownership fence** | `requirement-incorrect-ownership-parameter` |
| **Text dual colon** | `user\:group` in sudoers Cmnd lines; JSON args unescaped `user:group` |

### 2.9 Why This Requirement Exists (Direct CIAO Alignment)

- **Principle 10 – Least privilege**: One managed global binary, **one recursive folder per sudoers line**, exact `user:group` — not `/bin/chown -R *` and not a file list.  
- **Principle 1 – Caution**: USER_BIN in sudoers is a rewrite jailbreak.  
- **Principle 2 – Intentional**: JSON `action` vs CLI `action` are named and fenced.  
- **Principle 21 – Dual policies**: Core rules use placeholders; this section fills `take-ownership` and `/usr/local/bin`.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Refuse OS-tool JSON, local-bin JSON, and leftover `--ownership *` even if 2.0.0/2.2.0 emit used the star.  
- **Intentional:** `service` and `path` basename are `take-ownership`. `--ownership` is a Unix identity, not a sudoers wildcard.  
- **Anti-fragile:** A new `user:group` **is** a new grant (exact argv). A new **folder** is a later submission (replacement union). Wildcard `*` is withdrawn — it glob-expands (INC-20260823-002) and is not an owner.  
- **Over-protect:** Verb-bound exact `--path` and exact `user:group`; no USER_BIN; no `--path *`; no `--ownership *`.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Put `chown`, `cp`, `mkdir`, `install`, `chmod`, `tar`, `rm`, or a shell in a JSON sudoer file `commands` list.  
2. Elevate `${USER_BIN}/take-ownership` or any home-tree path.  
3. Grant `--path *` or omit `--path`.  
4. Grant the binary with no verb.  
5. Emit `-p`/`-o` or swapped flag order in `args`.  
6. Treat JSON field `action` as the CLI verb `action`.  
7. Emit `--ownership *` or unquoted `*` so a shell glob freezes cwd names into the grant.  
8. Store secrets in the JSON body.  
9. Duplicate submit/install workflow law here.  
10. Make submit, inbound, or a deleted temp the only way to obtain this JSON for tests or review.

**Violating this rule is a critical privilege / complexity-as-insecurity regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Every `commands[].path` is `/usr/local/bin/take-ownership` |
| AC-2 | `service` equals `take-ownership` |
| AC-3 | `args` are `action --path <abs> --ownership <user:group>` plus `--json` twin per folder |
| AC-4 | No `chown` / `mkdir` / `cp` / USER_BIN path |
| AC-5 | No `--path *` |
| AC-6 | Add sample is one folder (one line). Update **replacement** adds a **line** per extra unique folder; skip duplicates; never files on a line |
| AC-7 | Generate/submit of a violating body fails closed |
| AC-8 | Independent generate dest is readable without sudo |
| AC-9 | Global binary missing → generate/submit fail closed |
| AC-10 | `generate-sudoer-json` from a dirty cwd still emits `"--ownership","<user:group>"` (not `"*"`, not cwd names) |
| AC-11 | Submit of a globbed `--ownership` listing fails closed and names `generate-sudoer-json` |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-three-layer-privilege-model` | Privilege layers; submit/install workflow; global-bin gate |
| `requirement-incorrect-ownership-parameter` | Fence: `--ownership` is `user:group`; `*` and cwd listings fail closed |
| `requirement-domain-take-ownership` | `submit-sudoer-request` surface; defers JSON **body** here |
| `requirement-take-ownership-ops` | `action` ops after elev |
| `requirement-shell-cli-interface` | Verb routing |
| `requirement-project-folder` | Global bin / ship unit |
| `requirement-class-software-dev` | Residual points JSON sudoer file here |
| `docs/requirements/index.md` | Registry |
| `./src/take-ownership` | Implementation under test |

---

## Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-TAKE-OWNERSHIP-20** | `tests/test_domain_take_ownership.sh` | **todo** — JSON path is only `/usr/local/bin/take-ownership` |
| **TP-TAKE-OWNERSHIP-21** | same | **todo** — no `chown`/`mkdir`/USER_BIN |
| **TP-TAKE-OWNERSHIP-22** | same | **have** — args include exact `--path` and `--ownership user:group` plus `--json` twin |
| **TP-TAKE-OWNERSHIP-23** | same | **todo** — generate refuses missing global binary |
| **TP-TAKE-OWNERSHIP-24** | same | **have** — independent generate dest readable without sudo |
| **TP-TAKE-OWNERSHIP-27,27b** | same | **have** — `generate-sudoer-json` dirty cwd keeps `user:group`, not `"*"` (AC-10) |
| **TP-TAKE-OWNERSHIP-28** | same | **have** — globbed submit fails closed (AC-11) |
| **TP-TAKE-OWNERSHIP-33,33b,34** | same | **have** — replacement union; skip duplicate; `--path` file fails |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-15 | Active 1.0.0 | folder-backup: `{{PRJ_NAME}}` only; OS-tool commands forbidden |
| 2026-08-23 | Active 1.4.0 | folder-backup: `--json` twins; verb plus `*` |
| 2026-08-25 | Active 2.0.0 | Retarget take-ownership: exact `--path`, `--ownership *`, global-only, no test-local |
| 2026-08-26 | Active 2.1.0 | `generate-sudoer-json` alias; exact-args verify; globbed cwd listings fail closed |
| 2026-08-26 | Active 2.2.0 | `--ownership` is `user:group`; `*` withdrawn; incorrect-ownership-parameter fence |
| 2026-08-26 | Active 2.3.0 | One folder per line; replacement union on next submit; no files / no two folders on one line |
| 2026-08-26 | Active 2.4.0 | Withdraw leftover live `*` gold (AC-10 / Anti-fragile). Canonical operand is `user:group`. Text dual escapes `:` as `\:`. |

---

**Last Updated**: 2026-08-26  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
