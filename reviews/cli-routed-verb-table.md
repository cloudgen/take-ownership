# CLI routed-verb table — take-ownership

**Product:** take-ownership  
**Ship unit:** `src/take-ownership`  
**Dispatcher:** `app_main`  
**Scan date:** 2026-09-03  
**Mode:** incremental (family sudoers submenu + grant-draft verbs remain live)

## Live

| verb | handler | privilege | last modified date | purpose | human-readable |
|------|---------|-----------|--------------------|---------|----------------|
| version | `app_version` | you | missing | diagnostics | version: Show the local version |
| about | `app_about` | you | 2026-08-26 | diagnostics | about: Show diagnostics including global-bin presence |
| help | `app_help` | you | 2026-09-03 | diagnostics | help: Show this help |
| install | `inst_local_install` | you | 2026-08-09 | self-managed | install: Copy this program into your bin or /usr/local/bin |
| uninstall | `inst_local_uninstall` | you | 2026-08-03 | self-managed | uninstall: Remove the managed binary (not the host grant) |
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
| sudoers | — | — | — | — | sudoers: Grant and drafts | forbidden (menu-only family row; **not** a live dispatcher token) |

Do not list `menu` / `main` as choices on their own menu.

Empty argv (`take-ownership` with no command) uses the same handler as `menu` / `main` (`app_main_menu`). Off-TTY that path is help.

**Main menu** uses only **operational** rows other than `menu`/`main` **and** other than `list-folders`: **action**, then family **sudoers**. The five grant/draft verbs live on the **sudoers** submenu (Back **8**, Exit **9**). `list-folders` stays a live help verb. Self-managed, diagnostics, and test-purpose (`generate-sudoer-json`) stay off both numbered lists. **`sudoers` is not a live dispatcher token.** Main **N = 2**; submenu **K = 5**; **Exit 9**.

## Honesty

Dispatcher tokens on 2026-09-03: version, about, help, install, uninstall, where-is-me, list-folders, action, print-sudoers, print-sudoers-install-script, remove-project-sudoers, generate-sudoer-request, generate-sudoer-json, submit-sudoer-request, menu, main. Online `self-*` / `version-check` are absent by design. This product classifies `generate-sudoer-json` as **test-purpose**. The five grant/draft verbs are **operational** (submenu). Family `sudoers` is menu-only.

**Last Updated:** 2026-09-03 (family **sudoers** submenu; five grant/draft verbs operational)  
**Alignment:** term `cli-routed-verb-table` · **`SK-CLI-ROUTED-VERB-TABLE`** · **`SK-CLI-DEFAULT-INTERACTION`**
