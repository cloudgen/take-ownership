# Tests — take-ownership

## Run

```sh
./tests/run.sh
# or
sh tests/run.sh
```

Exit **0** when all assertions pass; **1** on failure; **2** if ship unit missing.

## Layout

| File | Focus | TP families |
|------|--------|-------------|
| `run.sh` | Entrypoint | — |
| `helpers.sh` | Asserts + isolated HOME | — |
| `test_cli.sh` | CLI surface, Type N empty argv, offline online-reject | **TP-CLI-*** |
| `test_local_lifecycle.sh` | install / uninstall / where-is-me | **TP-LC-*** |
| `test_domain_take_ownership.sh` | `action` + grant emit (global-only sudoers JSON) | **TP-TAKE-OWNERSHIP-*** |

## Isolation

- Temp `HOME` + `USER_BIN` + `GLOBAL_BIN` for install and grant tests  
- **No** public network  
- **No** write to `/etc/sudoers.d`  
- Grant emit copies the ship unit into isolated `GLOBAL_BIN` when testing a successful generate/print

## Ship unit under test

`src/take-ownership`

## Maps

Product TP map: `reviews/test-plan.md`  
RTM: `reviews/requirement-test-matrix.md`
