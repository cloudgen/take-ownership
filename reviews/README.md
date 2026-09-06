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

**Ship unit:** `src/take-ownership` (**VERSION 2.7.1**)  
**Suite:** `./tests/run.sh`  
**Last suite baseline:** see `test-plan.md`

**Privilege review focus:** global-only grant (`/usr/local/bin/take-ownership`); `--ownership user:group` (never `*`); independent generate; `submit-sudoer-request` public inbound; operator-readable errors; `print-sudoers-install-script`; `remove-project-sudoers` (draft only). **No** `--allow-test-local`. **No** backup/restore.
