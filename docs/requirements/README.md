# Requirements

Authoritative specialized product law for **take-ownership** lives here.

**Current state (2026-08-25):** Specialized **software-development** product. Bootstrap **cli-template → folder-backup → take-ownership** (domain replace). Registry is populated — see `index.md`.

## Product identity (summary)

| Field | Value |
|-------|--------|
| Product / `APP_NAME` | `take-ownership` |
| Version SSOT | ship unit hard-assign |
| Ship unit | `src/take-ownership` |
| Default user install | `${HOME}/.local/bin/take-ownership` |
| Production elevation path | `/usr/local/bin/take-ownership` (**required** before grant emit) |
| Install mode | **Local-only** / non-online-installable |
| Ops | `requirement-take-ownership-ops` — recursive chown, no symlink follow |
| Domain surface | `requirement-domain-take-ownership` — four pillars; ops deferred |
| JSON sudoer file | `requirement-sudoer-json-file` — global binary only; `action --path <folder> --ownership *` plus `--json` twin |

## Class requirement gate

| Class | Required class file |
|-------|---------------------|
| software-development | `requirement-class-software-dev.md` (**Active**) |
| genesis-template | N/A — this workspace is no longer genesis |

## Purpose

- **Plan** designs work by reading and updating these docs.  
- **Implement** delivers code that **traces** to these requirements.  
- **Review** verifies delivery against requirements and CIAO checklists.

## Layout

| Path | Role |
|------|------|
| `docs/requirements/index.md` | Registry of all requirements — keep in sync |
| `docs/requirements/requirement-*.md` | CIAO-style project requirements |

## Status values

Typical: `draft` · `Active` · `approved` · `in-progress` · `done` · `deprecated` · `superseded`

## Rules

1. Never invent paths — verify on disk.  
2. Class files only via class process; non-class via create-specific process.  
3. Never dump harness inventories into this versioned surface.  
4. Online install requirements stay **absent** unless product mode is explicitly changed.  
5. Sole domain SSOT: `requirement-domain-take-ownership.md`.
