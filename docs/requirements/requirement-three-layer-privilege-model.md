**file**: docs/requirements/requirement-three-layer-privilege-model.md  
**Status**: Active (Version 2.1.0)  
**Area**: architecture  
**Key**: `requirement-three-layer-privilege-model`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for the **three-layer privilege model** as applied to **take-ownership**: which operations run as the invoking user, which use **narrow elevated sudo**, and what is out of scope.

It is also the **product law SSOT for working with sudoers fragment files**: how the CLI **emits** a draft, how an **admin** validates and installs under `/etc/sudoers.d/`, how **`generate-sudoer-request`** writes a local JSON grant you can verify, how **`submit-sudoer-request`** hands a grant to sibling **sudoer-cli**, how **runtime `action`** uses allowlisted `sudo -n` of the **global** binary, and how **fail-closed** behaves when elevation or the global binary is missing.

**JSON sudoer file body** is **not** owned here — it is **`requirement-sudoer-json-file`**. That peer **MUST** grant only `/usr/local/bin/take-ownership`; OS-tool commands (`chown`, `cp`, …) are forbidden there.

Domain catalog lives in `requirement-domain-take-ownership`. Recursive chown lives in `requirement-take-ownership-ops`.

### 1.1 Human-facing

**In one sentence:** You install the program into `/usr/local/bin`, submit a grant for one folder, an admin installs it, then `take-ownership action --path <folder> --ownership user:group` can run passwordless — including from automation that has no terminal.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Generate/submit; run `action` after install | `take-ownership generate-sudoer-request --path /var/www/html` |
| Admin | Validate and install under `/etc/sudoers.d/` | `visudo -c` then mode `0440` |
| Not this file | JSON command list shape | `requirement-sudoer-json-file` |

| Includes | Excludes |
|----------|----------|
| Grant names **only** `/usr/local/bin/take-ownership` | `${HOME}/.local/bin/take-ownership` in sudoers |
| Exact `--path` + `--ownership *` | `--allow-test-local`; `NOPASSWD: ALL` |
| Non-interactive `sudo -n` of the matching line | Blaming “no TTY” when the grant is too narrow |

| Surface | What you open | What for |
|---------|---------------|----------|
| `./src/take-ownership` | ship unit | live emit |
| `take-ownership help` | command | `generate-sudoer-request` / `action` |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Place the production binary | Root copies the ship unit to `/usr/local/bin` | `sudo take-ownership install` or `sudo sh src/take-ownership install` |
| After admin install, take ownership | Automation may use `sudo -n` because NOPASSWD matches the full argv | `take-ownership action --path /var/www/html --ownership www-data:www-data` |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Layer map (this product)

| Layer | Privilege | Actor | take-ownership responsibilities |
|-------|-----------|-------|--------------------------------|
| **You (Type 0)** | Invoking user | End user / automation | Local or global install/uninstall, diagnostics, grant generate/submit (no `/etc` write), path report |
| **Host change (Type 1)** | Elevated (controlled sudo) | root via **allowlisted** command only | `take-ownership action --path <folder> --ownership <user:group>` of the **global** binary. After elev, chown runs **inside** the ship unit |
| **Dedicated badge (Type 2)** | Dedicated least-privilege system user | App runtime user | **Not used** — no dedicated app user required |

### 2.2 Least-privilege rules

1. **MUST NOT** require the whole CLI to run as root for help/generate/submit.  
2. **MUST** elevate only for `action` (and only via allowlisted sudo of the global binary).  
3. **MUST NOT** grant unrestricted shell, package install, `/bin/chown`, or arbitrary `cp`.  
4. **MUST NOT** open unapproved network egress as part of privilege design (non-online-installable product).  
5. **MUST NOT** treat “sudoers installed” as permission to broaden Cmnds later without a new security review.  
6. **MUST NOT** associate a user-rewritable binary into `/etc/sudoers.d/`.

### 2.3 Working with sudoers fragment files (normative)

#### 2.3.1 Roles and artifacts

