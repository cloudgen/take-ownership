# CLI routed-verb table — take-ownership

**Product:** take-ownership  
**Ship unit:** `src/take-ownership`  
**Dispatcher:** `app_main`  
**Scan date:** 2026-09-30  
**Mode:** incremental (menu tree 3.0.0: sudoers **71–75**, self-management **81–86**; both category names stay unrouted)

## Live

| verb | handler | privilege | last modified date | purpose | human-readable |
|------|---------|-----------|--------------------|---------|----------------|
| version | `app_version` | you | missing | diagnostics | version: Show the local version |
| about | `app_about` | you | 2026-08-26 | diagnostics | about: Show diagnostics including global-bin presence |
| help | `app_help` | you | 2026-09-03 | diagnostics | help: Show this help |
| install | `inst_perform_install` | you | 2026-09-08 | self-managed | install: Ensure this program from the channel |
| uninstall | `inst_self_uninstall` | you | 2026-09-08 | self-managed | uninstall: Alias of self-uninstall |
| self-uninstall | `inst_self_uninstall` | you | 2026-09-08 | self-managed | self-uninstall: Remove the managed binary (not the host grant) |
| self-update | `inst_self_update` | you | 2026-09-08 | self-managed | self-update: Update this program when the channel is newer |
| version-check | `ver_check` | you | 2026-09-08 | self-managed | version-check: Compare local version to the channel |
| where-is-me | `app_where_is_me` | you | 2026-08-03 | self-managed | where-is-me: Show running and install paths |
| list-folders | `to_list_folders` | you | 2026-08-26 | operational | list-folders: List folders this login may take ownership of |
| action | `to_action` | you (re-exec needs change-the-computer after admin grant) | 2026-08-30 | operational | action: Recursively take ownership of a named folder |
| print-sudoers | `to_print_sudoers` | you | 2026-08-26 | operational | print-sudoers: Emit sudoers draft |
| print-sudoers-install-script | `to_print_sudoers_install_script` | you | 2026-08-26 | operational | print-sudoers-install-script: Write admin install script |
| remove-project-sudoers | `to_remove_project_sudoers` | you | 2026-08-09 | operational | remove-project-sudoers: Remove sudoers draft only |
| generate-sudoer-request | `to_generate_sudoer_request` | you | 2026-08-26 | operational | generate-sudoer-request: Write a JSON grant you can read |
| generate-sudoer-json | `to_generate_sudoer_request` | you | 2026-08-26 | test-purpose | generate-sudoer-json: Write the canonical JSON grant for tests (ownership is user:group) |
| submit-sudoer-request | `to_submit_sudoer_request` | you | 2026-08-26 | operational | submit-sudoer-request: Queue the JSON grant inbound |
| menu | `app_main_menu` | you | 2026-09-03 | operational | menu: Show the numbered list of live work commands |
| main | `app_main_menu` | you | 2026-09-03 | operational | main: Same numbered list as menu |

## Not-yet-wired

| verb | handler | privilege | last modified date | purpose | human-readable | status |
|------|---------|-----------|--------------------|---------|----------------|--------|
| setup | — | — | — | — | — | forbidden (not this CLI; sibling inbound setup) |
| backup | — | — | — | — | — | retired (folder-backup domain) |
| restore | — | — | — | — | — | retired (folder-backup domain) |
| sudoers | — | — | — | — | sudoers: Grant and drafts | forbidden (menu-only category; **not** a live dispatcher token) |
| self-management | — | — | — | — | self-management: This CLI install, version, update, uninstall | forbidden (menu-only category; **not** a live dispatcher token) |
| self-install | — | — | — | — | — | absent (menu **87** reserved; channel place is `install` at **81**) |

Do not list `menu` / `main` as choices on their own menu.

Empty argv (`take-ownership` with no command) uses the same handler as `menu` / `main` (`app_main_menu`) on a TTY. Off-TTY empty argv is Type O install-ensure. Off-TTY `menu` / `main` is help.

**Front board** (law `requirement-shell-cli-default-interaction` **3.0.0**): **1** `action`, **7** category `sudoers`, **8** category `self-management`, **9** Exit. Sudoers children **71–75**. Self-management children **81** `install`, **82** `version`, **83** `about`, **84** `version-check`, **85** `self-update`, **86** `self-uninstall`, **0** Back. **87** is reserved and not printed. `where-is-me`, `list-folders`, `help`, `menu`/`main`, and test-purpose `generate-sudoer-json` stay off every numbered list. **`sudoers` and `self-management` are not live dispatcher tokens.** Ship unit `app_main_menu` draws this tree.

## Honesty

Dispatcher tokens on 2026-09-30: version, about, help, install, uninstall, self-uninstall, self-update, version-check, where-is-me, list-folders, action, print-sudoers, print-sudoers-install-script, remove-project-sudoers, generate-sudoer-request, generate-sudoer-json, submit-sudoer-request, menu, main. `self-install` is absent. This product classifies `generate-sudoer-json` as **test-purpose**. The five grant/draft verbs are **operational** (menu **71–75**). `install`, `version`, `about`, `version-check`, `self-update`, and `self-uninstall` are menu **81–86**. Category names `sudoers` and `self-management` are menu-only.

**Last Updated:** 2026-09-30 (menu tree **1 / 7 / 8 / 9**, **0** Back; online self-management rows restored on the kept list)  
**Alignment:** term `cli-routed-verb-table` · **`SK-CLI-ROUTED-VERB-TABLE`** · **`SK-CLI-DEFAULT-INTERACTION`**
