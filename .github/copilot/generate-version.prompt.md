---
mode: "agent"
description: "Generate a new version: update CHANGELOG.md, bump version in pubspec.yaml, commit and create git tag"
---

Perform the full release process for a new version of the project following these steps:

1. **Analyze commits**: Read the commit history since the last tag to understand what changed.

2. **Determine version**: Based on the commits, determine the next semantic version (patch, minor or major). Ask the user which version they want if it's not clear.

3. **Update CHANGELOG.md**: Add a new section with the version and today's date, categorizing changes under `### Added`, `### Fixed`, `### Changed`, `### Removed` as applicable. Follow the Keep a Changelog format.

4. **Update pubspec.yaml**: Bump the `version` field with the new version and increment the build number (number after `+`).

5. **Commit**: Create a commit with the message `chore: release vX.Y.Z`.

6. **Tag**: Create an annotated tag `vX.Y.Z` with the message `Release vX.Y.Z`.

7. **Final instructions**: Provide the push command with tags: `git push origin <branch> --tags`.
