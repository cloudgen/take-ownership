**file**: docs/requirements/requirement-bootstrap-chain.md  
**Status**: Active (Version 4.0.0)  
**Area**: architecture  
**Key**: `requirement-bootstrap-chain`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

Declare the **bootstrap chain** for this product: ordered lineage, direction, architecture inheritance, and the **online-install hop** from sibling selfmanaged while keeping the take-ownership domain.

**Direction is sacred:** ancestor → descendant only. Never reverse-copy this product onto selfmanaged, folder-backup, or cli-template.

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
| Online-install channel inherited from selfmanaged | Dual-class local-only + online without a matrix |

| Surface | What you open | What for |
|---------|---------------|----------|
| `docs/requirements/index.md` | registry | live law |
| `./take-ownership` | ship unit | B identity |

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
| **Hop 0 (history)** | `cli-template` then `folder-backup` — domain/sudoers architecture already on B |
| **Live hop A** | `selfmanaged` — Type 0 online-installable sibling `{{PROJECTS_ROOT}}/selfmanaged` |
| **Leaf / B** | `take-ownership` — this workspace product |
| **Immediate origin of leaf (this hop)** | `selfmanaged` |
| **Specialize mode** | **Keep online Type 0** from A + **keep domain** already on B (take-ownership + global-only sudoers grant) |
| **A ship unit** | Sibling: `{{PROJECTS_ROOT}}/selfmanaged/selfmanaged` (not overwritten from B) |
| **B ship unit** | `./take-ownership` (repo root; `src/take-ownership` symlink) |
| **A channel** | `https://raw.githubusercontent.com/cloudgen/selfmanaged/main/selfmanaged` |
| **B channel** | `https://raw.githubusercontent.com/cloudgen/take-ownership/main/take-ownership` |
| **A domain** | none (Type 0 lifecycle bootstrap) |
| **B domain** | take ownership of a named folder (`requirement-domain-take-ownership`) |

### 2.3 Architecture inheritance (B from A1, which inherited A0)

B **MUST** inherit structural contracts:

| Layer | Inherit / extend |
|-------|------------------|
| Runtime | POSIX `/bin/sh`, explicit errors |
| Output SSOT | `out_*` family |
| Modular prefixes | `out_`, `inst_`, `util_`, `app_`, `path_`, `prompt_`; domain uses dedicated `to_` prefix (**not** `fb_`) |
| Entry / dispatch | Single `app_main`; always call `app_main "$@"` at end |
| Global flags | `--quiet` / `--json` / `--debug` / `--force` / `--global` plus domain `--path` / `--ownership` |
| Integrity companion | **Keep** automatic `${SCRIPT_URL}.sha256` from A |
| Online lifecycle | **Keep** `install` / `version-check` / `self-update` / `self-uninstall` from A |
| Local checkout copy-only install | **Replace** with online ensure (`inst_perform_install`) |
| Empty argv | **Keep** Type O off-TTY from A; **extend** TTY empty argv → numbered list |
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
| Online channel | **Keep** | B’s own `SCRIPT_URL` (not A’s) |
| Type O empty argv | **Keep / extend** | Off-TTY = install-ensure; TTY = numbered list |
| Remote `version-check` / `self-update` / `self-uninstall` | **Keep** | Online package |
| Companion `.sha256` product law | **Keep** | `take-ownership.sha256` |
| `install` / `where-is-me` | **Keep / retarget** | `install` is channel ensure; `uninstall` aliases `self-uninstall` |
| USER_BIN sudoers / `--allow-test-local` | **Drop** | Global-only grant (security leak otherwise) |
| Domain backup + retention | **Retire** | Superseded REQs |
| Domain take-ownership + sudoers fragment | **Add** | Domain SSOT |

### 2.5 Identity retarget (B only)

| Concern | B value |
|---------|---------|
| `APP_NAME` | `take-ownership` |
| `VERSION` | ship unit SSOT |
| Primary install story | `curl -fsSL https://raw.githubusercontent.com/cloudgen/take-ownership/main/take-ownership \| sh`; **global** still required before grant emit |
| README one-liner | **Yes** — B’s `SCRIPT_URL` |
| Upstream | New repo later; current origin may still name folder-backup until retargeted |

### 2.6 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **A** | `selfmanaged` at `{{PROJECTS_ROOT}}/selfmanaged` (do not reverse-copy) |
| **History** | `cli-template` / `folder-backup` remain architecture ancestors of the domain (do not reverse-copy) |
| **B** | take-ownership (this tree) |
| **Specialize intent** | Same Type 0 online architecture as selfmanaged + existing take-ownership domain |
| **Install mode** | **online-installable** (not dual-class) |
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

1. Reverse-copy `take-ownership` onto `selfmanaged`, `folder-backup`, or `cli-template`.  
2. Point B’s default `SCRIPT_URL` at selfmanaged’s channel.  
3. Drop Type O off-TTY install-ensure while claiming `curl \| sh`.  
4. Leave dual-mode online+local install without an explicit dual-mode matrix and user order.  
5. Drop `out_*` / modular Protection Zones as “part of specialize.”  
6. Invent a second bootstrap origin that contradicts this declaration without updating this file.  
7. Keep `fb_` as the live domain prefix or `backup` as a live verb.

**Violating this rule is a critical bootstrap-direction regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Hop table names A=selfmanaged, B=take-ownership, direction ancestor→descendant |
| AC-2 | Keep/extend matrix matches Active registry (online package present; take-ownership domain present) |
| AC-3 | B identity retarget complete (`APP_NAME` take-ownership, B `SCRIPT_URL`) |
| AC-4 | Domain SSOT present for take-ownership surface |
| AC-5 | A ship unit is not overwritten from B |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-class-software-dev` | Class gate |
| `requirement-shell-self-management` | Online lifecycle inherited |
| `requirement-shell-cli-zero-arguments` | TTY menu / off-TTY Type O |
| `requirement-domain-take-ownership` | Domain replace |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status | Note |
|----------------|-------|--------|------|
| **TP-CLI-04** | `tests/test_cli.sh` | **have** | online verbs listed |
| **TP-CLI-07** | `tests/test_cli.sh` | **have** | off-TTY empty argv Type O; TTY menu |
| **TP-CURL-*** | `tests/test_online_curl_install.sh` | **have** | local HTTP `curl\|sh` |
| **TP-TAKE-OWNERSHIP-*** | `tests/test_domain_take_ownership.sh` | **todo** | domain replace |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-13 | Active 2.0.0 | folder-backup: A=cli-template → B=folder-backup |
| 2026-08-25 | Active 3.0.0 | take-ownership: A0=cli-template → A1=folder-backup → B=take-ownership (domain replace) |
| 2026-08-30 | Active 3.1.0 | Empty argv stays Type N (never install) and routes to the numbered list |
| 2026-09-08 | Active 4.0.0 | Live hop A=selfmanaged; online Type O + companion checksum; TTY menu kept |

---

**Last Updated**: 2026-08-30  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
