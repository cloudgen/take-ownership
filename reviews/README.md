# Reviews — take-ownership

Public product review surface (peer of `tests/`).

| File | Role |
|------|------|
| `what-to-review.md` | Living review plan / checklist |
| `test-plan.md` | TP-* status map |
| `requirement-test-matrix.md` | Requirement → TP families |
| `lessons.md` | Durable failure modes to re-check |
| `index.md` | Report index |
| `reports/` | Dated review run reports |
| `cli-routed-verb-table.md` | Live dispatcher inventory |

**Ship unit:** `./take-ownership` (`src/take-ownership` is a symlink) (**VERSION 3.3.0**)  
**Suite:** `./tests/run.sh`  
**Last suite baseline:** see `test-plan.md` (2026-10-14: PASS=517 FAIL=0 SKIP=1)

**Privilege review focus:** global-only grant (`/usr/local/bin/take-ownership`); `action` with `--ownership user:group` (never `*`); `return-original-owner --path` with no `--ownership`; saved line under `/var/take-ownership/original-owner` (root-owned, first observation wins, hostile file fails closed); independent generate; `submit-sudoer-request` public inbound; operator-readable errors; `print-sudoers-install-script`; `remove-project-sudoers` (draft only). **No** `--allow-test-local`. **No** backup/restore.
