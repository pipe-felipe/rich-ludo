---
name: generate-version
description: Cut a new RichLudo release - bump the version in pubspec.yaml, update CHANGELOG.md and the README badge, commit, and create an annotated git tag. Use when the user asks to "release a new version", "bump the version", "cut a release", or "tag vX.Y.Z".
---

# Generate a new release

Perform the full release process for a new version of RichLudo.

## Steps

1. **Analyze commits since the last tag**: run `git tag --sort=-creatordate | head -1` to find the last tag (format `vX.Y.Z`), then `git log <last-tag>..HEAD --oneline` to see what changed. If there is no tag yet, use the full `git log --oneline`.
2. **Determine the next semantic version** (patch/minor/major) from those commits. If it isn't obvious (e.g. the commits mix breaking and non-breaking changes), ask the user which bump they want instead of guessing, especially for a major bump.
3. **Update `CHANGELOG.md`**:
   - The file follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and keeps an `## [Unreleased]` section at the top.
   - If `## [Unreleased]` already has entries, turn it into `## [X.Y.Z] - YYYY-MM-DD` (today's date) and reuse those entries as the base, adding anything from the commit log that's missing.
   - If `## [Unreleased]` is empty or absent, build the new `## [X.Y.Z] - YYYY-MM-DD` section directly from the commit log.
   - Group entries under `### Added`, `### Fixed`, `### Changed`, `### Removed` as applicable; leave an empty `## [Unreleased]` section above the new version for future work.
4. **Update `pubspec.yaml`**: bump the `version:` field, which is `X.Y.Z+B` — increment the semantic version and the build number `B` after `+`.
5. **Update `README.md`**: update the shields.io version badge (`https://img.shields.io/badge/version-X.Y.Z-green`) to the new version.
6. **Commit**: stage exactly `CHANGELOG.md`, `pubspec.yaml`, and `README.md` (do not sweep in unrelated worktree changes) and commit as `chore: release vX.Y.Z`.
7. **Tag**: create an annotated tag: `git tag -a vX.Y.Z -m "Release vX.Y.Z"`.
8. **Do not push.** Tell the user the exact command to push (`git push origin <branch> --tags`) and let them run it.

## Guardrails

- Never force-push, amend, or skip commit hooks.
- Never push or push tags yourself — only the commit and the local tag are your responsibility.
- Confirm the version bump with the user before writing files whenever the commit history is ambiguous.
- If `CHANGELOG.md`, `pubspec.yaml`, or the README badge already reflect the intended version, say so and stop instead of duplicating the release.
