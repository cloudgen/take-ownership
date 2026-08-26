**file**: docs/requirements/requirement-shell-sudo-command.md  
**Status**: Active (Version 1.0.0)  
**Area**: shell  
**Key**: `requirement-shell-sudo-command`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **product Single Source of Truth** for **in-tool sudo**: the only call site (`util_sudo`), **check before sudo**, and the chmod example.

**Without this file, agents bring portable sudo-wrapping lessons raw** or scatter `sudo` through domain functions.

Coding-style **points** here. Class residual **points** here. Runtime `action` re-exec is owned with `requirement-take-ownership-ops`; this file owns **how** sudo is invoked.

### 1.1 Human-facing

**In one sentence:** The program never sprinkles `sudo` in random places; it asks “can I already do this?” and only then calls one wrapper.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Already root → no sudo | `sudo take-ownership action …` already euid 0 |
| The wrapper | Single `util_sudo` | re-exec `/usr/local/bin/take-ownership …` |
| Not this file | Which argv is allowlisted | `requirement-sudoer-json-file` |

| Includes | Excludes |
|----------|----------|
| One sudo wrapper; probe before elev | Raw `sudo` in `to_action` |
| chmod helper as the mode example | Putting `chmod` / `chown` in sudoers |

| Surface | What you open | What for |
|---------|---------------|----------|
| `./src/take-ownership` | ship unit | `util_sudo` / `util_chmod` |
| `take-ownership action` | command | re-exec path |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Run `action` as yourself | Wrapper uses `sudo -n` of the **global** binary after a non-sudo probe | `take-ownership action --path /var/www/html --ownership www-data:www-data` |
| Run already as root | No `sudo` prefix | `sudo take-ownership action --path /var/www/html --ownership www-data:www-data` |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Sudo-wrapping function

1. In-tool `sudo` **MUST** go through **`util_sudo`**. **MUST NOT** scatter raw `sudo`.  
2. If `id -u` is 0, `util_sudo` **MUST** run the command **without** `sudo`.  
3. If `sudo` is missing from `PATH`, **MUST** fail closed (no hang).  
4. For `action` re-exec after a NOPASSWD grant, **MAY** use `sudo -n` of **`${GLOBAL_BIN}/take-ownership`** only. **MUST NOT** copy `sudo -n` onto first-time `install --global` / unrelated tools.  
5. **MUST NOT** `sudo /bin/chown` or `sudo chmod` as the take-ownership mechanism (chown is inside the elevated ship unit).

### 2.2 Check before sudo

**Before any `sudo <cmd>`**, run a **non-sudo** probe. If this login **already can** do the job, **MUST NOT** `sudo`.

| # | Rule |
|---|------|
| **C0** | Class: every in-tool `sudo <cmd>`. chmod is the **example**, not the only case. |
| **C1** | Probe with a **non-sudo** command. chmod example: POSIX `[ -O path ]`. `action` example: `id -u` (already root) **or** the path is already `user:group` (then no elev — success no-op on `requirement-take-ownership-ops`). |
| **C2** | Probe match → **MUST NOT** `sudo`. |
| **C3** | `sudo` **MAY** run only when the probe misses. |
| **C4** | **MUST NOT** probe with `sudo` (`sudo ls`, `sudo stat`, `sudo -n stat`). |
| **C5** | Already-root already can — run the tool without `sudo`. |
| **C6** | chmod example **MUST** go through `util_chmod` that applies C1–C2. |

### 2.3 Complete samples (this product)

```sh
util_sudo() {
    if [ "$(id -u 2>/dev/null || echo 1)" -eq 0 ]; then
        "$@"
        return $?
    fi
    command -v sudo >/dev/null 2>&1 || return 1
    sudo "$@"
}

util_chmod() {
    _mode="${1:-}"
    _path="${2:-}"
    [ -n "${_mode}" ] && [ -n "${_path}" ] || return 1
    [ -e "${_path}" ] || return 1
    if [ -O "${_path}" ]; then
        chmod "${_mode}" "${_path}"
        return $?
    fi
    util_sudo chmod "${_mode}" "${_path}"
}
```

`action` re-exec (normative shape; names may match ship unit):

```sh
# After validation; only when not already root and ownership still differs.
util_sudo -n /usr/local/bin/take-ownership action --path "${TO_PATH}" --ownership "${TO_OWNERSHIP}"
```

**MUST NOT** pass `${USER_BIN}/take-ownership` or `$0` when that path is user-writable.

### 2.4 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `take-ownership` |
| **Wrapper** | `util_sudo` |
| **chmod helper** | `util_chmod` |
| **Production re-exec** | `sudo -n /usr/local/bin/take-ownership action --path F --ownership U:G` |
| **Coding-style peer** | `requirement-shell-script-coding` (points here) |

### 2.5 Why This Requirement Exists (CIAO)

- **Principle 10 – Least privilege**: No sudo when already able.  
- **Principle 22 – File modes**: chmod example checks owner first.  
- **Principle 2 – Intentional**: One wrapper; domain does not invent a second.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Probe without sudo.  
- **Intentional:** One call site.  
- **Anti-fragile:** Already-root path works without `sudo` in PATH.  
- **Over-protect:** No USER_BIN re-exec.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Scatter raw `sudo` outside `util_sudo`.  
2. Probe with `sudo ls` / `sudo stat`.  
3. `sudo` when `[ -O path ]` already allows chmod.  
4. Re-exec a user-writable binary.  
5. Put `chmod` / `chown` into sudoers because the wrapper exists.  
6. Default first-time global install to `sudo -n`.

**Violating this rule is a critical elevation regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Only `util_sudo` invokes `sudo` |
| AC-2 | euid 0 does not call `sudo` |
| AC-3 | `util_chmod` uses `[ -O` before sudo |
| AC-4 | `action` re-execs `/usr/local/bin/take-ownership` |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-script-coding` | Points here for wrapper bodies |
| `requirement-take-ownership-ops` | When re-exec happens |
| `requirement-three-layer-privilege-model` | Allowlist |
| `docs/requirements/index.md` | Registry |
| `./src/take-ownership` | Implementation under test |

---

## Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-TAKE-OWNERSHIP-40** | `tests/test_cli.sh` | **todo** — no raw `sudo` outside wrapper (review/grep) |
| **TP-TAKE-OWNERSHIP-41** | `tests/test_domain_take_ownership.sh` | **todo** — euid 0 `action` does not invoke sudo |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-25 | Active 1.0.0 | Specialize-in home for in-tool sudo on take-ownership |

---

**Last Updated**: 2026-08-25  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
