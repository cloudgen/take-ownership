# =============================================================================
# tests/test_cli.sh — CLI surface (local-only; no network)
# =============================================================================
# Primary REQs: requirement-shell-cli-interface, requirement-shell-cli-zero-arguments,
# requirement-shell-output-requirements, requirement-shell-cli-storage
# TP family: TP-CLI-*
# =============================================================================

# shellcheck source=helpers.sh
. "${TESTS_ROOT}/helpers.sh"

run_test_cli() {
    t_header "CLI surface (TP-CLI)"

    require_cmd sh
    require_cmd grep
    require_cmd id

    # TP-CLI-01 syntax
    sh -n "${SCRIPT}"
    assert_eq "TP-CLI-01 sh -n ship unit" 0 "$?"

    # TP-CLI-02 version human
    _out=$(sh "${SCRIPT}" version 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-02 version exit 0" 0 "$_ec"
    assert_contains "TP-CLI-02 version mentions app" "$_out" "${APP_NAME}"
    assert_contains "TP-CLI-02 version mentions VERSION" "$_out" "${PRODUCT_VERSION}"

    # TP-CLI-03 version json
    _out=$(sh "${SCRIPT}" --json version 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-03 version --json exit 0" 0 "$_ec"
    assert_contains "TP-CLI-03 type version" "$_out" '"type":"version"'
    assert_contains "TP-CLI-03 app field" "$_out" "\"app\":\"${APP_NAME}\""
    assert_contains "TP-CLI-03 version field" "$_out" "\"version\":\"${PRODUCT_VERSION}\""

    # TP-CLI-04 help lists local lifecycle + domain; not online verbs
    _out=$(sh "${SCRIPT}" help 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-04 help exit 0" 0 "$_ec"
    assert_contains "TP-CLI-04 help install" "$_out" "install"
    assert_contains "TP-CLI-04 help uninstall" "$_out" "uninstall"
    assert_contains "TP-CLI-04 help where-is-me" "$_out" "where-is-me"
    assert_contains "TP-CLI-04 help list-folders" "$_out" "list-folders"
    assert_contains "TP-CLI-04 help action" "$_out" "action --path"
    assert_contains "TP-CLI-04 help --ownership" "$_out" "--ownership"
    assert_not_contains "TP-CLI-04 no backup command" "$_out" "backup <folder>"
    assert_not_contains "TP-CLI-04 no restore command" "$_out" "restore <archive"
    assert_contains "TP-CLI-04 help print-sudoers" "$_out" "print-sudoers"
    assert_contains "TP-CLI-04 help install-script" "$_out" "print-sudoers-install-script"
    assert_contains "TP-CLI-04 help remove-project-sudoers" "$_out" "remove-project-sudoers"
    assert_contains "TP-CLI-04 help submit-sudoer-request" "$_out" "submit-sudoer-request"
    assert_contains "TP-CLI-04 help generate-sudoer-request" "$_out" "generate-sudoer-request"
    assert_contains "TP-CLI-04 help generate-sudoer-json" "$_out" "generate-sudoer-json"
    assert_contains "TP-CLI-04 help star is operand" "$_out" "not a directory listing"
    assert_contains "TP-CLI-04 help public inbound" "$_out" "/var/sudoer-cli/sudoer-request"
    assert_contains "TP-CLI-04 help --update" "$_out" "--update"
    assert_contains "TP-CLI-04 help --add" "$_out" "--add"
    assert_contains "TP-CLI-04 help SUDOER_PUBLIC_ROOT" "$_out" "SUDOER_PUBLIC_ROOT"
    assert_contains "TP-CLI-04 help --path" "$_out" "--path PATH"
    assert_contains "TP-CLI-04 help --json" "$_out" "--json"
    assert_contains "TP-CLI-04 help menu" "$_out" "Numbered list of live work commands"
    assert_contains "TP-CLI-04 help main" "$_out" "Same as menu"
    assert_not_contains "TP-CLI-04 no self-update" "$_out" "self-update"
    assert_not_contains "TP-CLI-04 no self-uninstall" "$_out" "self-uninstall"
    assert_not_contains "TP-CLI-04 no version-check" "$_out" "version-check"
    assert_not_contains "TP-CLI-04 no SCRIPT_URL channel" "$_out" "SCRIPT_URL"
    assert_not_contains "TP-CLI-04 no CHECKSUM" "$_out" "CHECKSUM"

    # TP-CLI-05 help json
    _out=$(sh "${SCRIPT}" --json help 2>/dev/null)
    assert_eq "TP-CLI-05 help --json exit 0" 0 "$?"
    assert_contains "TP-CLI-05 help json success" "$_out" '"type":"success"'

    # TP-CLI-06 about json domain + storage, no channel
    _out=$(sh "${SCRIPT}" --json about 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-06 about --json exit 0" 0 "$_ec"
    assert_contains "TP-CLI-06 type about" "$_out" '"type":"about"'
    assert_contains "TP-CLI-06 effective_storage" "$_out" '"effective_storage"'
    assert_contains "TP-CLI-06 global_bin_present" "$_out" '"global_bin_present"'
    assert_contains "TP-CLI-06 global_bin" "$_out" '"global_bin"'
    assert_contains "TP-CLI-06 sudoer_cli" "$_out" '"sudoer_cli"'
    assert_contains "TP-CLI-06 sudoer_adm" "$_out" '"sudoer_adm"'
    assert_contains "TP-CLI-06 sudoer_inbound" "$_out" '"sudoer_inbound"'
    assert_contains "TP-CLI-06 host_sudoers_present" "$_out" '"host_sudoers_present"'
    assert_not_contains "TP-CLI-06 no backup_notation" "$_out" "backup_notation"
    assert_not_contains "TP-CLI-06 no CHECKSUM" "$_out" "CHECKSUM"
    assert_not_contains "TP-CLI-06 no SCRIPT_URL" "$_out" "SCRIPT_URL"

    # TP-CLI-07 empty argv = Type N help (not install)
    _out=$(sh "${SCRIPT}" 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-07 empty argv exit 0" 0 "$_ec"
    assert_contains "TP-CLI-07 empty argv is help" "$_out" "Usage:"
    assert_contains "TP-CLI-07 empty argv mentions Type N or help" "$_out" "help"

    # TP-CLI-08 unknown command fail-closed
    _err=$(sh "${SCRIPT}" no-such-command 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CLI-08 unknown exit 1" 1 "$_ec"
    assert_contains "TP-CLI-08 unknown error text" "$_err" "Unknown command"

    _err=$(sh "${SCRIPT}" --json no-such-command 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CLI-08 unknown --json exit 1" 1 "$_ec"
    assert_contains "TP-CLI-08 unknown --json type" "$_err" '"type":"out_error"'

    # TP-CLI-09 quiet suppresses version info
    _out=$(sh "${SCRIPT}" --quiet version 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-09 quiet version exit 0" 0 "$_ec"
    _trim=$(printf '%s' "$_out" | tr -d ' \t\n\r')
    if [ -z "$_trim" ]; then
        t_pass "TP-CLI-09 quiet suppresses human version"
    else
        t_fail "TP-CLI-09 quiet expected empty stdout, got '$(_trunc "$_out")'"
    fi

    # TP-CLI-10 online verbs rejected
    _err=$(sh "${SCRIPT}" self-update 2>&1 >/dev/null)
    assert_eq "TP-CLI-10 self-update exit 1" 1 "$?"
    assert_contains "TP-CLI-10 self-update unknown" "$_err" "Unknown command"

    _err=$(sh "${SCRIPT}" version-check 2>&1 >/dev/null)
    assert_eq "TP-CLI-10 version-check exit 1" 1 "$?"

    _err=$(sh "${SCRIPT}" backup 2>&1 >/dev/null)
    assert_eq "TP-CLI-10 backup unknown exit 1" 1 "$?"
    assert_contains "TP-CLI-10 backup unknown" "$_err" "Unknown command"

    _err=$(sh "${SCRIPT}" restore 2>&1 >/dev/null)
    assert_eq "TP-CLI-10 restore unknown exit 1" 1 "$?"

    _err=$(sh "${SCRIPT}" --allow-test-local help 2>&1 >/dev/null)
    assert_eq "TP-CLI-10 no allow-test-local exit 1" 1 "$?"

    # TP-CLI-11 set -u HOME unset still works for version
    _out=$(env -u HOME sh "${SCRIPT}" version 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-11 env -u HOME version exit 0" 0 "$_ec"
    assert_contains "TP-CLI-11 env -u HOME version text" "$_out" "${PRODUCT_VERSION}"

    # TP-CLI-12 storage isolation under temp HOME
    ci_isolated_env
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${SCRIPT}" --json about 2>/dev/null)
    assert_contains "TP-CLI-12 isolated about has app in storage" "$_out" "${APP_NAME}"
    _eff=$(printf '%s' "$_out" | sed -n 's/.*"effective_storage":"\([^"]*\)".*/\1/p' | head -n1)
    if [ -n "$_eff" ] && [ -d "$_eff" ]; then
        t_pass "TP-CLI-12 effective_storage directory exists"
    else
        t_fail "TP-CLI-12 effective_storage missing: '${_eff:-empty}'"
    fi
    ci_cleanup_env

    # TP-CLI-15 non-interactive menu is help; --json JSON help; empty argv stays help
    _out=$(sh "${SCRIPT}" menu 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-15 menu off-TTY exit 0" 0 "$_ec"
    assert_contains "TP-CLI-15 menu off-TTY is help" "$_out" "Usage:"
    assert_not_contains "TP-CLI-15 menu off-TTY not the numbered list" "$_out" "9. Exit"

    _out=$(sh "${SCRIPT}" main 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-15 main off-TTY exit 0" 0 "$_ec"
    assert_contains "TP-CLI-15 main off-TTY is help" "$_out" "Usage:"

    _out=$(sh "${SCRIPT}" --json menu 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-15 menu --json off-TTY exit 0" 0 "$_ec"
    assert_contains "TP-CLI-15 menu --json off-TTY JSON help" "$_out" '"type":"success"'
    assert_not_contains "TP-CLI-15 menu --json off-TTY not numbered list" "$_out" "9. Exit"

    _out=$(sh "${SCRIPT}" 2>/dev/null)
    assert_not_contains "TP-CLI-15 empty argv not numbered list" "$_out" "9. Exit"
    assert_contains "TP-CLI-15 empty argv still help" "$_out" "Usage:"

    _out=$(sh "${SCRIPT}" --quiet menu 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-15 menu --quiet off-TTY exit 0" 0 "$_ec"
    assert_contains "TP-CLI-15 menu --quiet off-TTY still help" "$_out" "Usage:"

    assert_contains "TP-CLI-15 help lists menu" "$(sh "${SCRIPT}" help 2>/dev/null)" "Numbered list of live work commands"
    assert_contains "TP-CLI-15 help lists main" "$(sh "${SCRIPT}" help 2>/dev/null)" "Same as menu"

    if command -v python3 >/dev/null 2>&1; then
        _out=$(PTY_IN="9" ci_pty_run menu)
        assert_contains "TP-CLI-13 TTY menu action row" "$_out" "1. action: Recursively take ownership of a named folder"
        assert_contains "TP-CLI-13 TTY menu list-folders row" "$_out" "2. list-folders: List folders this login may take ownership of"
        assert_contains "TP-CLI-13 TTY menu remove row" "$_out" "3. remove-project-sudoers: Remove the local grant draft only"
        assert_contains "TP-CLI-13 TTY menu submit row" "$_out" "4. submit-sudoer-request: Hand the JSON grant to the approval queue"
        assert_contains "TP-CLI-13 TTY menu Exit 9" "$_out" "9. Exit"
        assert_not_contains "TP-CLI-13 TTY menu no backup row" "$_out" "1. backup:"

        _out=$(PTY_IN="9" ci_pty_run --json menu)
        assert_contains "TP-CLI-14 TTY menu --json still numbered list" "$_out" "9. Exit"
        assert_contains "TP-CLI-14 TTY menu --json action row" "$_out" "1. action: Recursively take ownership"
        assert_not_contains "TP-CLI-14 TTY menu --json ignores JSON help" "$_out" '"type":"success"'

        _out=$(PTY_IN="9" ci_pty_run menu)
        assert_not_contains "TP-CLI-16 no help row" "$_out" "help: Show this help"
        assert_not_contains "TP-CLI-16 no install row" "$_out" "install: Copy this program"
        assert_not_contains "TP-CLI-16 no uninstall row" "$_out" "uninstall: Remove the managed binary"
        assert_not_contains "TP-CLI-16 no where-is-me row" "$_out" "where-is-me: Show running"
        assert_not_contains "TP-CLI-16 no version row" "$_out" "version: Show the local version"
        assert_not_contains "TP-CLI-16 no about row" "$_out" "about: Show diagnostics"
        assert_not_contains "TP-CLI-16 no print-sudoers row" "$_out" "print-sudoers: Write a grant file"
        assert_not_contains "TP-CLI-16 no install-script row" "$_out" "print-sudoers-install-script: Write an admin script"
        assert_not_contains "TP-CLI-16 no generate row" "$_out" "generate-sudoer-request: Write a local JSON grant"
        assert_not_contains "TP-CLI-16 no generate-sudoer-json row" "$_out" "generate-sudoer-json: Write the canonical JSON grant"
        assert_not_contains "TP-CLI-16 no menu row" "$_out" "menu: Show the numbered list"
        assert_not_contains "TP-CLI-16 no main row" "$_out" "main: Same numbered list"
    else
        t_skip "TP-CLI-13 TTY menu (no python3 for PTY)"
        t_skip "TP-CLI-14 TTY menu --json (no python3 for PTY)"
        t_skip "TP-CLI-16 TTY exclusions (no python3 for PTY)"
    fi
}