| Role | May | Must not |
|------|-----|----------|
| **End user / automation** | Run generate/submit after global install; run `action` after admin install | Write `/etc/sudoers.d/` as yourself |
| **CLI (you)** | Emit fragment to **stdout** or a **user-writable draft path** | Silently install or rewrite `/etc/sudoers.d/*` |
| **Admin (root)** | `visudo -c`, install with mode `0440` | Install fragments that grant shell/`ALL` or USER_BIN |
| **Sibling dest** | Approve queued JSON (`sudoer-adm` via `sudoer-cli`) | This product’s Type 0 path |

| Artifact | Location (this product) | Authority |
|----------|-------------------------|-----------|
| **Draft fragment** | stdout **or** `${HOME}/.config/take-ownership/sudoers.fragment-<user>` | Type 0 write only |
| **Installed fragment** | `/etc/sudoers.d/take-ownership-<user>` (per-user; multi-user safe) | Admin only; mode `0440` |
| **JSON grant draft** | `${HOME}/.config/take-ownership/sudoer-request-<user>.json` | Type 0 write; readable without sudo |

#### 2.3.1a Install trust tiers (mandatory — global only)

| Trust tier | Managed install | Grant emit |
|------------|-----------------|------------|
| **`production`** | Executable **`/usr/local/bin/take-ownership`** (typically root-owned, not writable by the target user) | **Allowed** |
| **`test_local`** | Only **`${USER_BIN}/take-ownership`** | **Forbidden** — fail closed. **No** `--allow-test-local` |
| **Unmanaged** | Neither | **Forbidden** — fail closed |

**Normative:**

1. **MUST NOT** emit, generate, or submit a grant unless `/usr/local/bin/take-ownership` exists and is executable.  
2. Local install remains correct for **help / version / about / where-is-me** **without** sudoers.  
3. Hosts that will **keep** an installed fragment **MUST** use root install → global: `sudo sh src/take-ownership install` or `take-ownership install --global`.  
4. Elevating `${USER_BIN}/take-ownership` is **forbidden** (user can rewrite the binary → jailbreak).  
5. Missing global binary: grant-emit verbs **MUST** fail closed with operator-readable next step (`sudo take-ownership install` / `install --global`).

#### 2.3.2 Operator workflow (mandatory order)

| Step | Who | Action |
|------|-----|--------|
| 1 | User / admin | **Global** install (`sudo take-ownership install`) |
| 2 | User | `take-ownership generate-sudoer-request --path <folder>` — independent JSON, readable without sudo |
| 3 | User (when sudoer-cli + sudoer-adm are present) | `take-ownership submit-sudoer-request --path <folder>` (or pass the reviewed file). Type 0; no `/etc` write; no inbound `mkdir` |
| 4 | **Admin** | Review; `visudo -c` + `install -m 0440`, **or** `sudo sh <admin-script> install`, **or** approve via sudoer-cli |
| 5 | User | `take-ownership action --path <folder> --ownership <user:group>` — in-tool `sudo -n` of the **global** binary |
| 6 | Admin (leave elev) | `sudo sh <admin-script> uninstall` (or `sudo rm /etc/sudoers.d/take-ownership-<user>`) |

Optional: `print-sudoers --path <folder>` (test-purpose text dual) and `print-sudoers-install-script --path <folder>`. Same global-bin gate.

#### 2.3.2a Independent sudoer generate (sacred)

Any sudoer artifact this product generates **MUST** be producible by a Type 0 subcommand that writes the file **independently** of submit, approve, and `/etc` install. Tests and review **MUST** open that file **without sudo**.

| Rule | Detail |
|------|--------|
| **Subcommand** | `generate-sudoer-request` / `generate-sudoer-json` (JSON) and `print-sudoers` (text dual) |
| **`--path` required** | Bound folder for the grant |
| **Readable dest** | Invoking user **MUST** `cat` without sudo |
| **Default dest** | `${HOME}/.config/take-ownership/sudoer-request-<user>.json` |
| **Forbidden dest** | `/etc/**`; sibling inbound; a deleted submit temp |
| **Global gate** | Fail closed if `/usr/local/bin/take-ownership` is missing |

#### 2.3.3 Grant-emit verbs (Type 0)

`print-sudoers`, `print-sudoers-install-script`, `generate-sudoer-request`, `generate-sudoer-json`, `submit-sudoer-request` keep the folder-backup workflow **shape** (no `/etc` write, no inbound `mkdir`, per-user fragment, sibling allocate, host-probe add vs update, `--add`/`--update` override, inbound fidelity, operator-readable fatal copy) with these **take-ownership** fills:

