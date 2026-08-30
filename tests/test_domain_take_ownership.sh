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

    _err=$(HOME="${CI_HOME}" GLOBAL_BIN="${CI_GLOBAL_BIN}" sh "${SCRIPT}" action --path /dev --ownership "${_og}" 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-TAKE-OWNERSHIP-11b refuse /dev exit 1" 1 "$_ec"
    assert_contains "TP-TAKE-OWNERSHIP-11b refuse /dev text" "$_err" "system path"

    _err=$(HOME="${CI_HOME}" GLOBAL_BIN="${CI_GLOBAL_BIN}" sh "${SCRIPT}" action --path /dev/shm --ownership "${_og}" 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-TAKE-OWNERSHIP-11b refuse /dev/shm mount root exit 1" 1 "$_ec"
    assert_contains "TP-TAKE-OWNERSHIP-11b refuse /dev/shm text" "$_err" "system path"

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
    _err=$(HOME="${CI_HOME}" GLOBAL_BIN="${CI_GLOBAL_BIN}" sh "${SCRIPT}" generate-sudoer-request --path /var/www/html --ownership "${_og}" 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-TAKE-OWNERSHIP-03 generate without global exit 1" 1 "$_ec"
    assert_contains "TP-TAKE-OWNERSHIP-03 generate names global program" "$_err" "global program"

    _err=$(HOME="${CI_HOME}" GLOBAL_BIN="${CI_GLOBAL_BIN}" sh "${SCRIPT}" print-sudoers --path /var/www/html --ownership "${_og}" 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-TAKE-OWNERSHIP-30 print-sudoers without global exit 1" 1 "$_ec"

    # Place global binary for grant emit
    to_ci_place_global

    # TP-TAKE-OWNERSHIP-29 ownership fence: * and missing operand fail closed
    _err=$(HOME="${CI_HOME}" GLOBAL_BIN="${CI_GLOBAL_BIN}" USER_BIN="${CI_USER_BIN}" \
        sh "${SCRIPT}" generate-sudoer-request --path /var/www/html --ownership '*' 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-TAKE-OWNERSHIP-29 generate star ownership exit 1" 1 "$_ec"
    assert_contains "TP-TAKE-OWNERSHIP-29 generate star names wildcard" "${_err}" "Wildcard"
    _err=$(HOME="${CI_HOME}" GLOBAL_BIN="${CI_GLOBAL_BIN}" USER_BIN="${CI_USER_BIN}" \
        sh "${SCRIPT}" generate-sudoer-json --path /var/www/html 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-TAKE-OWNERSHIP-29b generate missing ownership exit 1" 1 "$_ec"
    assert_contains "TP-TAKE-OWNERSHIP-29b generate needs --ownership" "${_err}" "--ownership"
    _err=$(HOME="${CI_HOME}" GLOBAL_BIN="${CI_GLOBAL_BIN}" sh "${SCRIPT}" action --path "${CI_HOME}/owned" --ownership '*' 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-TAKE-OWNERSHIP-29c action star ownership exit 1" 1 "$_ec"

    # TP-TAKE-OWNERSHIP-20/21/22 generate JSON grant
    _out=$(HOME="${CI_HOME}" GLOBAL_BIN="${CI_GLOBAL_BIN}" USER_BIN="${CI_USER_BIN}" \
        sh "${SCRIPT}" generate-sudoer-request --path /var/www/html --ownership "${_og}" 2>&1)
    _ec=$?
    assert_eq "TP-TAKE-OWNERSHIP-20 generate exit 0" 0 "$_ec"
    _gfile="${CI_HOME}/.config/${APP_NAME}/sudoer-request-${_me}.json"
    assert_file_exists "TP-TAKE-OWNERSHIP-24 generate dest exists" "${_gfile}"
    _gbody=$(cat "${_gfile}")
    assert_contains "TP-TAKE-OWNERSHIP-20 path is global take-ownership" "${_gbody}" "${CI_GLOBAL_BIN}/${APP_NAME}"
    assert_contains "TP-TAKE-OWNERSHIP-22 args action" "${_gbody}" '"action"'
    assert_contains "TP-TAKE-OWNERSHIP-22 --path" "${_gbody}" '/var/www/html'
    assert_contains "TP-TAKE-OWNERSHIP-22 --ownership user:group" "${_gbody}" "\"--ownership\",\"${_og}\""
    assert_not_contains "TP-TAKE-OWNERSHIP-22 no ownership star" "${_gbody}" '"--ownership","*"'
    assert_contains "TP-TAKE-OWNERSHIP-22 --json twin" "${_gbody}" '"--json"'
    assert_not_contains "TP-TAKE-OWNERSHIP-21 no /bin/chown" "${_gbody}" "/bin/chown"
    assert_not_contains "TP-TAKE-OWNERSHIP-21 no mkdir" "${_gbody}" "/usr/bin/mkdir"
    assert_not_contains "TP-TAKE-OWNERSHIP-05 no --path star" "${_gbody}" '"--path","*"'

    # TP-TAKE-OWNERSHIP-27 generate-sudoer-json from a dirty cwd (INC-20260823-002).
    # Gold is user:group, never "*". Fixture names match a globbed inbound.
    _dirty="${CI_HOME}/dirty-cwd"
    mkdir -p "${_dirty}/docs" "${_dirty}/src"
    : > "${_dirty}/AGENTS.md"
    : > "${_dirty}/AGENTS.md.20260809-141209.bak"
    : > "${_dirty}/AGENTS.md.bak-before-multivault-sync-20260810-124358"
    _gold="${_dirty}/gold-sudoer.json"
    _out=$(
        cd "${_dirty}" || exit 1
        HOME="${CI_HOME}" GLOBAL_BIN="${CI_GLOBAL_BIN}" USER_BIN="${CI_USER_BIN}" \
            sh "${SCRIPT}" generate-sudoer-json --add --path /dev/shm/genesis-template --ownership "${_og}" "${_gold}" 2>&1
    )
    _ec=$?
    assert_eq "TP-TAKE-OWNERSHIP-27 generate-sudoer-json dirty-cwd exit 0" 0 "$_ec"
    assert_file_exists "TP-TAKE-OWNERSHIP-27 generate-sudoer-json dest exists" "${_gold}"
    _goldbody=$(cat "${_gold}")
    assert_contains "TP-TAKE-OWNERSHIP-27 exact --ownership user:group" "${_goldbody}" "\"--ownership\",\"${_og}\""
    assert_contains "TP-TAKE-OWNERSHIP-27 bound --path" "${_goldbody}" '/dev/shm/genesis-template'
    assert_contains "TP-TAKE-OWNERSHIP-27 --json twin" "${_goldbody}" "\"args\":[\"--json\",\"action\",\"--path\",\"/dev/shm/genesis-template\",\"--ownership\",\"${_og}\"]"
    assert_contains "TP-TAKE-OWNERSHIP-27 verb args" "${_goldbody}" "\"args\":[\"action\",\"--path\",\"/dev/shm/genesis-template\",\"--ownership\",\"${_og}\"]"
    assert_not_contains "TP-TAKE-OWNERSHIP-27 no ownership star" "${_goldbody}" '"--ownership","*"'
    assert_not_contains "TP-TAKE-OWNERSHIP-27b no AGENTS.md glob" "${_goldbody}" "AGENTS.md"
    assert_not_contains "TP-TAKE-OWNERSHIP-27b no docs glob" "${_goldbody}" '"docs"'
    assert_not_contains "TP-TAKE-OWNERSHIP-27b no src glob" "${_goldbody}" '"src"'

    # TP-TAKE-OWNERSHIP-28 submit of globbed JSON (cwd listing after --ownership) fails closed
    # before sibling is required. Operator copy names generate-sudoer-json.
    _glob="${CI_HOME}/globbed-sudoer.json"
    printf '%s\n' "{\"schema_version\":1,\"purpose\":\"Allow x to take ownership of /dev/shm/genesis-template.\",\"username\":\"x\",\"service\":\"${APP_NAME}\",\"action\":\"add\",\"commands\":[{\"runas\":\"root\",\"tags\":[\"NOPASSWD\"],\"path\":\"${CI_GLOBAL_BIN}/${APP_NAME}\",\"args\":[\"action\",\"--path\",\"/dev/shm/genesis-template\",\"--ownership\",\"AGENTS.md\",\"AGENTS.md.20260809-141209.bak\",\"docs\",\"src\"]},{\"runas\":\"root\",\"tags\":[\"NOPASSWD\"],\"path\":\"${CI_GLOBAL_BIN}/${APP_NAME}\",\"args\":[\"--json\",\"action\",\"--path\",\"/dev/shm/genesis-template\",\"--ownership\",\"AGENTS.md\",\"AGENTS.md.20260809-141209.bak\",\"docs\",\"src\"]}]}" >"${_glob}"
    _err=$(HOME="${CI_HOME}" GLOBAL_BIN="${CI_GLOBAL_BIN}" sh "${SCRIPT}" submit-sudoer-request "${_glob}" 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-TAKE-OWNERSHIP-28 globbed submit exit 1" 1 "$_ec"
    assert_contains "TP-TAKE-OWNERSHIP-28 names user:group fence" "${_err}" "user:group"
    assert_contains "TP-TAKE-OWNERSHIP-28 names generate-sudoer-json" "${_err}" "generate-sudoer-json"
    assert_contains "TP-TAKE-OWNERSHIP-28 names generate-sudoer-request" "${_err}" "generate-sudoer-request"
    assert_not_contains "TP-TAKE-OWNERSHIP-28 no sibling jargon" "${_err}" "sibling re-encode"

    _stargrant="${CI_HOME}/star-sudoer.json"
    printf '%s\n' "{\"schema_version\":1,\"purpose\":\"x\",\"username\":\"x\",\"service\":\"${APP_NAME}\",\"action\":\"add\",\"commands\":[{\"runas\":\"root\",\"tags\":[\"NOPASSWD\"],\"path\":\"${CI_GLOBAL_BIN}/${APP_NAME}\",\"args\":[\"action\",\"--path\",\"/var/www/html\",\"--ownership\",\"*\"]},{\"runas\":\"root\",\"tags\":[\"NOPASSWD\"],\"path\":\"${CI_GLOBAL_BIN}/${APP_NAME}\",\"args\":[\"--json\",\"action\",\"--path\",\"/var/www/html\",\"--ownership\",\"*\"]}]}" >"${_stargrant}"
    _err=$(HOME="${CI_HOME}" GLOBAL_BIN="${CI_GLOBAL_BIN}" sh "${SCRIPT}" submit-sudoer-request "${_stargrant}" 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-TAKE-OWNERSHIP-28b star-grant submit exit 1" 1 "$_ec"
    assert_contains "TP-TAKE-OWNERSHIP-28b star-grant names wildcard" "${_err}" "wildcard"

    # TP-TAKE-OWNERSHIP-40/41 list-folders (same set action uses)
    _out=$(HOME="${CI_HOME}" GLOBAL_BIN="${CI_GLOBAL_BIN}" sh "${SCRIPT}" list-folders 2>&1)
    _ec=$?
    assert_eq "TP-TAKE-OWNERSHIP-40 list-folders exit 0" 0 "$_ec"
    assert_contains "TP-TAKE-OWNERSHIP-40 lists grant path" "$_out" "/var/www/html"
    _jout=$(HOME="${CI_HOME}" GLOBAL_BIN="${CI_GLOBAL_BIN}" sh "${SCRIPT}" --json list-folders 2>/dev/null)
    assert_contains "TP-TAKE-OWNERSHIP-41 list-folders json path" "${_jout}" "/var/www/html"
    assert_contains "TP-TAKE-OWNERSHIP-41 list-folders json folders" "${_jout}" '"folders"'

    mkdir -p "${CI_HOME}/owned"
    _err=$(HOME="${CI_HOME}" GLOBAL_BIN="${CI_GLOBAL_BIN}" sh "${SCRIPT}" action --path "${CI_HOME}/owned" --ownership "${_og}" 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-TAKE-OWNERSHIP-17 action path not in list exit 1" 1 "$_ec"
    assert_contains "TP-TAKE-OWNERSHIP-17 names list-folders" "$_err" "list-folders"

    _out=$(HOME="${CI_HOME}" GLOBAL_BIN="${CI_GLOBAL_BIN}" USER_BIN="${CI_USER_BIN}" \
        sh "${SCRIPT}" generate-sudoer-request --update --path "${CI_HOME}/owned2" --ownership "${_og}" 2>&1)
    _ec=$?
    assert_eq "TP-TAKE-OWNERSHIP-20b update grant for action path exit 0" 0 "$_ec"
    _gbody=$(cat "${_gfile}")
    assert_contains "TP-TAKE-OWNERSHIP-33 replacement keeps first folder" "${_gbody}" "/var/www/html"
    assert_contains "TP-TAKE-OWNERSHIP-33 replacement adds second folder line" "${_gbody}" "${CI_HOME}/owned2"
    _nact=$(printf '%s' "${_gbody}" | grep -o '"args":\["action"' | wc -l | tr -d ' ')
    assert_eq "TP-TAKE-OWNERSHIP-33 two folders two action lines" "2" "${_nact}"
    _out=$(HOME="${CI_HOME}" GLOBAL_BIN="${CI_GLOBAL_BIN}" USER_BIN="${CI_USER_BIN}" \
        sh "${SCRIPT}" generate-sudoer-request --update --path "${CI_HOME}/owned2" --ownership "${_og}" 2>&1)
    _ec=$?
    assert_eq "TP-TAKE-OWNERSHIP-33b duplicate folder update exit 0" 0 "$_ec"
    _gbody=$(cat "${_gfile}")
    _nact=$(printf '%s' "${_gbody}" | grep -o '"args":\["action"' | wc -l | tr -d ' ')
    assert_eq "TP-TAKE-OWNERSHIP-33b duplicate does not add a line" "2" "${_nact}"
    _notf="${CI_HOME}/not-a-folder"
    : > "${_notf}"
    _err=$(HOME="${CI_HOME}" GLOBAL_BIN="${CI_GLOBAL_BIN}" USER_BIN="${CI_USER_BIN}" \
        sh "${SCRIPT}" generate-sudoer-json --path "${_notf}" --ownership "${_og}" 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-TAKE-OWNERSHIP-34 --path file not folder exit 1" 1 "$_ec"
    assert_contains "TP-TAKE-OWNERSHIP-34 names folder not file" "${_err}" "not a file"

    _out=$(HOME="${CI_HOME}" GLOBAL_BIN="${CI_GLOBAL_BIN}" sh "${SCRIPT}" print-sudoers --path /var/www/html --ownership "${_og}" 2>&1)
    _ec=$?
    assert_eq "TP-TAKE-OWNERSHIP-31 print-sudoers exit 0" 0 "$_ec"
    _og_esc=$(printf '%s' "${_og}" | sed 's/:/\\:/g')
    assert_contains "TP-TAKE-OWNERSHIP-31 fragment action --path" "$_out" "action --path /var/www/html --ownership ${_og_esc}"
    assert_contains "TP-TAKE-OWNERSHIP-31 --json twin line" "$_out" "--json action --path /var/www/html --ownership ${_og_esc}"
    assert_not_contains "TP-TAKE-OWNERSHIP-31 no ownership star" "$_out" "--ownership *"
    if command -v visudo >/dev/null 2>&1; then
        _vf="${CI_HOME}/visudo-fragment"
        printf '%s\n' "$_out" | grep -E '^# Purpose:|[[:space:]]NOPASSWD:' >"${_vf}"
        visudo -cf "${_vf}" >/dev/null 2>&1
        _vc=$?
        assert_eq "TP-TAKE-OWNERSHIP-31 visudo parses escaped user:group" 0 "${_vc}"
    fi
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

    # TP-TAKE-OWNERSHIP-42/43 interactive action: numbered allowed folders,
    # current user:group with no ownership prompt.
    if command -v python3 >/dev/null 2>&1; then
        _out=$(HOME="${CI_HOME}" GLOBAL_BIN="${CI_GLOBAL_BIN}" USER_BIN="${CI_USER_BIN}" \
            PTY_IN="q" ci_pty_run action 2>&1) || true
        assert_contains "TP-TAKE-OWNERSHIP-42 TTY action numbered list" "$_out" "Folders this login may take ownership of"
        assert_contains "TP-TAKE-OWNERSHIP-42 TTY action lists granted folder" "$_out" "${CI_HOME}/owned2"
        assert_not_contains "TP-TAKE-OWNERSHIP-42 TTY action no ownership prompt" "$_out" "Unix user:group for the new owner"
        _out=$(HOME="${CI_HOME}" GLOBAL_BIN="${CI_GLOBAL_BIN}" USER_BIN="${CI_USER_BIN}" \
            PTY_IN="${CI_HOME}/owned2" ci_pty_run action 2>&1)
        _ec=$?
        assert_eq "TP-TAKE-OWNERSHIP-43 TTY action pick path exit 0" 0 "$_ec"
        assert_contains "TP-TAKE-OWNERSHIP-43 TTY action uses current user:group" "$_out" "Taking ownership as ${_og}"
        assert_contains "TP-TAKE-OWNERSHIP-43 TTY action already matching" "$_out" "Already ${_og}: ${CI_HOME}/owned2"
        assert_not_contains "TP-TAKE-OWNERSHIP-43 TTY action no ownership prompt" "$_out" "Unix user:group for the new owner"
    else
        t_skip "TP-TAKE-OWNERSHIP-42 TTY action numbered list (no python3 for PTY)"
        t_skip "TP-TAKE-OWNERSHIP-43 TTY action current user:group (no python3 for PTY)"
    fi

    # TP-TAKE-OWNERSHIP-16 ram-drive project tree under /dev/shm is not refuse-list
    _ram="/dev/shm/take-ownership-ci-owned-$$"
    if [ -d /dev/shm ] && mkdir -p "${_ram}" 2>/dev/null; then
        HOME="${CI_HOME}" GLOBAL_BIN="${CI_GLOBAL_BIN}" USER_BIN="${CI_USER_BIN}" \
            sh "${SCRIPT}" generate-sudoer-request --update --path "${_ram}" --ownership "${_og}" >/dev/null 2>&1 || true
        _out=$(HOME="${CI_HOME}" GLOBAL_BIN="${CI_GLOBAL_BIN}" sh "${SCRIPT}" action --path "${_ram}" --ownership "${_og}" 2>&1)
        _ec=$?
        assert_eq "TP-TAKE-OWNERSHIP-16 ram-drive --path exit 0" 0 "$_ec"
        assert_not_contains "TP-TAKE-OWNERSHIP-16 not refuse-list" "${_out}" "system path"
        rmdir "${_ram}" 2>/dev/null || true
    else
        t_skip "TP-TAKE-OWNERSHIP-16 ram-drive tree (no writable /dev/shm)"
    fi

    ci_cleanup_env
}
