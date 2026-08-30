**file**: docs/requirements/requirement-incorrect-ownership-parameter.md  
**Status**: Active (Version 1.0.0)  
**Area**: architecture  
**Key**: `requirement-incorrect-ownership-parameter`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **product Single Source of Truth** for the **incorrect ownership parameter** fence: `--ownership` on `action`, grant emit, and inbound sudoer JSON **MUST** be an existing host `user:group`. It **MUST NOT** be `*`, a filesystem glob, extra cwd names, or a missing operand.

This is a **product grant / inbound JSON fence** (submitter-side fail closed). It is **not** a dest-approver dest Fence (this CLI has no dest approval machine). Sibling dest still must not approve a globbed request.

JSON grant shape (paths, global binary) remains `requirement-sudoer-json-file`. Runtime chown remains `requirement-take-ownership-ops`.

### 1.1 Human-facing

**In one sentence:** `--ownership` names who will own the folder (`leolio:leolio`); it is not `*` and it is not a list of files from the current directory.

| Box | Meaning | Example |
|-----|---------|---------|
| Correct | One existing `user:group` | `--ownership leolio:leolio` |
| Incorrect | Wildcard | `--ownership *` |
| Incorrect | Directory listing (glob of `*`) | `--ownership AGENTS.md docs src` |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Generate a grant | JSON args end in that `user:group` | `take-ownership generate-sudoer-json --path /dev/shm/genesis-template --ownership leolio:leolio` |
| See cwd names after `--ownership` | Do not approve; regenerate | `generate-sudoer-json --path F --ownership user:group` |

---

## 2. Core Rules / Requirements (Mandatory)

1. `--ownership` **MUST** be exactly one `user:group` (one colon; both sides non-empty; user and group exist on the host).  
2. **MUST NOT** accept `*` as `--ownership` (CLI, text sudoers, or JSON `"*"`).  
3. **MUST NOT** accept extra arguments after `--ownership` (cwd names such as `AGENTS.md`, `docs`, `src`).  
4. Generate / print-sudoers / submit emit **MUST** require `--ownership` the same way `action` does.  
5. When a queued inbound file is readable, submit **MUST** fail closed on (2) or (3) and say **do not approve** the request id.  
6. Operator copy **MUST** name the next command: `generate-sudoer-json --path <folder> --ownership <user:group>`.  
7. **MUST NOT** treat JSON `"*"` as a sudoers operand wildcard for ownership.  
8. JSON `args` keep the live argv `user:group`. The **text dual** (print-sudoers) **MUST** escape `:` as `\:` so visudo parses. That escape is encoding, not a different owner. Peer: `requirement-sudoer-json-file`.

Worked fail body (do not approve):

```json
"args":["action","--path","/dev/shm/genesis-template","--ownership","AGENTS.md","docs","src"]
```

Worked pass body:

```json
"args":["action","--path","/dev/shm/genesis-template","--ownership","leolio:leolio"]
```

---

## 3. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Restore `--ownership *` in grant JSON or sudoers text.  
2. Approve or submit a request whose `--ownership` args are cwd names.  
3. Teach skills to use `--ownership *` in a grant.  
4. Treat dest-approver dest Fence machinery as required for this product because this fence exists (no dest approve on this CLI).

**Violating this rule is a privilege / glob-expansion regression.**

---

## 4. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Generate / action refuse `--ownership *` |
| AC-2 | Generate without `--ownership` fails closed (non-TTY) |
| AC-3 | Gold JSON uses `"--ownership","<user:group>"` even from a dirty cwd (never `"*"`) |
| AC-4 | Submit of globbed or `*` grant JSON fails closed and names generate-sudoer-json |
| AC-5 | print-sudoers Cmnd lines escape `:` in `user:group` (`user\:group`); JSON args stay unescaped |

---

## Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-TAKE-OWNERSHIP-29,29b,29c** | `tests/test_domain_take_ownership.sh` | **have** — `*` / missing ownership fail closed |
| **TP-TAKE-OWNERSHIP-27,27b** | same | **have** — dirty cwd emits `user:group` not `"*"` and not cwd names |
| **TP-TAKE-OWNERSHIP-31** | same | **have** — print-sudoers has escaped `user\:group`, no `--ownership *` |
| **TP-TAKE-OWNERSHIP-28,28b** | same | **have** — globbed and `*` inbound JSON fail closed |

## 5. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-26 | Active 1.0.0 | Ownership fence: no `*`; no glob listings; grant is `user:group` |

**Last Updated**: 2026-08-26  
**Owner**: project maintainers  
**Alignment**: `requirement-sudoer-json-file` · `requirement-take-ownership-ops` · INC-20260823-002 (glob class; `*` is withdrawn as the ownership operand).
