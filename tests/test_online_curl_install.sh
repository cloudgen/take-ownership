# =============================================================================
# tests/test_online_curl_install.sh — TP-CURL-* (local HTTP channel)
# =============================================================================
# Core cases use local HTTP channel only. Optional public channel behind flag.
# Primary REQs: requirement-shell-cli-zero-arguments, requirement-shell-self-management
# =============================================================================

# shellcheck source=helpers.sh
. "${TESTS_ROOT}/helpers.sh"

run_test_online_curl_install() {
    t_header "Online curl|sh (TP-CURL local channel)"

    require_cmd curl
    require_cmd python3
    require_cmd sha256sum

    ci_isolated_env
    if ! ci_start_channel; then
        ci_cleanup_env
        return 1
    fi

    _errf="${CI_HOME}/curl-err.txt"
    _app_bin="${CI_USER_BIN}/${APP_NAME}"

    # --- TP-CURL-01: channel probe ---
    _out=$(curl -fsS "${CI_SCRIPT_URL}" 2>"${_errf}")
    _ec=$?
    assert_eq "TP-CURL-01 curl channel ship unit exit 0" 0 "$_ec"
    assert_contains "TP-CURL-01 body has APP_NAME assign" "$_out" "APP_NAME=\"${APP_NAME}\""
    assert_contains "TP-CURL-01 body has VERSION" "$_out" "VERSION=\""
    _comp=$(curl -fsS "${CI_SCRIPT_URL}.sha256" 2>"${_errf}")
    _ec=$?
    assert_eq "TP-CURL-01 companion download exit 0" 0 "$_ec"
    _hex=$(printf '%s' "$_comp" | awk '{print $1; exit}')
    case "$_hex" in
        [0-9a-fA-F][0-9a-fA-F]*) t_pass "TP-CURL-01 companion first field looks like SHA-256 hex" ;;
        *) t_fail "TP-CURL-01 companion not hex: '$(_trunc "$_hex")'" ;;
    esac

    # --- TP-CURL-02: first curl|sh clean HOME ---
    _out=$(
        curl -fsSL "${CI_SCRIPT_URL}" 2>"${_errf}" \
        | env HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
            sh 2>>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    assert_eq "TP-CURL-02 first pipe install exit 0" 0 "$_ec"
    assert_file_exists "TP-CURL-02 binary at USER_BIN" "${_app_bin}"
    assert_not_silent "TP-CURL-02 first pipe not silent" "$_out" "$_err"

    # --- TP-CURL-03: second pipe same HOME ---
    : > "${_errf}"
    _out=$(
        curl -fsSL "${CI_SCRIPT_URL}" 2>"${_errf}" \
        | env HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
            sh 2>>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    assert_eq "TP-CURL-03 second pipe exit 0" 0 "$_ec"
    assert_not_silent "TP-CURL-03 second pipe not silent" "$_out" "$_err"
    assert_not_contains "TP-CURL-03 second pipe not help-only" "$_out" "Global Options"
    assert_contains "TP-CURL-03 second pipe already-installed messaging" "$_out$_err" "already installed"

    # --- TP-CURL-05: bad URL with curl -fsSL ---
    : > "${_errf}"
    _out=$(curl -fsSL "http://127.0.0.1:1/${APP_NAME}-missing" 2>"${_errf}" || true)
    _err=$(cat "${_errf}" 2>/dev/null || true)
    assert_not_silent "TP-CURL-05 bad URL curl not silent" "$_out" "$_err"

    # --- TP-CURL-07: pipe with args: sh -s -- version ---
    : > "${_errf}"
    _out=$(
        curl -fsSL "${CI_SCRIPT_URL}" 2>"${_errf}" \
        | env HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
            sh -s -- version 2>>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    assert_eq "TP-CURL-07 pipe version exit 0" 0 "$_ec"
    assert_contains "TP-CURL-07 pipe version reports version" "$_out" "${PRODUCT_VERSION}"
    assert_not_silent "TP-CURL-07 pipe version not silent" "$_out" "$_err"

    # --- TP-CURL-08: empty argv / install download unreachable ---
    rm -f "${_app_bin}"
    : > "${_errf}"
    _out=$(
        env HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" \
        SCRIPT_URL="http://127.0.0.1:1/${APP_NAME}-unreachable" \
        sh "${SCRIPT}" </dev/null 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    if [ "$_ec" -ne 0 ]; then
        t_pass "TP-CURL-08 unreachable channel non-zero"
    else
        t_fail "TP-CURL-08 expected non-zero, got 0"
    fi
    assert_not_silent "TP-CURL-08 unreachable not silent" "$_out" "$_err"
    assert_file_missing "TP-CURL-08 no binary left" "${_app_bin}"

    t_pass "TP-CURL-06 n/a product supports sh (no bash-required gate)"
    t_skip "TP-CURL-09 optional online (set RUN_ONLINE_CURL_TESTS=1)"

    ci_stop_channel
    ci_cleanup_env
}
