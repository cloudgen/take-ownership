# =============================================================================
# tests/test_domain_take_ownership.sh — action + grant emit
# =============================================================================
# Primary ops REQ: requirement-take-ownership-ops
# Domain surface:  requirement-domain-take-ownership
# Privilege peer:  requirement-three-layer-privilege-model
# JSON grant:      requirement-sudoer-json-file
# TP family: TP-TAKE-OWNERSHIP-*
# =============================================================================

# shellcheck source=helpers.sh
. "${TESTS_ROOT}/helpers.sh"

to_ci_place_global() {
    cp "${SCRIPT}" "${CI_GLOBAL_BIN}/${APP_NAME}"
    chmod 0755 "${CI_GLOBAL_BIN}/${APP_NAME}"
}

run_test_domain_take_ownership() {
    t_header "Domain take-ownership (TP-TAKE-OWNERSHIP)"

    require_cmd sh
    require_cmd id

    ci_isolated_env

    _me=$(id -un)
    _grp=$(id -gn)
    _og="${_me}:${_grp}"

    # TP-TAKE-OWNERSHIP-01 action routed; missing flags fail, no hang
    _err=$(HOME="${CI_HOME}" GLOBAL_BIN="${CI_GLOBAL_BIN}" sh "${SCRIPT}" action 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-TAKE-OWNERSHIP-01 action missing flags exit 1" 1 "$_ec"
    assert_contains "TP-TAKE-OWNERSHIP-01 needs --path" "$_err" "--path"

    # TP-TAKE-OWNERSHIP-15 swapped flag order fail closed
    _err=$(HOME="${CI_HOME}" GLOBAL_BIN="${CI_GLOBAL_BIN}" sh "${SCRIPT}" action --ownership "${_og}" --path /tmp 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-TAKE-OWNERSHIP-15 swapped flags exit 1" 1 "$_ec"
    assert_contains "TP-TAKE-OWNERSHIP-15 swapped order" "$_err" "that order"

    # TP-TAKE-OWNERSHIP-11 refuse /etc and relative path
    _err=$(HOME="${CI_HOME}" GLOBAL_BIN="${CI_GLOBAL_BIN}" sh "${SCRIPT}" action --path /etc --ownership "${_og}" 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-TAKE-OWNERSHIP-11 refuse /etc exit 1" 1 "$_ec"
    assert_contains "TP-TAKE-OWNERSHIP-11 refuse system path" "$_err" "system path"

    _err=$(HOME="${CI_HOME}" GLOBAL_BIN="${CI_GLOBAL_BIN}" sh "${SCRIPT}" action --path relative/dir --ownership "${_og}" 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-TAKE-OWNERSHIP-11 relative path exit 1" 1 "$_ec"

    _link="${CI_HOME}/link-dir"
    mkdir -p "${CI_HOME}/real-dir"
    ln -s "${CI_HOME}/real-dir" "${_link}"
    _err=$(HOME="${CI_HOME}" GLOBAL_BIN="${CI_GLOBAL_BIN}" sh "${SCRIPT}" action --path "${_link}" --ownership "${_og}" 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-TAKE-OWNERSHIP-11 symlink --path exit 1" 1 "$_ec"
    assert_contains "TP-TAKE-OWNERSHIP-11 symlink text" "$_err" "symbolic link"

    # TP-TAKE-OWNERSHIP-12 missing owner:group
    mkdir -p "${CI_HOME}/owned"
    _err=$(HOME="${CI_HOME}" GLOBAL_BIN="${CI_GLOBAL_BIN}" sh "${SCRIPT}" action --path "${CI_HOME}/owned" --ownership "no-such-user-xyz:no-such-group-xyz" 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-TAKE-OWNERSHIP-12 missing user:group exit 1" 1 "$_ec"

    # TP-TAKE-OWNERSHIP-03 / 30 generate/submit refuse without global binary
    _err=$(HOME="${CI_HOME}" GLOBAL_BIN="${CI_GLOBAL_BIN}" sh "${SCRIPT}" generate-sudoer-request --path /var/www/html 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-TAKE-OWNERSHIP-03 generate without global exit 1" 1 "$_ec"
    assert_contains "TP-TAKE-OWNERSHIP-03 generate names global program" "$_err" "global program"

    _err=$(HOME="${CI_HOME}" GLOBAL_BIN="${CI_GLOBAL_BIN}" sh "${SCRIPT}" print-sudoers --path /var/www/html 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-TAKE-OWNERSHIP-30 print-sudoers without global exit 1" 1 "$_ec"

    # Place global binary for grant emit
    to_ci_place_global

    # TP-TAKE-OWNERSHIP-20/21/22 generate JSON grant
    _out=$(HOME="${CI_HOME}" GLOBAL_BIN="${CI_GLOBAL_BIN}" USER_BIN="${CI_USER_BIN}" \
        sh "${SCRIPT}" generate-sudoer-request --path /var/www/html 2>&1)
    _ec=$?
    assert_eq "TP-TAKE-OWNERSHIP-20 generate exit 0" 0 "$_ec"
    _gfile="${CI_HOME}/.config/${APP_NAME}/sudoer-request-${_me}.json"
    assert_file_exists "TP-TAKE-OWNERSHIP-24 generate dest exists" "${_gfile}"
    _gbody=$(cat "${_gfile}")
    assert_contains "TP-TAKE-OWNERSHIP-20 path is global take-ownership" "${_gbody}" "${CI_GLOBAL_BIN}/${APP_NAME}"
    assert_contains "TP-TAKE-OWNERSHIP-22 args action" "${_gbody}" '"action"'
    assert_contains "TP-TAKE-OWNERSHIP-22 --path" "${_gbody}" '/var/www/html'
    assert_contains "TP-TAKE-OWNERSHIP-22 --ownership star" "${_gbody}" '"--ownership","*"'
    assert_contains "TP-TAKE-OWNERSHIP-22 --json twin" "${_gbody}" '"--json"'
    assert_not_contains "TP-TAKE-OWNERSHIP-21 no /bin/chown" "${_gbody}" "/bin/chown"
    assert_not_contains "TP-TAKE-OWNERSHIP-21 no mkdir" "${_gbody}" "/usr/bin/mkdir"
    assert_not_contains "TP-TAKE-OWNERSHIP-05 no --path star" "${_gbody}" '"--path","*"'

    _out=$(HOME="${CI_HOME}" GLOBAL_BIN="${CI_GLOBAL_BIN}" sh "${SCRIPT}" print-sudoers --path /var/www/html 2>&1)
    _ec=$?
    assert_eq "TP-TAKE-OWNERSHIP-31 print-sudoers exit 0" 0 "$_ec"
    assert_contains "TP-TAKE-OWNERSHIP-31 fragment action --path" "$_out" "action --path /var/www/html --ownership *"
    assert_contains "TP-TAKE-OWNERSHIP-31 --json twin line" "$_out" "--json action --path /var/www/html --ownership *"
    assert_not_contains "TP-TAKE-OWNERSHIP-31 no USER_BIN in fragment" "$_out" "${CI_USER_BIN}/${APP_NAME} action"
    assert_not_contains "TP-TAKE-OWNERSHIP-31 no chown Cmnd" "$_out" "/bin/chown"
    assert_file_missing "TP-TAKE-OWNERSHIP-32 no /etc write" "/etc/sudoers.d/${APP_NAME}"

    # TP-TAKE-OWNERSHIP-13 already matching (same owner:group) is success
    mkdir -p "${CI_HOME}/owned2"
    _out=$(HOME="${CI_HOME}" GLOBAL_BIN="${CI_GLOBAL_BIN}" sh "${SCRIPT}" action --path "${CI_HOME}/owned2" --ownership "${_og}" 2>&1)
    _ec=$?
    assert_eq "TP-TAKE-OWNERSHIP-13 already matching exit 0" 0 "$_ec"
    assert_contains "TP-TAKE-OWNERSHIP-13 already matching text" "$_out" "Already ${_og}"

    # TP-TAKE-OWNERSHIP-14 non-TTY missing ownership does not hang
    _err=$(HOME="${CI_HOME}" GLOBAL_BIN="${CI_GLOBAL_BIN}" sh "${SCRIPT}" action --path "${CI_HOME}/owned2" 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-TAKE-OWNERSHIP-14 missing ownership exit 1" 1 "$_ec"
    assert_contains "TP-TAKE-OWNERSHIP-14 names --ownership" "$_err" "--ownership"

    ci_cleanup_env
}
