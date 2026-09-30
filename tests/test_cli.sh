# =============================================================================
# tests/test_cli.sh — CLI surface (online-installable Type 0 + domain)
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

    # TP-CLI-04 help lists online lifecycle + domain
    _out=$(sh "${SCRIPT}" help 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-04 help exit 0" 0 "$_ec"
    assert_contains "TP-CLI-04 help install" "$_out" "install"
    assert_contains "TP-CLI-04 help uninstall" "$_out" "uninstall"
    assert_contains "TP-CLI-04 help self-uninstall" "$_out" "self-uninstall"
    assert_contains "TP-CLI-04 help self-update" "$_out" "self-update"
    assert_contains "TP-CLI-04 help version-check" "$_out" "version-check"
    assert_contains "TP-CLI-04 help SCRIPT_URL" "$_out" "SCRIPT_URL"
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
    assert_contains "TP-CLI-04 help no ownership wildcard" "$_out" "Wildcard * is not allowed"
    assert_contains "TP-CLI-04 help public inbound" "$_out" "/var/sudoer-cli/sudoer-request"
    assert_contains "TP-CLI-04 help --update" "$_out" "--update"
    assert_contains "TP-CLI-04 help --add" "$_out" "--add"
    assert_contains "TP-CLI-04 help SUDOER_PUBLIC_ROOT" "$_out" "SUDOER_PUBLIC_ROOT"
    assert_contains "TP-CLI-04 help --path" "$_out" "--path PATH"
    assert_contains "TP-CLI-04 help --json" "$_out" "--json"
    assert_contains "TP-CLI-04 help menu" "$_out" "Numbered list of live work commands"
    assert_contains "TP-CLI-04 help main" "$_out" "Same as menu"
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
    assert_contains "TP-CLI-06 cache_used" "$_out" '"cache_used"'
    assert_contains "TP-CLI-06 cache_preferred" "$_out" '"cache_preferred"'
    assert_contains "TP-CLI-06 cache_fallback" "$_out" '"cache_fallback"'
    assert_contains "TP-CLI-06 cache_fallback_2" "$_out" '"cache_fallback_2"'
    assert_contains "TP-CLI-06 persistence_storage" "$_out" '"persistence_storage"'
    assert_contains "TP-CLI-06 effective_storage" "$_out" '"effective_storage"'
    assert_not_contains "TP-CLI-06 no retired persist_dir" "$_out" '"persist_dir"'
    _hum=$(sh "${SCRIPT}" about 2>/dev/null)
    assert_contains "TP-CLI-06 human Cache folder used" "$_hum" "Cache folder used:"
    assert_contains "TP-CLI-06 human Cache folder preferred" "$_hum" "Cache folder (preferred):"
    assert_contains "TP-CLI-06 human Cache folder 1st" "$_hum" "Cache folder (1st fallback):"
    assert_contains "TP-CLI-06 human Cache folder 2nd" "$_hum" "Cache folder (2nd fallback):"
    assert_contains "TP-CLI-06 human Persistence storage" "$_hum" "Persistence storage:"
    assert_not_contains "TP-CLI-06 no Storage (effective) label" "$_hum" "Storage (effective)"
    assert_not_contains "TP-CLI-06 no Storage (fallback) label" "$_hum" "Storage (fallback)"
    assert_contains "TP-CLI-06 global_bin_present" "$_out" '"global_bin_present"'
    assert_contains "TP-CLI-06 global_bin" "$_out" '"global_bin"'
    assert_contains "TP-CLI-06 sudoer_cli" "$_out" '"sudoer_cli"'
    assert_contains "TP-CLI-06 sudoer_adm" "$_out" '"sudoer_adm"'
    assert_contains "TP-CLI-06 sudoer_inbound" "$_out" '"sudoer_inbound"'
    assert_contains "TP-CLI-06 host_sudoers_present" "$_out" '"host_sudoers_present"'
    assert_not_contains "TP-CLI-06 no backup_notation" "$_out" "backup_notation"
    assert_not_contains "TP-CLI-06 no CHECKSUM" "$_out" "CHECKSUM"
    assert_contains "TP-CLI-06 script_url field" "$_out" '"script_url"'

    # TP-CLI-07 empty argv off-TTY is Type O (not help). Unreachable channel
    # fails loud and must not print the numbered list or help dump.
    ci_isolated_env
    _errf="${CI_HOME}/cli07-err.txt"
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" \
        SCRIPT_URL="http://127.0.0.1:1/${APP_NAME}-missing" \
        sh "${SCRIPT}" </dev/null 2>"${_errf}")
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    ci_cleanup_env
    if [ "$_ec" -ne 0 ]; then
        t_pass "TP-CLI-07 empty argv off-TTY unreachable non-zero"
    else
        t_fail "TP-CLI-07 empty argv off-TTY expected non-zero, got 0"
    fi
    assert_not_silent "TP-CLI-07 empty argv off-TTY not silent" "$_out" "$_err"
    assert_not_contains "TP-CLI-07 empty argv off-TTY not numbered list" "$_out" "9. Exit"
    assert_not_contains "TP-CLI-07 empty argv off-TTY not help dump" "$_out" "Global Options"

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

    # TP-CLI-10 backup/restore/--allow-test-local still rejected; online verbs are live
    _err=$(sh "${SCRIPT}" backup 2>&1 >/dev/null)
    assert_eq "TP-CLI-10 backup unknown exit 1" 1 "$?"
    assert_contains "TP-CLI-10 backup unknown" "$_err" "Unknown command"

    _err=$(sh "${SCRIPT}" restore 2>&1 >/dev/null)
    assert_eq "TP-CLI-10 restore unknown exit 1" 1 "$?"

    _err=$(sh "${SCRIPT}" --allow-test-local help 2>&1 >/dev/null)
    assert_eq "TP-CLI-10 no allow-test-local exit 1" 1 "$?"

    # TP-CLI-20 command line for normal user only: Git Bash still runs Type 0
    _out=$(MSYSTEM=MINGW64 sh "${SCRIPT}" version 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-20 MSYSTEM version exit 0" 0 "$_ec"
    assert_contains "TP-CLI-20 MSYSTEM version text" "$_out" "${PRODUCT_VERSION}"

    # TP-CLI-11 set -u HOME unset still works for version
    _out=$(env -u HOME sh "${SCRIPT}" version 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-11 env -u HOME version exit 0" 0 "$_ec"
    assert_contains "TP-CLI-11 env -u HOME version text" "$_out" "${PRODUCT_VERSION}"

    # TP-CLI-12 cache isolation under temp HOME
    ci_isolated_env
    _login=$(id -un 2>/dev/null || echo "unknown")
    case "${_login}" in
        *[!A-Za-z0-9._-]*)
            _login=$(printf '%s' "${_login}" | tr -c 'A-Za-z0-9._-' '_')
            ;;
    esac
    [ -n "${_login}" ] || _login="unknown"
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${SCRIPT}" --json about 2>/dev/null)
    assert_contains "TP-CLI-12 isolated about has app in cache" "$_out" "${APP_NAME}"
    _pref=$(printf '%s' "$_out" | sed -n 's/.*"cache_preferred":"\([^"]*\)".*/\1/p' | head -n1)
    _pid="${_pref##*-}"
    assert_eq "TP-CLI-12 cache_preferred path" "/dev/shm/cache/cache-${APP_NAME}-${_login}-${_pid}" "${_pref}"
    _fb=$(printf '%s' "$_out" | sed -n 's/.*"cache_fallback":"\([^"]*\)".*/\1/p' | head -n1)
    assert_eq "TP-CLI-12 cache_fallback 1st" "/tmp/cache/cache-${APP_NAME}-${_login}-${_pid}" "${_fb}"
    _eff=$(printf '%s' "$_out" | sed -n 's/.*"effective_storage":"\([^"]*\)".*/\1/p' | head -n1)
    if [ -n "$_eff" ] && [ -d "$_eff" ]; then
        t_pass "TP-CLI-12 effective cache directory exists"
    else
        t_fail "TP-CLI-12 effective cache missing: '${_eff:-empty}'"
    fi
    case "${_eff}" in
        /dev/shm/${APP_NAME}|/dev/shm/${APP_NAME}-*)
            t_fail "TP-CLI-12 effective cache must not be a ram-drive project shape: '${_eff}'"
            ;;
        *)
            t_pass "TP-CLI-12 effective cache is not a ram-drive project shape"
            ;;
    esac

    # TP-CLI-18 persistence storage under isolated HOME
    _persist=$(printf '%s' "$_out" | sed -n 's/.*"persistence_storage":"\([^"]*\)".*/\1/p' | head -n1)
    assert_eq "TP-CLI-18 persistence_storage path" "${CI_HOME}/.local/${APP_NAME}" "${_persist}"
    if [ -n "$_persist" ] && [ -d "$_persist" ]; then
        t_pass "TP-CLI-18 persist directory exists"
    else
        t_fail "TP-CLI-18 persist directory missing: '${_persist:-empty}'"
    fi
    if [ "${_persist}" = "${CI_USER_BIN}" ] || [ "${_persist}" = "${CI_USER_BIN}/${APP_NAME}" ]; then
        t_fail "TP-CLI-18 persist must not be USER_BIN: '${_persist}'"
    else
        t_pass "TP-CLI-18 persist is not USER_BIN"
    fi
    if [ -n "${_persist}" ] && [ "${_persist}" = "${_eff}" ]; then
        t_fail "TP-CLI-18 persist must not equal live cache: '${_persist}'"
    else
        t_pass "TP-CLI-18 persist is not the live cache root"
    fi
    _hum_iso=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${SCRIPT}" about 2>/dev/null)
    assert_contains "TP-CLI-18 human Persistence storage" "$_hum_iso" "Persistence storage"
    ci_cleanup_env

    # TP-CACHE-01 / TP-CACHE-02 / TP-CACHE-03 cache folder.
    # about is not an ownership path. HOME is this login (not a scratch dir).
    _cache_home=$(getent passwd "$(id -un 2>/dev/null || echo "")" 2>/dev/null | cut -d: -f6)
    if [ -z "${_cache_home}" ] || [ ! -d "${_cache_home}" ]; then
        _cache_home="${HOME}"
    fi
    _json=$(HOME="${_cache_home}" sh "${SCRIPT}" --json about 2>/dev/null)
    _ec=$?
    assert_eq "TP-CACHE-01 about json exit" 0 "${_ec}"
    assert_contains "TP-CACHE-01 cache_used" "${_json}" '"cache_used"'
    assert_contains "TP-CACHE-01 cache_preferred" "${_json}" '"cache_preferred"'
    assert_contains "TP-CACHE-01 cache_fallback" "${_json}" '"cache_fallback"'
    assert_contains "TP-CACHE-01 cache_fallback_2" "${_json}" '"cache_fallback_2"'
    assert_contains "TP-CACHE-01 persistence_storage" "${_json}" '"persistence_storage"'
    assert_contains "TP-CACHE-01 effective_storage" "${_json}" '"effective_storage"'
    assert_not_contains "TP-CACHE-01 no CHECKSUM" "${_json}" "CHECKSUM"
    _hum=$(HOME="${_cache_home}" sh "${SCRIPT}" about 2>/dev/null)
    assert_contains "TP-CACHE-01 human used" "${_hum}" "Cache folder used:"
    assert_contains "TP-CACHE-01 human preferred" "${_hum}" "Cache folder (preferred):"
    assert_contains "TP-CACHE-01 human 1st" "${_hum}" "Cache folder (1st fallback):"
    assert_contains "TP-CACHE-01 human 2nd" "${_hum}" "Cache folder (2nd fallback):"
    assert_contains "TP-CACHE-01 human persistence" "${_hum}" "Persistence storage:"
    assert_not_contains "TP-CACHE-01 no Storage (effective)" "${_hum}" "Storage (effective)"
    assert_not_contains "TP-CACHE-01 no Storage (fallback)" "${_hum}" "Storage (fallback)"
    _pref=$(printf '%s' "${_json}" | sed -n 's/.*"cache_preferred":"\([^"]*\)".*/\1/p' | head -n1)
    _pid="${_pref##*-}"
    case "${_pref}" in
        /dev/shm/cache/cache-${APP_NAME}-${_login}-[0-9]*)
            t_pass "TP-CACHE-02 cache_preferred is shm login process leaf"
            ;;
        *)
            t_fail "TP-CACHE-02 cache_preferred unexpected: ${_pref:-empty}"
            ;;
    esac
    _fb=$(printf '%s' "${_json}" | sed -n 's/.*"cache_fallback":"\([^"]*\)".*/\1/p' | head -n1)
    assert_eq "TP-CACHE-02 cache_fallback 1st" "/tmp/cache/cache-${APP_NAME}-${_login}-${_pid}" "${_fb}"
    _fb2=$(printf '%s' "${_json}" | sed -n 's/.*"cache_fallback_2":"\([^"]*\)".*/\1/p' | head -n1)
    assert_eq "TP-CACHE-02 cache_fallback 2nd" "${_cache_home}/.cache/cache-${APP_NAME}-${_pid}" "${_fb2}"
    _used=$(printf '%s' "${_json}" | sed -n 's/.*"cache_used":"\([^"]*\)".*/\1/p' | head -n1)
    _eff=$(printf '%s' "${_json}" | sed -n 's/.*"effective_storage":"\([^"]*\)".*/\1/p' | head -n1)
    _sdir=$(printf '%s' "${_json}" | sed -n 's/.*"storage_dir":"\([^"]*\)".*/\1/p' | head -n1)
    assert_eq "TP-CACHE-02 cache_used matches effective" "${_eff}" "${_used}"
    assert_eq "TP-CACHE-02 storage_dir is 1st fallback" "${_fb}" "${_sdir}"
    if [ -n "${_eff}" ] && [ -d "${_eff}" ]; then
        t_pass "TP-CACHE-02 effective cache directory exists"
    else
        t_fail "TP-CACHE-02 effective cache missing: ${_eff:-empty}"
    fi
    case "${_eff}" in
        /dev/shm/${APP_NAME}|/dev/shm/${APP_NAME}-*)
            t_fail "TP-CACHE-02 effective cache must not be a ram-drive project shape: ${_eff}"
            ;;
        *)
            t_pass "TP-CACHE-02 effective cache is not a ram-drive project shape"
            ;;
    esac
    _mode=$(stat -c %a "${_eff}" 2>/dev/null || echo "")
    assert_eq "TP-CACHE-02 effective cache mode 0700" "700" "${_mode}"
    _errc=$(HOME="${_cache_home}" TO_CACHE_SKIP=preferred sh "${SCRIPT}" about 2>&1 >/dev/null)
    assert_not_contains "TP-CACHE-02 silent cache fallback" "${_errc}" "fallback"
    assert_not_contains "TP-CACHE-02 silent cache fallback error" "${_errc}" "Cannot create cache"
    _skip_hum=$(HOME="${_cache_home}" TO_CACHE_SKIP=preferred sh "${SCRIPT}" about 2>/dev/null)
    assert_not_contains "TP-CACHE-02 no warn on skip" "${_skip_hum}" "[WARN]"
    assert_not_contains "TP-CACHE-02 no error on skip" "${_skip_hum}" "[ERROR]"
    _skip=$(HOME="${_cache_home}" TO_CACHE_SKIP=preferred sh "${SCRIPT}" --json about 2>/dev/null)
    _skip_eff=$(printf '%s' "${_skip}" | sed -n 's/.*"effective_storage":"\([^"]*\)".*/\1/p' | head -n1)
    _skip_fb=$(printf '%s' "${_skip}" | sed -n 's/.*"cache_fallback":"\([^"]*\)".*/\1/p' | head -n1)
    _skip_pref=$(printf '%s' "${_skip}" | sed -n 's/.*"cache_preferred":"\([^"]*\)".*/\1/p' | head -n1)
    assert_eq "TP-CACHE-02 skipped preferred uses 1st fallback" "${_skip_fb}" "${_skip_eff}"
    if [ -n "${_skip_pref}" ] && [ "${_skip_pref}" != "${_skip_eff}" ]; then
        t_pass "TP-CACHE-02 skipped preferred still names the preferred path"
    else
        t_fail "TP-CACHE-02 preferred path should stay visible when unused"
    fi
    _gb=$(HOME="${_cache_home}" TO_CACHE_HOST=gitbash sh "${SCRIPT}" --json about 2>/dev/null)
    _gb_pref=$(printf '%s' "${_gb}" | sed -n 's/.*"cache_preferred":"\([^"]*\)".*/\1/p' | head -n1)
    _gb_pid="${_gb_pref##*-}"
    assert_eq "TP-CACHE-02 gitbash preferred" "/tmp/cache/cache-${APP_NAME}-${_login}-${_gb_pid}" "${_gb_pref}"
    _gb_fb=$(printf '%s' "${_gb}" | sed -n 's/.*"cache_fallback":"\([^"]*\)".*/\1/p' | head -n1)
    assert_eq "TP-CACHE-02 gitbash 1st fallback" "${_cache_home}/AppData/Local/Temp/cache-${APP_NAME}-${_gb_pid}" "${_gb_fb}"
    assert_contains "TP-CACHE-02 gitbash json has empty cache_fallback_2" "${_gb}" '"cache_fallback_2":""'
    _gb_fb2=$(printf '%s' "${_gb}" | sed -n 's/.*"cache_fallback_2":"\([^"]*\)".*/\1/p' | head -n1)
    assert_eq "TP-CACHE-02 gitbash no 2nd fallback" "" "${_gb_fb2}"
    _mac=$(HOME="${_cache_home}" TO_CACHE_HOST=mac sh "${SCRIPT}" --json about 2>/dev/null)
    _mac_pref=$(printf '%s' "${_mac}" | sed -n 's/.*"cache_preferred":"\([^"]*\)".*/\1/p' | head -n1)
    _mac_pid="${_mac_pref##*-}"
    assert_eq "TP-CACHE-02 mac preferred" "/tmp/cache/cache-${APP_NAME}-${_login}-${_mac_pid}" "${_mac_pref}"
    _mac_fb=$(printf '%s' "${_mac}" | sed -n 's/.*"cache_fallback":"\([^"]*\)".*/\1/p' | head -n1)
    assert_eq "TP-CACHE-02 mac 1st fallback" "${_cache_home}/Library/Caches/cache-${APP_NAME}-${_mac_pid}" "${_mac_fb}"
    _mac_fb2=$(printf '%s' "${_mac}" | sed -n 's/.*"cache_fallback_2":"\([^"]*\)".*/\1/p' | head -n1)
    assert_eq "TP-CACHE-02 mac 2nd fallback" "${_cache_home}/cache/cache-${APP_NAME}-${_mac_pid}" "${_mac_fb2}"
    _hum_l=$(HOME="${_cache_home}" sh "${SCRIPT}" about 2>/dev/null)
    _used_line=$(printf '%s\n' "${_hum_l}" | sed -n 's/.*Cache folder used: //p' | head -n1)
    _pref_line=$(printf '%s\n' "${_hum_l}" | sed -n 's/.*Cache folder (preferred): //p' | head -n1)
    assert_eq "TP-CACHE-02 used matches preferred when preferred works" "${_pref_line}" "${_used_line}"
    assert_contains "TP-CACHE-02 linux about preferred path" "${_hum_l}" "/dev/shm/cache/cache-${APP_NAME}-${_login}-"
    assert_contains "TP-CACHE-02 linux about 2nd path" "${_hum_l}" "/.cache/cache-${APP_NAME}-"
    _hum_gb=$(HOME="${_cache_home}" TO_CACHE_HOST=gitbash sh "${SCRIPT}" about 2>/dev/null)
    assert_contains "TP-CACHE-02 gitbash about 1st" "${_hum_gb}" "AppData/Local/Temp/cache-${APP_NAME}-"
    assert_not_contains "TP-CACHE-02 gitbash about omits 2nd" "${_hum_gb}" "Cache folder (2nd fallback)"
    _hum_mac=$(HOME="${_cache_home}" TO_CACHE_HOST=mac sh "${SCRIPT}" about 2>/dev/null)
    assert_contains "TP-CACHE-02 mac about 1st" "${_hum_mac}" "Library/Caches/cache-${APP_NAME}-"
    assert_contains "TP-CACHE-02 mac about 2nd path" "${_hum_mac}" "Cache folder (2nd fallback): ${_cache_home}/cache/cache-${APP_NAME}-"
    _persist=$(printf '%s' "${_json}" | sed -n 's/.*"persistence_storage":"\([^"]*\)".*/\1/p' | head -n1)
    assert_eq "TP-CACHE-02 persistence_storage path" "${_cache_home}/.local/${APP_NAME}" "${_persist}"
    if [ -n "${_persist}" ] && [ -d "${_persist}" ]; then
        t_pass "TP-CACHE-02 persistence storage directory exists"
    else
        t_fail "TP-CACHE-02 persistence storage missing: ${_persist:-empty}"
    fi
    case "${_persist}" in
        */.local/bin|*/.local/bin/)
            t_fail "TP-CACHE-02 persistence must not be USER_BIN: ${_persist}"
            ;;
        *)
            t_pass "TP-CACHE-02 persistence is not the install bin directory"
            ;;
    esac
    _j2=$(HOME="${_cache_home}" sh "${SCRIPT}" --json about 2>/dev/null)
    _p2=$(printf '%s' "${_j2}" | sed -n 's/.*"cache_preferred":"\([^"]*\)".*/\1/p' | head -n1)
    _p2="${_p2##*-}"
    if [ -n "${_pid}" ] && [ -n "${_p2}" ] && [ "${_pid}" != "${_p2}" ]; then
        t_pass "TP-CACHE-02 each process has its own cache leaf"
    else
        t_fail "TP-CACHE-02 cache leaf pid reused (${_pid:-empty} vs ${_p2:-empty})"
    fi

    # TP-CACHE-03 scratch names stay inside the cache directory.
    _lib=$(mktemp /tmp/take-ownership-lib.XXXXXX) || exit 2
    awk '
        /^app_main "\$@"$/ { print "# app_main stripped"; next }
        { print }
    ' "${SCRIPT}" > "${_lib}"
    _leaf=$(HOME="${_cache_home}" sh -c '. "$1"; util_mktemp tmp' sh "${_lib}" 2>/dev/null) || _leaf=""
    case "${_leaf}" in
        /dev/shm/cache/cache-${APP_NAME}-${_login}-[0-9]*/${APP_NAME}.tmp.*)
            _base=${_leaf##*/}
            case "${_base}" in
                *.\$\$|${APP_NAME}.\$\$)
                    t_fail "TP-CACHE-03 scratch file uses a dollar name: ${_base}"
                    ;;
                *)
                    t_pass "TP-CACHE-03 scratch file is an mktemp name under the cache leaf"
                    ;;
            esac
            ;;
        *)
            t_fail "TP-CACHE-03 scratch file unexpected: ${_leaf:-empty}"
            ;;
    esac
    if [ -n "${_leaf}" ] && [ -f "${_leaf}" ]; then
        rm -f -- "${_leaf}"
    fi
    _dollars=$(printf '%s%s' '$' '$')
    _bad=$(HOME="${_cache_home}" sh -c '. "$1"; util_mktemp "$2"' sh "${_lib}" "x${_dollars}y" 2>&1 >/dev/null) || true
    assert_contains "TP-CACHE-03 refuses a dollar file name" "${_bad}" "refuse predictable"
    _fbfile=$(HOME="${_cache_home}" sh -c '. "$1"; TO_MKTEMP_BIN= util_mktemp tmp' sh "${_lib}" 2>/dev/null) || _fbfile=""
    case "${_fbfile}" in
        /dev/shm/cache/cache-${APP_NAME}-${_login}-[0-9]*/${APP_NAME}.tmp.*)
            _base=${_fbfile##*/}
            case "${_base}" in
                *'$$'*)
                    t_fail "TP-CACHE-03 absent mktemp uses a dollar name: ${_base}"
                    ;;
                *)
                    _mode=$(stat -c '%a' "${_fbfile}" 2>/dev/null || echo "")
                    if [ "${_mode}" = "600" ]; then
                        t_pass "TP-CACHE-03 absent mktemp writes a mode-0600 file under the cache leaf"
                    else
                        t_fail "TP-CACHE-03 absent mktemp mode ${_mode:-empty} for ${_fbfile}"
                    fi
                    ;;
            esac
            ;;
        *)
            t_fail "TP-CACHE-03 absent mktemp unexpected: ${_fbfile:-empty}"
            ;;
    esac
    if [ -n "${_fbfile}" ] && [ -f "${_fbfile}" ]; then
        rm -f -- "${_fbfile}"
    fi
    _fbdir=$(HOME="${_cache_home}" sh -c '. "$1"; TO_MKTEMP_BIN= util_mktemp_dir' sh "${_lib}" 2>/dev/null) || _fbdir=""
    case "${_fbdir}" in
        /dev/shm/cache/cache-${APP_NAME}-${_login}-[0-9]*/${APP_NAME}-work.*)
            _mode=$(stat -c '%a' "${_fbdir}" 2>/dev/null || echo "")
            if [ "${_mode}" = "700" ] && [ -x "${_fbdir}" ] && [ -w "${_fbdir}" ]; then
                t_pass "TP-CACHE-03 absent mktemp directory is mode 0700 and searchable"
            else
                t_fail "TP-CACHE-03 absent mktemp directory mode ${_mode:-empty} for ${_fbdir}"
            fi
            ;;
        *)
            t_fail "TP-CACHE-03 absent mktemp directory unexpected: ${_fbdir:-empty}"
            ;;
    esac
    if [ -n "${_fbdir}" ] && [ -d "${_fbdir}" ]; then
        rmdir "${_fbdir}" 2>/dev/null || rm -rf -- "${_fbdir}"
    fi
    rm -f -- "${_lib}"

    # TP-CLI-15 non-interactive menu is help; --json JSON help; empty argv off-TTY is help
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

    _out=$(SCRIPT_URL="http://127.0.0.1:1/${APP_NAME}-missing" sh "${SCRIPT}" 2>/dev/null || true)
    assert_not_contains "TP-CLI-15 empty argv off-TTY not numbered list" "$_out" "9. Exit"

    _out=$(sh "${SCRIPT}" --quiet menu 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-15 menu --quiet off-TTY exit 0" 0 "$_ec"
    assert_contains "TP-CLI-15 menu --quiet off-TTY still help" "$_out" "Usage:"

    assert_contains "TP-CLI-15 help lists menu" "$(sh "${SCRIPT}" help 2>/dev/null)" "Numbered list of live work commands"
    assert_contains "TP-CLI-15 help lists main" "$(sh "${SCRIPT}" help 2>/dev/null)" "Same as menu"

    _help=$(sh "${SCRIPT}" help 2>/dev/null)
    assert_contains "TP-CLI-17 help grant testers heading" "$_help" "Grant testers (test-purpose"
    assert_contains "TP-CLI-17 help generate-sudoer-json tester" "$_help" "generate-sudoer-json"
    assert_contains "TP-CLI-17 help generate-sudoer-request operational" "$_help" "generate-sudoer-request --path"

    _err=$(sh "${SCRIPT}" sudoers 2>&1 >/dev/null)
    assert_eq "TP-CLI-13 sudoers not a live command" 1 "$?"
    assert_contains "TP-CLI-13 sudoers unknown" "$_err" "Unknown command"
    _err=$(sh "${SCRIPT}" self-management 2>&1 >/dev/null)
    assert_eq "TP-CLI-21 self-management not a live command" 1 "$?"
    assert_contains "TP-CLI-21 self-management unknown" "$_err" "Unknown command"

    if command -v python3 >/dev/null 2>&1; then
        _esc=$(printf '\033')
        _out=$(PTY_IN="9" ci_pty_run menu)
        _plain=$(ci_strip_ansi "$_out")
        assert_contains "TP-CLI-13 TTY menu action row" "$_plain" "1. action: Recursively take ownership of a named folder"
        assert_contains "TP-CLI-13 TTY menu family sudoers" "$_plain" "7. sudoers: Grant and drafts"
        assert_contains "TP-CLI-13 TTY menu family self-management" "$_plain" "8. self-management: This CLI install, version, update, uninstall"
        assert_contains "TP-CLI-13 TTY menu Exit 9" "$_plain" "9. Exit"
        assert_contains "TP-CLI-13 TTY menu ident token" "$_plain" "${APP_NAME}(${PRODUCT_VERSION})"
        assert_not_contains "TP-CLI-13 TTY menu no old family row 2" "$_plain" "2. sudoers:"
        assert_not_contains "TP-CLI-13 TTY menu no list-folders row" "$_plain" "list-folders: List folders this login may take ownership of"
        assert_not_contains "TP-CLI-13 TTY menu no backup row" "$_plain" "1. backup:"
        assert_not_contains "TP-CLI-13 TTY main hides generate row" "$_plain" "71. generate-sudoer-request:"
        assert_not_contains "TP-CLI-13 TTY main hides install row" "$_plain" "81. install:"

        _out=$(PTY_IN="9" ci_pty_run)
        _plain=$(ci_strip_ansi "$_out")
        assert_contains "TP-CLI-13 TTY empty argv action row" "$_plain" "1. action: Recursively take ownership of a named folder"
        assert_contains "TP-CLI-13 TTY empty argv family sudoers" "$_plain" "7. sudoers: Grant and drafts"
        assert_contains "TP-CLI-13 TTY empty argv family self-management" "$_plain" "8. self-management: This CLI install, version, update, uninstall"
        assert_contains "TP-CLI-13 TTY empty argv Exit 9" "$_plain" "9. Exit"
        assert_contains "TP-CLI-13 TTY empty argv ident token" "$_plain" "${APP_NAME}(${PRODUCT_VERSION})"
        assert_not_contains "TP-CLI-13 TTY empty argv no list-folders row" "$_plain" "list-folders: List folders this login may take ownership of"
        assert_not_contains "TP-CLI-13 TTY empty argv not help Usage" "$_plain" "Usage:"

        _out=$(PTY_IN="7
0
9" ci_pty_run menu)
        _plain=$(ci_strip_ansi "$_out")
        assert_contains "TP-CLI-22 TTY submenu generate row" "$_plain" "71. generate-sudoer-request: Write a JSON grant you can read"
        assert_contains "TP-CLI-22 TTY submenu submit row" "$_plain" "72. submit-sudoer-request: Queue the JSON grant inbound"
        assert_contains "TP-CLI-22 TTY submenu print row" "$_plain" "73. print-sudoers: Emit sudoers draft"
        assert_contains "TP-CLI-22 TTY submenu install-script row" "$_plain" "74. print-sudoers-install-script: Write admin install script"
        assert_contains "TP-CLI-22 TTY submenu remove row" "$_plain" "75. remove-project-sudoers: Remove sudoers draft only"
        assert_contains "TP-CLI-22 TTY submenu Back 0" "$_plain" "0. Back"
        assert_not_contains "TP-CLI-22 TTY submenu no Back 8" "$_plain" "8. Back"
        _mid=$(printf '%s\n' "$_plain" | sed -n '/sudoers (grant and drafts)/,/0\. Back/p')
        assert_not_contains "TP-CLI-22 TTY submenu no Exit 9" "$_mid" "9. Exit"

        _out=$(PTY_IN="9" ci_pty_run --json menu)
        _plain=$(ci_strip_ansi "$_out")
        assert_contains "TP-CLI-14 TTY menu --json still numbered list" "$_plain" "9. Exit"
        assert_contains "TP-CLI-14 TTY menu --json action row" "$_plain" "1. action: Recursively take ownership"
        assert_contains "TP-CLI-14 TTY menu --json family sudoers" "$_plain" "7. sudoers: Grant and drafts"
        assert_contains "TP-CLI-14 TTY menu --json family self-management" "$_plain" "8. self-management:"
        assert_not_contains "TP-CLI-14 TTY menu --json ignores JSON help" "$_out" '"type":"success"'

        _out=$(PTY_IN="9" ci_pty_run menu)
        _plain=$(ci_strip_ansi "$_out")
        assert_not_contains "TP-CLI-16 no help row" "$_plain" "help: Show this help"
        assert_not_contains "TP-CLI-16 front no install row" "$_plain" "81. install:"
        assert_not_contains "TP-CLI-16 front no install explain" "$_plain" "install: Ensure this program from the channel"
        assert_not_contains "TP-CLI-16 front no uninstall row" "$_plain" "self-uninstall: Remove the managed binary"
        assert_not_contains "TP-CLI-16 no where-is-me row" "$_plain" "where-is-me: Show running"
        assert_not_contains "TP-CLI-16 front no version row" "$_plain" "version: Show the local version"
        assert_not_contains "TP-CLI-16 front no about row" "$_plain" "about: Show diagnostics"
        assert_not_contains "TP-CLI-16 no generate-sudoer-json row" "$_plain" "generate-sudoer-json:"
        assert_not_contains "TP-CLI-16 no menu row" "$_plain" "menu: Show the numbered list"
        assert_not_contains "TP-CLI-16 no main row" "$_plain" "main: Same numbered list"
        assert_not_contains "TP-CLI-16 no list-folders row" "$_plain" "list-folders:"
        _out=$(PTY_IN="8
0
9" ci_pty_run menu)
        _plain=$(ci_strip_ansi "$_out")
        assert_contains "TP-CLI-16 submenu install row" "$_plain" "81. install: Ensure this program from the channel"
        assert_contains "TP-CLI-23 submenu version row" "$_plain" "82. version: Show the local version"
        assert_contains "TP-CLI-23 submenu about row" "$_plain" "83. about: Show diagnostics including global-bin presence"
        assert_contains "TP-CLI-23 submenu version-check row" "$_plain" "84. version-check: Compare local version to the channel"
        assert_contains "TP-CLI-23 submenu self-update row" "$_plain" "85. self-update: Update this program when the channel is newer"
        assert_contains "TP-CLI-23 submenu self-uninstall row" "$_plain" "86. self-uninstall: Remove the managed binary (not the host grant)"
        assert_contains "TP-CLI-23 submenu Back 0" "$_plain" "0. Back"
        assert_not_contains "TP-CLI-23 submenu no self-install row" "$_plain" "87. self-install"
        assert_not_contains "TP-CLI-23 submenu no where-is-me row" "$_plain" "where-is-me:"
        _mid=$(printf '%s\n' "$_plain" | sed -n '/self-management (this CLI)/,/0\. Back/p')
        assert_not_contains "TP-CLI-23 TTY submenu no Exit 9" "$_mid" "9. Exit"
        if grep -E '^[[:space:]]*[^#]*\$\(prompt_|^[[:space:]]*[^#]*`prompt_' "${SCRIPT}" >/dev/null 2>&1; then
            t_fail "TP-CLI-16 ship unit captures a prompt helper with \$()"
        else
            t_pass "TP-CLI-16 no \$() of prompt helpers"
        fi

        # TP-CLI-19 — default CLI main menu style (product alias of portable TP-CLI-17)
        _out=$(PTY_IN="9" ci_pty_run menu)
        _plain=$(ci_strip_ansi "$_out")
        assert_contains "TP-CLI-19 TTY ident token" "$_plain" "${APP_NAME}(${PRODUCT_VERSION})"
        assert_contains "TP-CLI-19 TTY header bold name" "$_out" "${_esc}[1m${APP_NAME}${_esc}[0m"
        assert_contains "TP-CLI-19 TTY header italic version" "$_out" "(${_esc}[3m${PRODUCT_VERSION}${_esc}[0m)"
        assert_contains "TP-CLI-19 TTY header short desc" "$_plain" "Take Unix ownership of a named folder with a narrow global-only sudo grant"
        assert_not_contains "TP-CLI-19 TTY header not generic board title" "$_plain" "numbered list of live work commands"
        assert_contains "TP-CLI-19 TTY explain SGR 3;37" "$_out" "${_esc}[3;37m"
        assert_contains "TP-CLI-19 TTY action name unstyled" "$_out" "1. action: "
        assert_contains "TP-CLI-19 TTY Exit unstyled" "$_plain" "9. Exit"
        _out=$(PTY_IN="7
0
9" ci_pty_run menu)
        _plain=$(ci_strip_ansi "$_out")
        assert_contains "TP-CLI-19 TTY submenu header ident" "$_plain" "${APP_NAME}(${PRODUCT_VERSION})"
        assert_contains "TP-CLI-19 TTY submenu title" "$_plain" "sudoers (grant and drafts)"
        _off=$(sh "${SCRIPT}" menu 2>/dev/null)
        assert_not_contains "TP-CLI-19 off-TTY menu no explain CSI" "$_off" "${_esc}[3;37m"
        assert_not_contains "TP-CLI-19 off-TTY menu no ident CSI" "$_off" "${_esc}[1m${APP_NAME}"
        _empty=$(sh "${SCRIPT}" 2>/dev/null)
        assert_not_contains "TP-CLI-19 off-TTY empty argv no explain CSI" "$_empty" "${_esc}[3;37m"

        # TP-CLI-24 — after version, the front board returns; a bad token reprints this layer
        _out=$(PTY_IN="8
82
9" ci_pty_run menu)
        _plain=$(ci_strip_ansi "$_out")
        assert_contains "TP-CLI-24 version leaf ran" "$_plain" "${APP_NAME} version ${PRODUCT_VERSION}"
        _nfront=$(printf '%s\n' "$_plain" | grep -c '1\. action: Recursively take ownership of a named folder' || true)
        assert_eq "TP-CLI-24 front board returns after leaf" "2" "${_nfront}"
        _out=$(PTY_IN="no-such
9" ci_pty_run menu)
        _plain=$(ci_strip_ansi "$_out")
        assert_contains "TP-CLI-24 unknown token named" "$_plain" "Not a menu choice: 'no-such'"
        assert_contains "TP-CLI-24 unknown token says choose listed" "$_plain" "Choose a listed number or command name."
        assert_not_contains "TP-CLI-24 unknown token is not ERROR" "$_plain" "[ERROR]"
        _nfront=$(printf '%s\n' "$_plain" | grep -c '1\. action: Recursively take ownership of a named folder' || true)
        assert_eq "TP-CLI-24 unknown token reprints front" "2" "${_nfront}"
        _out=$(PTY_IN="7
9
0
9" ci_pty_run menu)
        _plain=$(ci_strip_ansi "$_out")
        assert_contains "TP-CLI-24 submenu 9 is not Exit" "$_plain" "Not a menu choice: '9'"
        _nsudo=$(printf '%s\n' "$_plain" | grep -c '71\. generate-sudoer-request:' || true)
        assert_eq "TP-CLI-24 submenu 9 reprints sudoers" "2" "${_nsudo}"

        # TP-CLI-25 — Termux / Git Bash / Windows cmd omit row 7 and name why
        _out=$(PREFIX="/data/data/com.termux/files/usr" PTY_IN="9" ci_pty_run menu)
        _plain=$(ci_strip_ansi "$_out")
        _head=${_plain%%1. action:*}
        assert_contains "TP-CLI-25 termux reason before numbers" "$_head" "sudoers not available for termux"
        assert_not_contains "TP-CLI-25 termux omits row 7" "$_plain" "7. sudoers:"
        assert_contains "TP-CLI-25 termux keeps self-management" "$_plain" "8. self-management:"
        assert_contains "TP-CLI-25 termux keeps Exit 9" "$_plain" "9. Exit"
        _gbhome=$(mktemp -d "${TMPDIR:-/tmp}/to-menu-gb.XXXXXX")
        _out=$(MSYSTEM="MINGW64" HOME="${_gbhome}" PTY_IN="9" ci_pty_run menu)
        _plain=$(ci_strip_ansi "$_out")
        _head=${_plain%%1. action:*}
        assert_contains "TP-CLI-25 gitbash reason before numbers" "$_head" "sudoers not available for gitbash"
        assert_not_contains "TP-CLI-25 gitbash omits row 7" "$_plain" "7. sudoers:"
        rm -rf "${_gbhome}"
        _out=$(OS="Windows_NT" PTY_IN="9" ci_pty_run menu)
        _plain=$(ci_strip_ansi "$_out")
        _head=${_plain%%1. action:*}
        assert_contains "TP-CLI-25 windows-cmd reason before numbers" "$_head" "sudoers not available for windows-cmd"
        assert_not_contains "TP-CLI-25 windows-cmd omits row 7" "$_plain" "7. sudoers:"
        assert_contains "TP-CLI-25 windows-cmd keeps action" "$_plain" "1. action:"
    else
        t_skip "TP-CLI-13 TTY menu / empty argv (no python3 for PTY)"
        t_skip "TP-CLI-14 TTY menu --json (no python3 for PTY)"
        t_skip "TP-CLI-16 TTY exclusions (no python3 for PTY)"
        t_skip "TP-CLI-19 TTY menu look (no python3 for PTY)"
        t_skip "TP-CLI-22 TTY sudoers submenu (no python3 for PTY)"
        t_skip "TP-CLI-23 TTY self-management submenu (no python3 for PTY)"
        t_skip "TP-CLI-24 menu return and invalid choice (no python3 for PTY)"
        t_skip "TP-CLI-25 menu-hidden sudoers (no python3 for PTY)"
    fi
}
