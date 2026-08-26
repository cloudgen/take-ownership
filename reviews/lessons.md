# Lessons — take-ownership

Durable failure modes. **Always re-check on product review.**

| ID | Mode | Prevention | Status |
|----|------|------------|--------|
| L-TYPE-N-01 | Empty argv becomes install-ensure (parent Type O leak) | `requirement-shell-cli-zero-arguments` Type N; TP-CLI-07 | open watch |
| L-ONLINE-01 | Online verbs reintroduced (self-update / SCRIPT_URL UX) | A=cli-template already absent + TP-CLI-04/10 | open watch |
| L-UNIN-01 | Non-interactive uninstall succeeds without force | TP-LC-05 confirm fail-closed | open watch |
| L-INST-MODE-01 | Install leaves `0711`/`0700` (chmod +x after mktemp) so non-owners cannot run shell ship unit | absolute `chmod 0755` + heal on reinstall; TP-LC-09/10; local-self-management §2.3.1 | open watch |
| L-DEPOSIT-01 | Unprivileged write to `/var/backup` or silent deposit success without sudo | fail-closed + print-sudoers; TP-FOLDER-BACKUP-05 | open watch |
| L-SUDOERS-01 | Auto-write `/etc/sudoers.d` or `NOPASSWD: ALL` fragment | print-only + install-script handoff; narrow Cmnd; TP-FOLDER-BACKUP-01/02/14 | open watch |
| L-SUDOERS-02 | Local `~/.local/bin` treated as production-secure for sudoers (user rewrites binary → jailbreak) | **Global-only** grant; generate/submit fail closed without GLOBAL_BIN; no `--allow-test-local`; TP-TAKE-OWNERSHIP-03/30 | open watch |
| L-SUDOERS-03 | Confuse draft removal with host elev removal (or Type 0 delete under `/etc`) | `remove-project-sudoers` draft-only + admin script uninstall; TP-FOLDER-BACKUP-15 | open watch |
| L-SUDOERS-04 | Shared `/etc/sudoers.d/{{APP_NAME}}` basename overwrites another user’s fragment on multi-user host | Per-user draft + installed `{{APP_NAME}}-<user>`; multi-draft list/choose; TP-FOLDER-BACKUP-14/15/15b | open watch |
| L-SUDOERS-05 | Generate fragment as wrong user (`id -un` mismatch with backup operator) | Generate as elevating login; User lines = invoking user; review fragment before install | open watch |
| L-PUSH-VAULT-01 | Bare `git push` uses wrong active SSH vault when default face ≠ repository-user | Pre-git report + `GIT_SSH_COMMAND -i` / activate matching vault (SK-COMMIT-CHECK §3.3); incident 20260810-001 | open watch |
| L-OVERWRITE-01 | Same-day archive overwrite without next-N | naming allocator; TP-FOLDER-BACKUP-08 when root | open watch |
| L-SETU-01 | `set -u` crash with unset HOME | TP-CLI-11 | open watch |
| L-STOR-01 | Shared world-writable storage / stage roots not matching sudoers wildcards | util_resolve_storage; per-user stage; TP-CLI-12 · TP-FOLDER-BACKUP-02 | open watch |
| L-INBOUND-01 | Submit probes only home `sudoer-approving` (or Type 0 `mkdir` inbound) | Public inbound first (`/var/sudoer-cli/sudoer-request`); no mkdir; TP-FOLDER-BACKUP-21/21b | open watch |
| L-SUDOERS-06 | `[OK] submit` inbound is restore-only while emit/purpose list backup+restore | Inbound is sibling **re-encode**; count `commands[].args` before approve; pretty JSON trips `sudoer-cli` `},{` split; INC-20260817-001 | open watch |
| L-SUDOERS-07 | Installed verb-only fragment ≠ `backup <folder>` (file exists / `sudo -n -l` still password on the operand) | Trailing sudoers `*`; do not skip on TTY or file existence; INC-20260823-001 | open watch |
| L-SUDOERS-08 | Submit of JSON `"*"` lands as cwd listing in inbound/`/etc` (unquoted sibling encode glob) | Fail closed unless inbound args stay `["backup","*"]`; convert ≠ submit re-encode; do not approve `ls` names; INC-20260823-002 | open watch |
| L-OUTPUT-01 | Submit fail-closed `[ERROR]` uses inbound/verb/sibling-re-encode jargon; operator cannot act | Fatal submit errors must name the missing grant, do-not-approve request id, and next command (`generate-sudoer-request`); **requirement-operator-readable-error**; TP-25*; incomplete inbound JSON is **not** a standing expected class (owner); INC-20260817-002 | open watch |
| L-TEST-REVIEW-01 | Green emit TP-22 + stub TP-20 + S14 Pass miss sibling decode drop | Assert inbound after **real** sudoer-cli; pretty + compact fixtures; do not treat `tests/run.sh` PASS as grant fidelity; INC-20260817-001 | open watch |

**Bootstrap parent lessons (cli-template) still relevant for kept surfaces:** output SSOT, no basename gate on entry, storage isolation, Type N empty argv, local-only install. Historical selfmanaged lessons apply only as retired-hop context.
