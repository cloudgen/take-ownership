# Report: harness knowledge + current project — take-ownership 2.3.0

**Date:** 2026-08-30  
**Mode:** audit-only (SK-REVIEW-HARNESS-KNOWLEDGE + SK-PRODUCT-REVIEW). No dest-SSOT rebind; no ship-unit edits.  
**Status:** open items  
**Product:** take-ownership `VERSION=2.3.0` (uncommitted working tree)  
**Ship unit:** `src/take-ownership`  
**PROJECT_SSOT:** hard-disk `take-ownership` (`/dev/shm/take-ownership` absent)  
**Observed class:** **software-development** (disk). Agent OS maps still say **genesis-template**.  
**Suite this run:** `./tests/run.sh` **PASS=207 FAIL=0 SKIP=0**  
**Lessons loaded:** `reviews/lessons.md` (all L-* open watch)

## Summary

This dest is a specialized **take-ownership** product (class law, 24 `requirement-*.md` files, ship unit 2.3.0). Portable harness **payload counts** (skills 65, terms 314, policies 19, blank CL 47, law molds 97, proof 15) match disk and skills/terms indexes. Agent OS maps (`AGENTS.md`, `docs/README.md`) still claim **genesis-template / 0 REQs / no ship unit / sh-cli-template**, which is a dest-SSOT honesty **Block**. The uncommitted 2.3.0 work correctly withdraws `--ownership *` gold, fences `user:group`, escapes `:` in sudoers text, and the suite is green. Public `reviews/` living files (`what-to-review.md`, `test-plan.md` header, `reviews/README.md`) remain **folder-backup 1.11.0**, so a full product-review Pass is not honest.

## Strengths

| Area | Notes |
|------|--------|
| Ownership fence (2.3.0) | `to_fence_ownership_operand` + `to_require_grant_ownership`; generate/action refuse `*`; dirty-cwd JSON keeps `user:group` (TP-27/27b); globbed/`*` inbound fail-closed (TP-28/28b); text dual `user\:group` (TP-31) |
| Operate skill already aligned | `SK-USE-TAKE-OWNERSHIP` **1.6.1** never `--ownership *`; replacement union; list-folders before action |
| New product law | Untracked `requirement-incorrect-ownership-parameter.md` 1.0.0 registered in `docs/requirements/index.md` |
| Privilege residual | Global-only grant; no `--allow-test-local`; no `/bin/chown` Cmnd; Type N empty argv still help |
| Harness payload (non-map) | Skills README 65/65 no orphan/phantom; eleven-class wording clean; keep-set floor present; no blacklisted language-pack leftovers |
| Suite | PASS=207 FAIL=0 SKIP=0 on this tree |

## Issues

### Issue 1 -- Severity: bug
- File: AGENTS.md:47
- Description: **H-HK-01 / TO-MAP-01.** This-workspace live inventory claims genesis-template, template-name `sh-cli-template`, **0** `requirement-*.md`, no ship unit. Disk is software-development take-ownership with 24 requirement files and `src/take-ownership`. Same lie in `docs/README.md` Live inventory snapshot. Protection Rule of SK-REVIEW-HARNESS-KNOWLEDGE: genesis claim with REQs = **Block**. SK-DEST-SSOT-MAP-REBIND §5.2: never leave genesis 0 REQs on a specialized dest.
- Suggestion: User-authorize **`SK-DEST-SSOT-MAP-REBIND`**. Do not empty REQs to make maps “honest.”
- Lesson: L-MAP-01
- Test: n/a (map honesty)
- Status: open

### Issue 2 -- Severity: bug
- File: reviews/what-to-review.md:1
- Description: **TO-REV-01.** Living product review plan is still **folder-backup** (ship unit `src/folder-backup`, VERSION 1.11.0, suite PASS=296 SKIP=2, `--allow-test-local`, backup/restore, TP-FOLDER-BACKUP). Same identity on `reviews/README.md`, `reviews/test-plan.md` header, `reviews/index.md` title. SK-PRODUCT-REVIEW Protection: incomplete/wrong review plan while JSON grant + Type 1 residual are in scope → **Revise/Block**, not Pass.
- Suggestion: Rebind `what-to-review.md`, `test-plan.md`, `reviews/README.md`, matrix title to take-ownership 2.3.0; drop live backup/restore/`--allow-test-local` gates; keep lineage only where superseded.
- Lesson: L-MAP-01
- Test: n/a (plan honesty)
- Status: open

### Issue 3 -- Severity: suggestion
- File: README.md:54
- Description: **TO-DOC-01.** After 2.3.0, `print-sudoers` / `print-sudoers-install-script` call `to_require_grant_ownership`. README still shows `take-ownership print-sudoers-install-script --path /var/www/html` with no `--ownership`. That one-liner now fail-closes.
- Suggestion: Add `--ownership www-data:www-data` (or equivalent) on that line, matching generate/submit examples above it.
- Lesson: L-OUTPUT-01 (operator next step)
- Test: none today (docs)
- Status: open

### Issue 4 -- Severity: suggestion
- File: reviews/test-plan.md:121
- Description: **TO-PLAN-01.** Suite **has** TP-TAKE-OWNERSHIP-29/29b/29c/28b/31/33/33b/34; living `test-plan.md` only retargeted TP-27. Header still folder-backup 1.11.0. `requirement-test-matrix.md` added the new REQ row but still titles folder-backup and lists retired backup REQs as if live TP families.
- Suggestion: Add missing TP-TAKE-OWNERSHIP rows as **have**; mark folder-backup ops TPs **n/a / superseded**; retitle matrix.
- Lesson: L-TEST-REVIEW-01
- Test: TP-TAKE-OWNERSHIP-29 family (have in suite, missing from plan)
- Status: open

