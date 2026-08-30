**file**: docs/requirements/requirement-class-software-dev.md  
**Status**: Active (Version 2.0.1 – take-ownership residual)  
**Area**: class  
**Key**: `requirement-class-software-dev`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

Declare this workspace as a **software-development** project nature and hold the **residual collection** of software-engineering stack facts **not already owned** by more specific Active peer requirements: primary language, toolchain policy, package/test tooling, and runtime OS family.

This file is **class law + residual SSOT**, not a second copy of Type 0 lifecycle, domain take-ownership, output, or storage tables (those stay on peer requirements).

### 1.1 Human-facing

This file says the workspace is a **shippable program** (take-ownership) and records leftover stack facts that no other requirement already owns.

| You | Another role | Not this |
|-----|--------------|----------|
| Read this file to learn the project nature and leftover stack (language, tools, “no dest approver”) | Peer requirements own take-ownership ops, install, sudoers grant body, and CLI verbs | A dest approval machine, a second class file, or online-install law |

**Includes:** class membership, residual stack, honest “none” for dest approver and dest fences.  
**Excludes:** inventing an approver account; inventing dest fence rows; duplicating peer ops/install tables.

| Step | What it means | What you type |
|------|---------------|---------------|
| Classify | Agents treat this tree as software-development, not a blank seed. | Open `docs/requirements/requirement-class-software-dev.md` |
| Own-or-point | Stack facts live here until a peer requirement takes them. | Follow the residual ownership table in this file |

---

## 2. Core Rules (Mandatory)

### 2.0 Project class membership

1. **MUST** treat this workspace as **software-development** (shippable software), not genesis-template and not server-maintenance.  
2. **MUST** use basename **`requirement-class-software-dev.md`** as the sole Active class-law file for this class.  
3. **MUST NOT** register an Active `requirement-class-server-maintenance.md` while class is software-development.  
4. **MUST** retain portable harness knowledge; specialized product knowledge lives in this and peer `requirement-*.md` files.  
5. **MUST** apply software-development SSOT/gate posture when claimed (identity, ship unit, precommit when git is used — as applicable).  
5a. When git is used on a **multi-vault host**, **MUST** treat forge push identity as **product repository-user SSOT** (Config `REPO_USER` / project-repository owner), not ambient default SSH face. Host vault basenames are **not** product law.  
6. **MUST NOT** invent hollow product docs solely to look specialized; collect real values or defer explicitly.

### 2.1 Residual collection principle (SSOT hygiene)

7. **MUST** treat this file as the **default home** for software-stack facts **not owned** by another Active requirement.  
8. **MUST NOT** duplicate full normative tables that already live in a more specific Active requirement. Prefer a **one-line pointer** to the peer requirement key.  
9. When a new specialized requirement **takes ownership** of a topic previously only listed here, **MUST** update this file in the **same change**: remove or shrink the residual entry and point to the new owner.  
10. **MUST NOT** leave contradictory stack facts across this file and peer requirements.

### 2.2–2.6 Stack rules

Primary language, toolchain, package tools, and runtime **MUST** be declared in Implementation Notes. **MUST NOT** freeze secrets or a session Unix login as universal core law.

### 2.7 Implementation Notes (this project)

| Field | Value (take-ownership) |
|-------|---------------------|
| **Project display name** | `take-ownership` |
| **Project nature** | software-development |
| **Class requirement basename** | `requirement-class-software-dev.md` |
| **Primary language(s)** | `posix-sh` (`/bin/sh`) |
| **Language role** | primary only — single-file shell ship unit under `src/` |
| **Execution model** | **interpreted** — no compile step |
| **Toolchain / interpreter** | POSIX `/bin/sh` (dash/bash-as-sh compatible subset); no compiler |
| **Toolchain version policy** | **unconstrained** among POSIX sh implementations that pass product tests when present |
| **Cross-compile in scope?** | no |
| **Primary project/package tool** | **none** — no language module system; ship unit is the source |
| **Lockfile policy** | not used |
| **Test runner** | POSIX shell suite under `tests/` when present (`tests/run.sh` pattern) |
| **Linter/formatter** | none as project law (shellcheck optional for maintainers) |
| **Primary runtime / OS family** | POSIX Linux (and compatible UNIX where `/bin/sh` + `chown` + `mktemp` exist) |
| **Architectures supported** | any arch with POSIX sh and the external tools the script invokes |
| **Git surface** | used when product is published |
| **Ship unit / install** | yes — `src/take-ownership` → user bin and/or `/usr/local/bin/take-ownership`; **local-only** / non-online-installable (no online channel) |
| **Product version SSOT** | `VERSION=` hard-assign in `src/take-ownership` |
| **Bootstrap origin** | hop A0 `cli-template` → hop A1 `folder-backup` → B `take-ownership` (`requirement-bootstrap-chain`) |
| **Database** | **none** |
| **Product archive backup** | **none** (not a backup tool) |

