**file**: docs/requirements/requirement-bootstrap-chain.md  
**Status**: Active (Version 3.0.0)  
**Area**: architecture  
**Key**: `requirement-bootstrap-chain`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

Declare the **bootstrap chain** for this product: ordered lineage, direction, architecture inheritance, and the **domain replace** of folder-archive backup with take-ownership.

**Direction is sacred:** ancestor → descendant only. Never reverse-copy this product onto folder-backup or cli-template.

### 1.1 Human-facing

**In one sentence:** This tree was copied from folder-backup and specialized into take-ownership; architecture stays, backup verbs go away, ownership verbs come in.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Work in this product tree | `{{PROJECTS_ROOT}}/take-ownership` |
| Bootstrap parents | Architecture reference only | folder-backup, then cli-template |
| Not this file | Live `action` semantics | `requirement-take-ownership-ops` |

| Includes | Excludes |
|----------|----------|
| Hop table + keep/extend matrix | Reverse-copy “fixes” onto the parent |
| Domain replace | Online-install channel |

| Surface | What you open | What for |
|---------|---------------|----------|
| `docs/requirements/index.md` | registry | live law |
| `src/take-ownership` | ship unit | B identity |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Specialize further | Copy A→B only | keep parents intact |
| See backup verbs in this tree | Those REQs are superseded | open the Active domain file |

---

## 2. Core Rules (Mandatory)

### 2.1 Direction

1. Every edge **MUST** be **ancestor → descendant** only.  
2. Plans **MUST NOT** copy this product’s ship unit onto folder-backup or cli-template to “share fixes.”  
3. Detected reverse-copy **MUST** be treated as critical pollution (restore parent; rebuild this product).

### 2.2 Chain declaration (this product)

| Field | Value |
|-------|--------|
| **Hop 0 (A0)** | `cli-template` — Type 0 local-only template (sibling `{{PROJECTS_ROOT}}/cli-template`) |
| **Hop 1 (A1)** | `folder-backup` — copy source; Type 0 + sudoers submit architecture |
| **Leaf / hop 2 (B)** | `take-ownership` — this workspace product |
| **Immediate origin of leaf** | `folder-backup` |
| **Specialize mode** | **Domain replace** (take-ownership + global-only sudoers grant). Online / Type O already **absent on A0 and A1** |
| **A0 ship unit** | Sibling: `{{PROJECTS_ROOT}}/cli-template/src/cli-template` (not in this tree) |
| **A1 ship unit** | Sibling: `{{PROJECTS_ROOT}}/folder-backup/src/folder-backup` (not overwritten from B) |
| **B ship unit** | `src/take-ownership` |
| **A0 / A1 / B channel** | **None** — non-online-installable (local-only install) |
| **A0 domain** | none (Type 0 lifecycle template) |
| **A1 domain** | folder tar.gz backup (not live on B) |
| **B domain** | take ownership of a named folder (`requirement-domain-take-ownership`) |
| **Retired names (not live hops)** | `selfmanaged` — historical folder-backup origin. **Not** a live hop here. |

### 2.3 Architecture inheritance (B from A1, which inherited A0)

B **MUST** inherit structural contracts:

| Layer | Inherit / extend |
|-------|------------------|
| Runtime | POSIX `/bin/sh`, explicit errors |
| Output SSOT | `out_*` family |
| Modular prefixes | `out_`, `inst_`, `util_`, `app_`, `path_`, `prompt_`; domain uses dedicated `to_` prefix (**not** `fb_`) |
| Entry / dispatch | Single `app_main`; always call `app_main "$@"` at end |
| Global flags | `--quiet` / `--json` / `--debug` / `--force` / `--global` plus domain `--path` / `--ownership` |
| Integrity companion | **Absent** |
| Online lifecycle | **Absent** |
| Local lifecycle | **Keep** local `install` / `uninstall` / `where-is-me` |
| Empty argv | **Keep** Type N help |
| Sudoers submit workflow | **Keep** generate / submit / print / per-user fragment / sibling inbound |
| Domain | **Replace** backup/restore with `action` |

### 2.4 Keep / extend matrix (normative for this product)

