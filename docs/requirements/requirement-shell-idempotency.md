**file**: docs/requirements/requirement-shell-idempotency.md  
**Status**: Active (Version 1.0.0)  
**Area**: shell  
**Key**: `requirement-shell-idempotency`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for **idempotency (re-run safety)** of state-changing operations in the take-ownership POSIX shell CLI.

**Informal formula:** for ensure-style operation *f* and system state *x*, **f(f(x)) ≈ f(x)** for the **desired outcome** (logs and timestamps may differ).

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 What must be idempotent

Every **state-changing** shell operation that **ensures** a desired configuration **MUST**:

1. **Detect** whether the desired state already holds.  
2. **Skip or no-op** unsafe work when it does.  
3. **Succeed** when already achieved — **MUST NOT** fail solely because state “already exists.”  
4. **Avoid duplicates** (binary installs, PATH lines, identical archive slot collisions handled by numbering).  
5. **Leave the system consistent** on every run (including partial prior installs).  
6. **Communicate** clearly when already done in human mode; respect quiet/json via output SSOT.

### 2.2 What a second run must not do

| Forbidden when desired state already holds | Prefer |
|--------------------------------------------|--------|
| Fail solely because state exists | Success + “already installed / nothing to uninstall” |
| Create duplicate managed binaries | Existence check first |
| Overwrite a correct install without force | No-op unless force |
| Leave half-applied worse state | Atomic steps; cleanup temps; fail loud |

### 2.3 Force override

Force policy (`--force` / `FORCE=1`) **MAY** re-apply ensure steps that would otherwise no-op **only** when documented. Force **MUST NOT** silently skip integrity or path validation for domain deposit.

### 2.4 Implementation Notes — command matrix (this project)

| Command / path | Desired state | Re-run when already good | Force / special |
|----------------|---------------|--------------------------|-----------------|
| `install` | Managed binary present at privilege-correct path | Success no-op | `--force` replaces from running ship unit |
| `uninstall` | Managed binary absent | Success no-op | `--force` skips confirm |
| `where-is-me` / `version` / `about` / `help` | Read-only | Always safe | N/A |
| `print-sudoers` | Emit fragment text | Safe re-print (same content for same user/host defaults) | Does not install into `/etc` |
| `generate-sudoer-request` | Local verified JSON grant at dest path | Overwrite same dest (draft) | Does not write `/etc` or inbound |
| `submit-sudoer-request` | Queue a **new** JSON request (sibling allocates next `n`) | Each success is a new `request_id`; not a no-op | Does not write `/etc`; does not `mkdir` inbound; missing inbound fails closed |
| `action` | Named folder already has `--ownership` | Success no-op (idempotent chown) | `--force` does **not** bypass refuse-list or missing identity |

### 2.5 Domain idempotency

`action` **MUST** succeed without rewriting inodes when the tree already matches `--ownership` (`requirement-take-ownership-ops`). Sibling submit still allocates a **new** request `n` each success (not a no-op).

### 2.6 Why This Requirement Exists (CIAO)

- **Principle 1 – Caution**: Re-runs must not corrupt installs.  
- **Principle 3 – Anti-fragile**: Safe to re-invoke.  
- **Principle 10 – Least privilege**: Already-matching ownership is not a second elev.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- Detect → ensure → success-if-done for lifecycle.  
- Domain `action` is **ensure-same-owner**, not additive archives.  
- Fail closed on permission and path errors (idempotency ≠ never error).

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Make `install` fail when already installed (force off).  
2. Fail `action` solely because the folder is already the requested owner:group.  
3. Treat idempotency as permission to ignore validation failures.  
4. Remove atomic install/stage patterns for “speed.”

**Violating this rule is a critical re-run safety regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Second `install` without force is success no-op |
| AC-2 | Second `uninstall` when absent is success no-op |
| AC-3 | Second `action` on an already-matching tree is success no-op |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-local-self-management` | Install/uninstall ensure |
| `requirement-take-ownership-ops` | `action` already-matching success |
| `requirement-shell-cli-interface` | Force flag wiring |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-LC-03,07** | `tests/test_local_lifecycle.sh` | have |
| **TP-TAKE-OWNERSHIP-13** | `tests/test_domain_take_ownership.sh` | **todo** — already matching is success |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active | Idempotency for local lifecycle + archive numbering |

---

**Last Updated**: 2026-08-03  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