| Concern | This product |
|---------|----------------|
| APP_NAME | `take-ownership` |
| Bound folder | `--path <folder>` required on emit (file operand on submit **MAY** omit if the file already names `--path`) |
| Draft | `${HOME}/.config/take-ownership/sudoers.fragment-<user>` |
| Installed | `/etc/sudoers.d/take-ownership-<user>` |
| Admin script | `/dev/shm/take-ownership-<user>-sudoers-admin.sh` (`install`/`uninstall`/`replace`/`status`) |
| Sibling CLI | `sudoer-cli` (`SUDOER_CLI`) |
| Sibling approver | `sudoer-adm` (`SUDOER_ADM_USER`) |
| Preferred inbound | `/var/sudoer-cli/sudoer-request` (3773) — **MUST NOT** mkdir |
| Default add vs update | Host probe of **this user’s** `/etc/sudoers.d/take-ownership-<user>` (legacy `/etc/sudoers.d/take-ownership`) |
| Later folders | **update appends** another `--path` command pair (verb + `--json` twin). **MUST NOT** drop the old folder |
| Body SSOT | `requirement-sudoer-json-file` |
| Test-local flag | **Absent** — do not implement `--allow-test-local` |

`remove-project-sudoers` removes the **draft only** (not `/etc`). Confirm / `--force`. Probe host fragment and warn if elev remains.

#### 2.3.4 Fragment content constraints

Match the JSON grant:

```text
<user> ALL=(root) NOPASSWD: /usr/local/bin/take-ownership action --path /var/www/html --ownership *
<user> ALL=(root) NOPASSWD: /usr/local/bin/take-ownership --json action --path /var/www/html --ownership *
```

**MUST NOT:** USER_BIN path, `/bin/chown`, `NOPASSWD: ALL`, shells, `--path *`, verb-only `action` with no `--path`.

Worked user in comments: `alice` (illustrative; live emit uses `id -un`).

#### 2.3.5 Admin install rules

1. Admin **MUST** `visudo -c` before install.  
2. Mode **`0440`**, owner `root:root`.  
3. Path **`/etc/sudoers.d/take-ownership-<user>`** (per-user).  
4. Type 0 **MUST NOT** perform this install as a silent side effect.  
5. **MUST NOT** install multiple users into a shared basename.

#### 2.3.6 Runtime elevation after sudoers install

| Rule | Detail |
|------|--------|
| **Invocation** | Non-root `action` **MUST** re-exec `sudo -n /usr/local/bin/take-ownership action --path <folder> --ownership <user:group>` |
| **Root path** | If `id -u` is 0, chown **MAY** run without sudo |
| **Wrapper** | `requirement-shell-sudo-command` |
| **Probe honesty** | **MUST NOT** claim elevation is impossible solely because there is no TTY. Verb-only or wrong-flag-order grant + password prompt is **grant-too-narrow** |

#### 2.3.7 Fail-closed (mandatory)

If sudo is missing, not authorized for the `action` argv, the global binary is missing, or chown cannot complete:

1. `action` **MUST** fail with non-zero exit.  
2. Human error **MUST** name the missing grant and next commands (`generate-sudoer-request --path …`, `submit-sudoer-request`).  
3. **MUST NOT** silently skip chown and claim success.  
4. **MUST NOT** fall back to `${USER_BIN}/take-ownership` as the elevated Cmnd.

### 2.4 Implementation Notes (this product)

