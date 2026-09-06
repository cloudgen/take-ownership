# Report: README / requirements / coverage — take-ownership 2.7.1

**Date:** 2026-09-06  
**Mode:** review + implement (user authorized fix, commit, push)  
**Status:** closed this run (maps retargeted; TP-44 have)

## Summary

README was hard to read (workshop jargon, leftover backup/restore). Public `reviews/` still named folder-backup and claimed `TP-FOLDER-BACKUP-*` **have** while `tests/` has none of those IDs. Six Active requirements lacked **§1.1 Human-facing**. Related shell requirements lacked a section **literally titled** **Under command line for normal user only**. **TP-TAKE-OWNERSHIP-44** (granted-missing directory) was **todo** (L-OPS-01 / INC-20260830-001). SECURITY.md still described folder-backup and `--allow-test-local`.

This run rewrote README and SECURITY in people-and-folders voice, added missing requirement human-facing / Termux-class sections, implemented granted-missing pick + recreate copy, retargeted coverage maps, filled product checklists, and locked **TP-TAKE-OWNERSHIP-44**.

Lessons re-checked: **L-OPS-01** closed; **L-MAP-01** closed; **L-SUDOERS-02** still open watch (global-only); **L-OUTPUT-01** still open watch (wording).

## Issues

### Issue 1 -- Severity: bug
- File: src/take-ownership (TTY pick / missing-dir `[ERROR]`)
- Description: Granted `--path` that is not an existing directory was a live TTY pick; `action --path` did not name recreate-then-action.
- Suggestion: Filter live pick to existing dirs; mark `list-folders`; recreate copy.
- Lesson: L-OPS-01
- Test: TP-TAKE-OWNERSHIP-44
- Status: closed

### Issue 2 -- Severity: bug
- File: reviews/what-to-review.md, reviews/test-plan.md, reviews/README.md, reviews/requirement-test-matrix.md
- Description: Maps still said folder-backup / VERSION 1.11.0 / TP-FOLDER-BACKUP backup/restore **have**.
- Suggestion: Rebind to take-ownership live TPs.
- Lesson: L-MAP-01
- Test: n/a (docs honesty)
- Status: closed

### Issue 3 -- Severity: suggestion
- File: README.md, SECURITY.md
- Description: People-facing docs led with jargon and leftover deposit/restore / `--allow-test-local`.
- Suggestion: Voice pack + honest take-ownership trust notes.
- Status: closed

### Issue 4 -- Severity: suggestion
- File: docs/requirements/requirement-shell-*.md (six files without §1.1; related shell REQs without the Termux-class heading)
- Description: Human-readable-law / SK-REQUIREMENT-REVIEW 2.25.0 gaps.
- Suggestion: Add §1.1 and **Under command line for normal user only**.
- Status: closed

## Checklists this run

- `docs/checklists/2026-09-06-checklist-operator-readable-error-take-ownership.md` — **Pass**
- `docs/checklists/2026-09-06-checklist-create-sudoers-security-take-ownership.md` — **Pass** (no `/etc` write)

## Verdict

**Revise → closed** after implement. Suite: PASS=277 FAIL=0 SKIP=0.
