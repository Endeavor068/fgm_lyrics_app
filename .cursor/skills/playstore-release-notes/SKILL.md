---
name: playstore-release-notes
description: >-
  Bumps the Flutter app version and writes bilingual Google Play Store “What’s
  new” release notes plus CHANGELOG.md. Use when the user asks for Play Store
  changelog, nouveautés Play Console, version bump, numéro de version, what’s
  new, release notes, or a new store build number.
---

# Play Store release notes + version

Produce a **new version number**, update project files, and deliver **EN + FR**
copy-paste text for Google Play Console “What’s new”.

Default audience: **store listing** (end users), not developers.

## Mandatory workflow

```
Release progress:
- [ ] Step 1 — Collect changes since last release
- [ ] Step 2 — Decide bump type + next version
- [ ] Step 3 — Draft EN/FR Play notes (≤ 500 chars each)
- [ ] Step 4 — Update pubspec.yaml + CHANGELOG.md
- [ ] Step 5 — Show user the Play Console blocks to copy
```

Ask before applying file writes only if the user said “propose” / “suggest”
without asking to update files. Otherwise **apply** `pubspec.yaml` +
`CHANGELOG.md` by default.

## Step 1 — Collect changes

Run in parallel when possible:

```bash
grep -E '^version:' pubspec.yaml
head -80 CHANGELOG.md
git log --oneline -40
git status -sb
git diff --stat HEAD
```

Also scan recent Cursor agent transcripts when useful for user-visible work
that never landed as a clean commit message.

**Include:** features, UX polish, fixes users will notice.  
**Exclude / soften:** refactors, deps-only, internal renames, debug logs.

## Step 2 — Version number (Flutter)

`pubspec.yaml` format: `MAJOR.MINOR.PATCH+BUILD`

| Signal | Bump |
|--------|------|
| Bug fixes / small polish only | `PATCH` +1, `BUILD` +1 |
| New user-visible features / UX | `MINOR` +1, reset `PATCH` to `0`, `BUILD` +1 |
| Breaking / major product shift | `MAJOR` +1, reset `MINOR`/`PATCH` to `0`, `BUILD` +1 |

Rules:
- Always increment **BUILD** (`+N`) for every store upload.
- Never reuse a BUILD already shipped.
- Prefer the next logical number after the latest entry in `CHANGELOG.md` and
  current `pubspec.yaml` (take the higher of the two if they diverge).

Announce the chosen version and why (patch vs minor vs major) in one sentence.

## Step 3 — Play Console copy

Constraints:
- **≤ 500 characters** per locale (hard Play limit).
- 4–7 short bullets max.
- User benefit language; no file paths, class names, or git hashes.
- Lead with the strongest user-facing change.

Templates:

```
What's new in {VERSION}

• …
• …
```

```
Nouveautés de la version {VERSION}

• …
• …
```

French: natural FR, not word-for-word from EN.  
Keep EN and FR **aligned** (same points, same order).

## Step 4 — Write project files

### `pubspec.yaml`

Set:

```yaml
version: {MAJOR.MINOR.PATCH}+{BUILD}
```

### `CHANGELOG.md`

Prepend a section matching this project’s existing style:

```markdown
## [{VERSION}] — {YYYY-MM-DD}

**Build:** `{VERSION}+{BUILD}`

### Added
- …

### Changed
- …

### Fixed
- …

### Notes for Google Play Console (“What’s new”)

**English (default)** — copy into Play Console (≤ 500 characters)

\`\`\`
What's new in {VERSION}

• …
\`\`\`

**Français**

\`\`\`
Nouveautés de la version {VERSION}

• …
\`\`\`

---
```

Omit empty subsections. Keep older changelog entries intact below.

## Step 5 — User-facing delivery

After writing files, reply with:

1. Proposed version + bump rationale (1 line)
2. Confirmation that `pubspec.yaml` / `CHANGELOG.md` were updated
3. The two Play Console blocks ready to copy (EN then FR)

Do **not** create a git commit unless the user explicitly asks.

## Quality checklist

- [ ] BUILD number increased vs previous store build
- [ ] EN and FR Play notes ≤ 500 characters
- [ ] Bullets are user-visible, not engineering jargon
- [ ] CHANGELOG date is today’s date from user context when available
- [ ] No secrets or internal URLs in store copy

## Extra detail

- For sample EN/FR tone, see [examples.md](examples.md).
