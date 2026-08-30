# CLI routed-verb table — take-ownership

**Product:** take-ownership  
**Ship unit:** `src/take-ownership`  
**Dispatcher:** `app_main`  
**Scan date:** 2026-08-30  
**Mode:** full (domain replace)

## Live

| verb | handler | privilege | last modified date | purpose | human-readable |
|------|---------|-----------|--------------------|---------|----------------|
| version | `app_version` | you | missing | diagnostics | version: Show the local version |
| about | `app_about` | you | 2026-08-26 | diagnostics | about: Show diagnostics including global-bin presence |
| help | `app_help` | you | 2026-08-26 | diagnostics | help: Show this help |
| install | `inst_local_install` | you | 2026-08-09 | self-managed | install: Copy this program into your bin or /usr/local/bin |
| uninstall | `inst_local_uninstall` | you | 2026-08-03 | self-managed | uninstall: Remove the managed binary (not the host grant) |
| where-is-me | `app_where_is_me` | you | 2026-08-03 | self-managed | where-is-me: Show running and install paths |
| list-folders | `to_list_folders` | you | 2026-08-26 | operational | list-folders: List folders this login may take ownership of |
| action | `to_action` | you (re-exec needs change-the-computer after admin grant) | 2026-08-30 | operational | action: Recursively take ownership of a named folder |
| print-sudoers | `to_print_sudoers` | you | 2026-08-26 | test-purpose | print-sudoers: Write a grant file an admin can install |
| print-sudoers-install-script | `to_print_sudoers_install_script` | you | 2026-08-26 | test-purpose | print-sudoers-install-script: Write an admin script to install or remove the grant |
| remove-project-sudoers | `to_remove_project_sudoers` | you | 2026-08-09 | operational | remove-project-sudoers: Remove the local grant draft only |
| generate-sudoer-request | `to_generate_sudoer_request` | you | 2026-08-26 | test-purpose | generate-sudoer-request: Write a local JSON grant you can read without sudo |
| generate-sudoer-json | `to_generate_sudoer_request` | you | 2026-08-26 | test-purpose | generate-sudoer-json: Write the canonical JSON grant for tests (ownership is user:group) |
| submit-sudoer-request | `to_submit_sudoer_request` | you | 2026-08-26 | operational | submit-sudoer-request: Hand the JSON grant to the approval queue |
| menu | `app_main_menu` | you | 2026-08-26 | operational | menu: Show the numbered list of live work commands |
| main | `app_main_menu` | you | 2026-08-26 | operational | main: Same numbered list as menu |

## Not-yet-wired

| verb | handler | privilege | last modified date | purpose | human-readable | status |
|------|---------|-----------|--------------------|---------|----------------|--------|
| setup | — | — | — | — | — | forbidden (not this CLI; sibling inbound setup) |
| backup | — | — | — | — | — | retired (folder-backup domain) |
| restore | — | — | — | — | — | retired (folder-backup domain) |

Do not list `menu` / `main` as choices on their own menu.

Empty argv (`take-ownership` with no command) uses the same handler as `menu` / `main` (`app_main_menu`). Off-TTY that path is help.

**Main menu** uses only **operational** rows other than `menu`/`main` **and** other than `list-folders`: action, remove-project-sudoers, submit-sudoer-request. `list-folders` stays a live help verb. Self-managed, diagnostics, and test-purpose stay off the numbered list.

## Honesty

Dispatcher tokens on 2026-08-26: version, about, help, install, uninstall, where-is-me, list-folders, action, print-sudoers, print-sudoers-install-script, remove-project-sudoers, generate-sudoer-request, generate-sudoer-json, submit-sudoer-request, menu, main. Online `self-*` / `version-check` are absent by design. This product classifies `print-sudoers`, `print-sudoers-install-script`, `generate-sudoer-request`, and `generate-sudoer-json` as **test-purpose**.