### Issue 5 -- Severity: suggestion
- File: tests/test_domain_take_ownership.sh:149
- Description: **TO-JR-01.** JSON grant is in scope. This suite locks emit + readable inbound glob/`*` fail-closed. It does **not** run sibling `sudoer-cli` convert/submit of pretty `user:group` JSON (parent JR-3/JR-4 / TP-FOLDER-BACKUP-22e). Emit-only green is not that gate (`skill-product-review` §2.6).
- Suggestion: When sudoer-cli is available in CI, add convert + queued-body TPs for exact `action --path F --ownership user:group` plus `--json` twin. Do not treat stub `cp` as fidelity.
- Lesson: L-SUDOERS-06 · L-TEST-REVIEW-01
- Test: TODO (no TP-TAKE-OWNERSHIP convert/submit-body row)
- Status: open

### Issue 6 -- Severity: nit
- File: src/take-ownership:2120
- Description: **TO-ERR-01.** `to_require_grant_ownership` always passes context `generate-sudoer-json` into `to_fence_ownership_operand`, so print-sudoers / submit fatals tell the operator that verb even when they ran another command. Copy still names user:group and forbids `*`.
- Suggestion: Pass the live `${COMMAND}` (or a grant-emit family name) as `_ctx`.
- Lesson: L-OUTPUT-01
- Test: TP-CLI-04 / TP-29 (human text)
- Status: open

## Non-findings (explicitly OK)

| Check | Result |
|-------|--------|
| Harness skill inventory | 65 files = skills README unique basenames; 0 orphan, 0 phantom |
| Eleven-class SSOT | `project-class.md` exactly eleven; no “three/four peer classes” |
| Stripped keep/deny | No `skill-python-*` / circuit / named nginx leftovers; keep-set floor present |
| `--ownership *` in live grant emit | Withdrawn in ship unit + SK-USE-TAKE-OWNERSHIP 1.6.1; CHANGELOG 2.0.0/2.2.0 rows stay historical |
| Global-only / no USER_BIN sudoers | TP-TAKE-OWNERSHIP-03/30/31 |
| Operator-readable inbound glob | TP-28 names user:group + generate-sudoer-json + generate-sudoer-request; no `sibling re-encode` |
| Type N empty argv | TP-CLI-07 still help |
| Online verbs | TP-CLI-10 still rejected |
| Secrets in harness | None found in this audit |
| Replacement-union path extract | Compact JSON no longer uses greedy sed (TP-33 keeps first folder) |

## Operator-readable error (CL-OPERATOR-READABLE-ERROR)

In scope: 2.3.0 blocking paths for `*` / missing `--ownership` / globbed inbound.

| ID | Result |
|----|--------|
| E1 what happened | Pass — wildcard / user:group / glob named |
| E2 next step | Pass on TP-28 (generate-sudoer-json); nit TO-ERR-01 on print-sudoers ctx |
| E3 no jargon-only | Pass — TP-28 asserts no `sibling re-encode` |
| E4–E7 | N/A or unchanged printers |

**Verdict:** Pass with nit (Issue 6).

## JSON re-encode / inbound fidelity

| ID | Result |
|----|--------|
| JR-1 emit exact argv | Pass — TP-22/27 `user:group`, no `"*"` |
| JR-2 pretty fixture | Not the 2.3.0 gold (compact generate); not scored Pass |
| JR-3 sibling convert | **Not run** (TO-JR-01) |
| JR-4 sibling submit body | **Not run** (TO-JR-01) |
| JR-5 readable inbound missing/wrong ownership | Pass — TP-28/28b fail-closed |
| JR-6 suite rows | Partial — 27/28 have; convert TPs missing |
| JR-9 independent generate dest | Pass — TP-24 dest exists without sudo |

Incomplete as a full JR gate → product **Revise**, not Pass.

## Harness knowledge (CL-REVIEW-HARNESS-KNOWLEDGE)

Filled: `docs/checklists/2026-08-30-checklist-review-harness-knowledge-take-ownership.md`  
**Verdict: Block** (H-HK-01). Payload counts otherwise match. Audit-only: maps not rewritten.

## Priority remediation order

1. **`SK-DEST-SSOT-MAP-REBIND`** on this dest (`AGENTS.md` + `docs/README.md` live inventory → software-development, REQ count + `docs/requirements/index.md`, ship unit, tests/reviews present).  
2. Rebind public `reviews/` living files from folder-backup 1.11.0 → take-ownership 2.3.0.  
3. Fix README `print-sudoers-install-script` example (`--ownership`).  
4. Add missing TP rows; optional real sudoer-cli convert/submit-body tests.

## Related

| Artifact | Role |
|----------|------|
| `docs/checklists/2026-08-30-checklist-review-harness-knowledge-take-ownership.md` | Harness checklist run |
| `docs/requirements/requirement-incorrect-ownership-parameter.md` | New fence law (untracked) |
| `docs/skills/skill-dest-ssot-map-rebind.md` | Map fix procedure (not applied) |
| `docs/skills/skill-use-take-ownership.md` | Operate skill already 1.6.1 |

**Written by:** SK-REVIEW-HARNESS-KNOWLEDGE + SK-PRODUCT-REVIEW (council)  
**Review status:** Findings open — harness **Block**; product 2.3.0 change **Revise**
