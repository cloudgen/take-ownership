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
| `test_cli.sh` | CLI surface, TTY menu tree **1 / 7 / 8 / 9** (sudoers **71–75**, self-management **81–86**, **0** Back), off-TTY Type O, numbered-list look, cache folder | **TP-CLI-*** (incl. **TP-CLI-13** · **TP-CLI-21..25** · **TP-CLI-19** look · **TP-CACHE-01..03**) |
| `test_local_lifecycle.sh` | install / uninstall / where-is-me (local HTTP channel) | **TP-LC-*** |
| `test_online_curl_install.sh` | `curl \| sh` against a local HTTP channel | **TP-CURL-*** |
| `test_domain_take_ownership.sh` | `action` + grant emit (global-only sudoers JSON) | **TP-TAKE-OWNERSHIP-*** |

## Isolation

- Temp `HOME` + `USER_BIN` + `GLOBAL_BIN` for install and grant tests  
- **No** public network  
- **No** write to `/etc/sudoers.d`  
- Grant emit copies the ship unit into isolated `GLOBAL_BIN` when testing a successful generate/print

## Ship unit under test

`./take-ownership` (`src/take-ownership` is a symlink)

## Maps

Product TP map: `reviews/test-plan.md`  
RTM: `reviews/requirement-test-matrix.md`