**Residual ownership table:**

| Topic | Owner | Notes |
|-------|-------|--------|
| Project class membership | **this file** | Fixed |
| Primary language + toolchain policy | **this file** | posix-sh, unconstrained |
| Package/build tool + lockfile | **this file** | none / not used |
| Coding-style specialize-in | `requirement-shell-script-coding` | **MUST**; without it, portable lessons arrive raw |
| In-tool sudo wrap | `requirement-shell-sudo-command` | `util_sudo`; check before sudo |
| Bootstrap lineage / keep-extend | `requirement-bootstrap-chain` | A0=cli-template → A1=folder-backup → B |
| Project layout / ship path | `requirement-project-folder` | `src/` + bin targets |
| Type 0 CLI surface / flags / dispatch | `requirement-shell-cli-interface` | Do not duplicate |
| Empty argv Type N (menu path) | `requirement-shell-cli-zero-arguments` | Local-only; never install; empty argv → `app_main_menu` |
| Local self-managed lifecycle | `requirement-shell-local-self-management` | install / uninstall / where-is-me |
| Output SSOT (`out_*`) | `requirement-shell-output-requirements` | Do not duplicate |
| Operator-readable error wording | `requirement-operator-readable-error` | Do not duplicate |
| Scratch/cache storage resolve | `requirement-shell-cli-storage` | Do not duplicate |
| Idempotency / re-run safety | `requirement-shell-idempotency` | Do not duplicate |
| Interactive vs non-interactive | `requirement-shell-interactive-vs-noninteractive` | Do not duplicate |
| Modular prefixes / single-file layout | `requirement-shell-modular-function-design` | Do not duplicate |
| Privilege layers + sudoers **files** | `requirement-three-layer-privilege-model` | You + narrow `action`; global-only grant |
| JSON sudoer file (grant body) | `requirement-sudoer-json-file` | `take-ownership` only; exact `--path`; `--ownership user:group` |
| Incorrect ownership parameter | `requirement-incorrect-ownership-parameter` | Product grant/inbound fence: no `*`, no cwd listings |
| Take-ownership **operations** | `requirement-take-ownership-ops` | Recursive chown; no symlink follow |
| Domain surface (verbs, help, about) | `requirement-domain-take-ownership` | Four pillars only; ops pointer |
| Actor / role / subject / approver | **this file** (residual) | **considered — no dest approver and no approval subject**. This product has no dest approval machine. Sibling `sudoer-cli` dest is **not** this product. **MUST NOT** invent an approver. |
| Dest fence conditions | **this file** (residual) | **considered — no dest fence conditions**. No dest Fence table. **MUST NOT** invent a dest fence. |
| Online install / remote self-management / companion checksum | **intentionally absent** | Remain absent on B |
| Folder archive backup / retention | **superseded** | Not Active on this product |

**Actor / role / subject / approver (considered — None dest):**

| Actor | Role | Subject | Submitter | Approver |
|-------|------|---------|-----------|----------|
| Invoking login | Operator of this CLI | This login (self-scope grant) | **the actor itself** | **None** (this product). Sibling dest `sudoer-adm` is outside this CLI |

---