| Item | Value |
|------|--------|
| **Product / APP_NAME** | `take-ownership` |
| **Ship unit** | `src/take-ownership` |
| **GLOBAL_BIN** | `/usr/local/bin` |
| **USER_BIN** | `${HOME}/.local/bin` |
| **Project sudoers file (draft)** | `${HOME}/.config/take-ownership/sudoers.fragment-<user>` |
| **Admin install path** | `/etc/sudoers.d/take-ownership-<user>` |
| **Admin install script** | `/dev/shm/take-ownership-<user>-sudoers-admin.sh` |
| **Type 2 system user** | None |
| **Handlers** | `to_print_sudoers`, `to_print_sudoers_install_script`, `to_remove_project_sudoers`, `to_generate_sudoer_request` (`generate-sudoer-json` alias), `to_submit_sudoer_request` |
| **Independent JSON generate dest** | `${HOME}/.config/take-ownership/sudoer-request-<user>.json` |
| **Sibling approval CLI** | `sudoer-cli` |
| **Sibling approver** | `sudoer-adm` |
| **Preferred public inbound** | `/var/sudoer-cli/sudoer-request` |
| **Queued basename** | `sudoer-{{YYYYMMDD}}-take-ownership-{{user}}-add-{{n}}.json` (or `update`) |
| **Worked sample basename** | `sudoer-20260825-take-ownership-alice-add-1.json` |
| **JSON body SSOT** | `requirement-sudoer-json-file` |
| **Test emit gate** | **None** — global binary required |

### 2.5 Why This Requirement Exists (CIAO)

- **Principle 9 – Three Types of Commands**  
- **Principle 10 – Least-Privilege User**  
- **Principle 1 – Caution**: Fail closed without working sudoers or without the global binary  
- **Principle 20 – Over-protect**: Do not collapse elevation into “just run as root” or `NOPASSWD: ALL`

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Narrow allowlist; admin review gate; fail closed; no USER_BIN grant.  
- **Intentional:** You generate; admin installs; `action` elevates only the global binary.  
- **Anti-fragile:** Clear operator path when elevation missing; draft outside `/etc`.  
- **Over-protect:** No unrestricted sudoers templates; no `--allow-test-local`.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Auto-write `/etc/sudoers.d` from Type 0.  
2. Emit `NOPASSWD: ALL` or shell Cmnds.  
3. Put USER_BIN or `/bin/chown` in the fragment.  
4. Reintroduce `--allow-test-local` without an explicit user order (this product forbids it).  
5. Treat “no TTY” as the reason a too-narrow grant prompts for a password.  
6. `mkdir` the production inbound.  
7. Confuse draft removal with host fragment uninstall.  
8. Share one `/etc/sudoers.d/take-ownership` basename across users.  
9. Drop a previously granted folder on update.

**Violating this rule is a critical privilege regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Layer map: you / host-change `action` / Type 2 unused |
| AC-2 | Grant emit fails closed without `/usr/local/bin/take-ownership` |
| AC-3 | Fragment path is global binary + `action --path F --ownership *` plus `--json` twin |
| AC-4 | Type 0 never writes `/etc` or mkdirs inbound |
| AC-5 | Independent generate dest is readable without sudo |
| AC-6 | Per-user installed fragment `/etc/sudoers.d/take-ownership-<user>` |
| AC-7 | Update appends a folder; does not drop the old one |
| AC-8 | Readable inbound still has exact `--ownership *` (cwd listings fail closed) |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-sudoer-json-file` | JSON grant body |
| `requirement-domain-take-ownership` | Verb catalog |
| `requirement-take-ownership-ops` | Runtime `action` |
| `requirement-shell-sudo-command` | In-tool sudo wrap |
| `requirement-shell-cli-interface` | Routing |
| `requirement-operator-readable-error` | Fatal copy |
| `docs/requirements/index.md` | Registry |
| `./src/take-ownership` | Implementation under test |

---

## Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-TAKE-OWNERSHIP-30** | `tests/test_domain_take_ownership.sh` | **todo** — generate/submit fail without global binary |
| **TP-TAKE-OWNERSHIP-31** | same | **todo** — fragment has no USER_BIN and no `/bin/chown` |
| **TP-TAKE-OWNERSHIP-32** | same | **todo** — Type 0 does not write `/etc` |
| **TP-TAKE-OWNERSHIP-33** | same | **todo** — update appends a second `--path` |
| **TP-TAKE-OWNERSHIP-27,28** | same | **have** — generate-sudoer-json dest; inbound exact-args (AC-8) |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active | folder-backup Type 0 + narrow deposit |
| 2026-08-23 | Active 1.12.0 | folder-backup: `backup *` / host-probe / independent generate |
| 2026-08-25 | Active 2.0.0 | Retarget take-ownership; **global-only** grant; no `--allow-test-local` |
| 2026-08-26 | Active 2.1.0 | Inbound exact-args; `generate-sudoer-json` independent generate alias |

---

**Last Updated**: 2026-08-26  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