| Surface | Decision | Notes for take-ownership |
|---------|----------|-------------------------|
| `out_*` output SSOT | **Keep** | Surgical only |
| Modular single-file design | **Keep** | Ship unit under `src/` |
| Global flags + `app_main` | **Keep** | Domain flags added on B |
| Storage resolve | **Keep / adapt** | Scratch for temps; no tar staging as product purpose |
| Idempotency / interactive modes | **Keep / retarget** | `action` idempotent when already matching |
| Online channel | **Absent (inherited)** | Not install source |
| Type O empty argv | **Absent (inherited)** | Empty argv = Type N help |
| Remote `version-check` / `self-update` / `self-uninstall` | **Absent (inherited)** | Unknown commands |
| Companion `.sha256` product law | **Absent (inherited)** | No channel integrity package |
| Local `install` / `uninstall` / `where-is-me` | **Keep** | Local self-managed package |
| USER_BIN sudoers / `--allow-test-local` | **Drop** | Global-only grant (security leak otherwise) |
| Domain backup + retention | **Retire** | Superseded REQs |
| Domain take-ownership + sudoers fragment | **Add** | Domain SSOT |

### 2.5 Identity retarget (B only)

| Concern | B value |
|---------|---------|
| `APP_NAME` | `take-ownership` |
| `VERSION` | ship unit SSOT |
| Primary install story | Local copy from running ship unit; **global** required before grant emit |
| README one-liner | **No** `curl \| sh` channel claim |
| Upstream | New repo later; current origin may still name folder-backup until retargeted |

### 2.6 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **A0** | `cli-template` at `{{PROJECTS_ROOT}}/cli-template` (do not reverse-copy) |
| **A1** | `folder-backup` at `{{PROJECTS_ROOT}}/folder-backup` (do not reverse-copy) |
| **B** | take-ownership (this tree) |
| **Specialize intent** | Same Type 0 local architecture + sudoers submit; domain replace |
| **Install mode** | **local-only** / non-online-installable (not dual-mode) |
| **Domain after specialize** | Active `requirement-domain-take-ownership` |

### 2.7 Why This Requirement Exists (CIAO)

- **Principle 2 – Intentional**: Lineage and domain replace are explicit.  
- **Principle 1 – Caution**: No half-live channel; parents already have none.  
- **Principle 18 / Over-protect**: Reverse-copy is forbidden pollution.  
- **Principle 21 – Dual policies**: Complete B law; portable cores elsewhere.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: Matrix before delete; verify no half-live install.  
- **Intentional**: Explicit keep/extend; registry names absences.  
- **Anti-fragile**: Keep battle-tested `out_*` / modular patterns from A.  
- **Over-protect**: Never reverse-copy; no silent channel reintro.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Reverse-copy `take-ownership` onto `folder-backup` or `cli-template`.  
2. Name `selfmanaged` as this product’s live origin.  
3. Reintroduce Type O install-ensure or `SCRIPT_URL` as product UX.  
4. Leave dual-mode online+local install without an explicit dual-mode matrix and user order.  
5. Drop `out_*` / modular Protection Zones as “part of specialize.”  
6. Invent a second bootstrap origin that contradicts this declaration without updating this file.  
7. Keep `fb_` as the live domain prefix or `backup` as a live verb.

**Violating this rule is a critical bootstrap-direction regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Hop table names A0=cli-template, A1=folder-backup, B=take-ownership, direction ancestor→descendant |
| AC-2 | Keep/extend matrix matches Active registry (online package absent; take-ownership domain present; backup domain superseded) |
| AC-3 | B identity retarget complete (`APP_NAME` take-ownership, local install) |
| AC-4 | Domain SSOT present for take-ownership surface |
| AC-5 | `selfmanaged` is retired history, not a live hop |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-class-software-dev` | Class gate |
| `requirement-shell-local-self-management` | Local lifecycle inherited |
| `requirement-shell-cli-zero-arguments` | Type N empty argv inherited |
| `requirement-domain-take-ownership` | Domain replace |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status | Note |
|----------------|-------|--------|------|
| **TP-CLI-04,10** | `tests/test_cli.sh` | **todo** | online verbs absent |
| **TP-CLI-07** | `tests/test_cli.sh` | **todo** | Type N empty argv |
| **TP-TAKE-OWNERSHIP-*** | `tests/test_domain_take_ownership.sh` | **todo** | domain replace |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-13 | Active 2.0.0 | folder-backup: A=cli-template → B=folder-backup |
| 2026-08-25 | Active 3.0.0 | take-ownership: A0=cli-template → A1=folder-backup → B=take-ownership (domain replace) |

---

**Last Updated**: 2026-08-25  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