## 3. Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 2 – Intentional**: Class and stack choices are explicit, not assumed from folder names.  
- **CIAO Principle 5 – SSOT**: Residual stack facts have one home until specialized requirements take ownership.  
- **CIAO Principle 1 – Caution**: Toolchain policies are declared; agents do not invent compilers or online install.  
- **CIAO Principle 21 – Dual Policies**: Portable core; filled Implementation Notes.  
- **CIAO Principle 4 (O) + Principle 20**: Protection Rule against dual stack SSOTs and wrong-class pollution.

---

## 4. Design Principles (CIAO / CIAO-Lite)

- **Caution**: Assume toolchain and package tools are missing until declared and verified.  
- **Intentional**: Residual collection is deliberate — not a dump of every possible tool.  
- **Anti-fragile**: Unconstrained POSIX sh policy survives multi-env runs when tests pass.  
- **Over-protect**: Protection rule prevents dual stack SSOTs and genesis/class confusion.

---

## 5. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Delete this file while the workspace remains **software-development** with other Active product requirements.  
2. Rename the specialized basename away from `requirement-class-software-dev.md` without an explicit class-model change.  
3. Hard-code secrets, personal owner identity, or production host FQDNs into core rules as universal law.  
4. Duplicate full peer requirement bodies into this residual section.  
5. Leave Implementation Notes as hollow stubs when Status claims Active.  
6. Reintroduce Active **online-install** / remote **self-update** / **self-uninstall** / channel **checksum** law without explicit user order (product is **non-online-installable** by design).  
7. Treat this file as server-maintenance allowlist law, or register an Active server-maintenance class file in parallel.  
8. Invent a dest approver or dest fence so the set “looks complete.”  
9. Skip `requirement-shell-script-coding` so portable lessons arrive raw.

**Violating any of these is considered a critical regression.**

---

## 6. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Active registered `requirement-class-software-dev.md` matches software-development |
| AC-2 | Primary language + toolchain policy + package tool declared in Implementation Notes (complete) |
| AC-3 | Residual ownership table honest: no silent dual SSOT with peer REQs |
| AC-4 | Core rules remain free of frozen secret/host hardcodes |
| AC-5 | No class file conflict with `requirement-class-server-maintenance` |
| AC-6 | Ship unit identity (posix-sh single-file, local install) consistent with peer shell REQs |
| AC-7 | Online install package **absent** from Active registry by design |
| AC-8 | Coding-style REQ Active; dest approver/fences honest None |

---

## 7. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-bootstrap-chain` | Lineage A0=cli-template → A1=folder-backup → B=take-ownership |
| `requirement-project-folder` | Layout and install locations |
| `requirement-shell-script-coding` | Coding-style specialize-in |
| `requirement-shell-sudo-command` | In-tool sudo |
| `requirement-shell-cli-interface` | Command surface, flags, dispatch |
| `requirement-shell-cli-zero-arguments` | Type N empty argv (routes to menu) |
| `requirement-shell-local-self-management` | Local install lifecycle |
| `requirement-shell-output-requirements` | `out_*` SSOT |
| `requirement-operator-readable-error` | Operator error wording |
| `requirement-shell-cli-storage` | Scratch/cache resolve |
| `requirement-shell-idempotency` | Re-run safety |
| `requirement-shell-interactive-vs-noninteractive` | Mode policy |
| `requirement-shell-modular-function-design` | Prefixes / single-file modularity |
| `requirement-three-layer-privilege-model` | Privilege + working with sudoers fragment files |
| `requirement-sudoer-json-file` | JSON sudoer file body |
| `requirement-take-ownership-ops` | Take-ownership operations SSOT |
| `requirement-domain-take-ownership` | Domain four pillars |
| `docs/requirements/index.md` | Registry SSOT |

---

## 8. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-19 | Active (1.1.0) | folder-backup residual: no dest approver / no dest fences |
| 2026-08-25 | Active (2.0.0) | take-ownership residual; coding-style + sudo-wrap peers; backup ops superseded |
| 2026-08-30 | Active (2.0.1) | Residual pointer: empty argv Type N routes to menu |

---

**Last Updated**: 2026-08-30  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
