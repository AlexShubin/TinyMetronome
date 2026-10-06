---
name: release
description: App Store release flow — start a release branch with version/build bump, bump builds for re-uploads, finish by squash-merging into main and tagging. Use when starting a new release, bumping the build number, or wrapping up a released version.
---

# Release flow

A release lives on a `release/MAJOR.MINOR.PATCH` branch with a PR against main. The lifecycle: branch → bump immediately → open PR → do the work → user uploads/releases via Xcode → squash-merge the PR → tag.

All commits and pushes in this flow follow the project's git rules: explicit per-action permission, every time.

## Versioning rules

- `appVersion` and `buildNumber` are declared once at the top of `TinyMetronome/Project.swift` and feed both the Info.plist (`CFBundleShortVersionString` / `CFBundleVersion`) and the build settings (`MARKETING_VERSION` / `CURRENT_PROJECT_VERSION`). Edit them there, nowhere else.
- **`appVersion` is always three-part `MAJOR.MINOR.PATCH`** (e.g. `1.2.0`) — including the trailing `.0` for non-patch releases. This matches the git release tags (`vMAJOR.MINOR.PATCH`): a release's tag is its `appVersion` with a `v` prefix, one-to-one.
- **A regular release bumps MINOR** (`1.3.0` → `1.4.0`), regardless of the change's size or user-visibility. **PATCH is reserved for hotfixes** — urgent fixes on top of an already-released version. Never pick the patch number just because a release "feels small".
- **`buildNumber` only ever goes up — never reset it.** It must strictly increase across the app's entire lifetime. The App Store rejects any upload whose build number isn't higher than the last build it received, even when the marketing version changes. Bumping `appVersion` does **not** allow resetting `buildNumber` — every version bump also increments `buildNumber`.
- After editing `Project.swift`, run `mise run generate`.

## Starting a release

1. `git checkout main && git pull`
2. `git checkout -b release/X.Y.Z`
3. Immediately bump `appVersion` to `X.Y.Z` and increment `buildNumber` in `TinyMetronome/Project.swift`, then `mise run generate`.
4. Commit the bump (e.g. `Bump version to X.Y.Z (build N)`) and push the branch — with permission.
5. Open the release PR: `gh pr create --base main --title "Release X.Y.Z"`.

## During the release

- Feature/fix work happens on the branch with the normal review→test→commit cadence.
- Each new upload to App Store Connect needs a `buildNumber` increment (commit it before the user archives).

## Finishing a release

Only after the user confirms the version is released on the App Store:

1. Squash-merge the PR via GitHub: `gh pr merge --squash --delete-branch --subject "Release X.Y.Z"` — one squash commit on main titled `Release X.Y.Z`; `--delete-branch` removes the branch on origin and locally and switches back to main.
2. `git pull` on main, then tag the squash commit: `git tag vX.Y.Z && git push origin vX.Y.Z`.
3. `git fetch --prune` to clean up.
