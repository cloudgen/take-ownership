# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| 3.0.1 (current) | Yes |
| 3.0.0 | Yes |
| 2.7.1 | Yes |
| 2.7.0 | Yes |
| 2.6.0 | Yes |
| 2.5.0 | Yes |
| 2.4.1 | Yes |
| 2.4.0 | Yes |
| 2.3.0 | Yes |
| 2.2.0 | Yes |
| 2.1.0 | Yes |
| 2.0.0 | Yes |
| 1.11.0 | Yes |
| 1.10.0 | Yes |
| 1.9.0 | Yes |
| 1.8.2 | Yes |
| 1.7.0 | Yes |
| 1.6.x | Yes |
| 1.5.x | Best-effort |
| 1.4.x | Best-effort |
| 1.3.x | Best-effort |
| 1.2.x | Best-effort |
| Older releases | Best-effort only |

## Reporting a Vulnerability

Please **do not** open a public issue for security-sensitive reports when a private channel is available.

**Maintainer contact (email):** `wongcf22@gmail.com`

- Source of contact: product **author-email** SSOT in [`LICENSE.md`](./LICENSE.md) (Copyright line).  
- Prefer email (or private GitHub security advisories when enabled) for vulnerability details, reproduction steps, and impact.  
- Do not include exploit weaponization guides in public channels.

## Security Design Principles (CIAO)

This project follows **[CIAO](https://github.com/cloudgen/ciao)** / **[CIAO-Lite](https://github.com/cloudgen/ciao-lite)** defensive design. Security-relevant intent:

| Letter | Principle | Security application |
|--------|-----------|----------------------|
| **C** | **Caution** | Stop without the global binary and a matching grant; refuse system roots and symlink `--path`. |
| **I** | **Intentional** | You generate/submit; `action` elevates only `/usr/local/bin/take-ownership`; `print-sudoers` never writes `/etc`. |
| **A** | **Anti-fragile** | Already-matching owner is success; clear next-step errors when the grant is missing or the folder is gone. |
| **O** | **Over-protect** | `~/.local/bin` is never in sudoers; no `/bin/chown`; no `NOPASSWD: ALL`; no `--allow-test-local`. |

Full principles: [CIAO](https://github.com/cloudgen/ciao) · [CIAO-Lite](https://github.com/cloudgen/ciao-lite).

This section is **design posture**, not a third-party certification claim.

## Scope notes

- Elevation is limited to the **global** program `action --path <one-folder> --ownership <user:group>` (plus the `--json` twin) under product law.  
- Operators must admin-install sudoers fragments after review (`visudo -c`, mode `0440`).  
- **Install trust for elevation:**
  - **Production:** global managed binary (`/usr/local/bin/take-ownership`, typically root-owned). Prefer `sudo curl … | sudo sh` (or `sudo take-ownership install`) before durable sudoers. Online install verifies `${SCRIPT_URL}.sha256` when the sidecar is present.  
  - **Local `~/.local/bin/take-ownership` is user-rewritable.** Grant emit **stops** unless the global program exists. Do **not** write the user-bin path into sudoers.  
  - **`--allow-test-local` is absent** (forbidden). There is no test-mode sudoers path.  
  - **`print-sudoers-install-script`** writes an admin handoff script under `/dev/shm` (or temp) that a sudo-capable account runs for `install` / `uninstall` / `replace` of this login’s fragment — the CLI never writes `/etc` itself.  
  - **Per-user host paths:** draft `~/.config/take-ownership/sudoers.fragment-<user>` installs to `/etc/sudoers.d/take-ownership-<user>` so multi-user admin installs do not overwrite each other.  
  - Uninstall of the binary does **not** remove `/etc/sudoers.d/take-ownership-<user>` — use `sudo sh <admin-script> uninstall` (or admin `rm`) when leaving elevation.  
  - **`remove-project-sudoers`** deletes drafts only; when multiple drafts exist it lists them for interactive choice (non-interactive needs an explicit path).  
- Related docs: [`README.md`](./README.md), [`LICENSE.md`](./LICENSE.md), `docs/requirements/requirement-three-layer-privilege-model.md`.
