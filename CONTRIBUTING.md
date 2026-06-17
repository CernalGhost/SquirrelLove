# Contributing to SquirrelLove

Thanks for helping improve SquirrelLove. This project is open to bug reports, feature ideas, and pull requests.

## Before you start

- Search [existing issues](https://github.com/CernalGhost/SquirrelLove/issues) to avoid duplicates.
- For gameplay questions, use [Discussions](https://github.com/CernalGhost/SquirrelLove/discussions) or open an issue with the **question** label.
- SquirrelLove is a **retail** addon. It does not target Classic flavors.

## Reporting bugs

Use the [bug report template](https://github.com/CernalGhost/SquirrelLove/issues/new?template=bug_report.yml) and include:

- WoW client version and addon version (from `/sqlove` or the AddOns list)
- Steps to reproduce
- What you expected vs. what happened
- Lua errors if any (`/console scriptErrors 1`, then `/reload`)
- Other addons enabled (especially TomTom)

## Suggesting features

Use the [feature request template](https://github.com/CernalGhost/SquirrelLove/issues/new?template=feature_request.yml). Explain the problem you are solving and how you imagine the feature working in-game.

## Pull requests

1. Fork the repo and create a branch from `main`.
2. Make focused changes. Match the existing Lua style in `SquirrelLove.lua`.
3. Test in-game: `/reload`, exercise the macro, waypoints, and UI.
4. Update `CHANGELOG.md` under an `## Unreleased` section (or the next version if you are bumping the `.toc`).
5. Open a PR against `main` and fill out the pull request template.

### WoW addon constraints

- Do not automate targeting + emoting outside the secure macro path. Blizzard blocks that for good reason.
- Critter names come from live achievement criteria; avoid hard-coded critter lists unless fixing a `NAME_FIXES` edge case.
- Keep the addon self-contained. Optional dependency: TomTom only.

## Development setup

```text
World of Warcraft\_retail_\Interface\AddOns\SquirrelLove\
  SquirrelLove.toc
  SquirrelLove.lua
  ...
```

Clone or symlink the repo folder there, `/reload`, and use `/sqlove debug` for state dumps.

## Releases

Maintainers tag versions matching `## Version:` in `SquirrelLove.toc` (e.g. `v1.0.10`). Pushing a tag runs the GitHub Actions packager and creates a release zip.

## License

By contributing, you agree that your contributions are licensed under the same [MIT License](LICENSE) as the project.
