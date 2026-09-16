# Vroff AI Companion – Testing Releases

Public distribution repository for test builds of Vroff AI Companion.

This software is proprietary and is provided for testing purposes only.

Test binaries are distributed through GitHub Releases.

## Publishing a test build

Copy the example local configuration once, then point it at the Vroff checkout:

```sh
cp release-config.example release-config.local
```

`release-config.local` is ignored and may alternatively be replaced by an exported
`VROFF_DIR`.

## Releasing

The normal command is the portable Bash script:

```sh
./release-companion --interactive
```

It opens a target picker. Windows is first and unchecked; every other available
target is selected. Use arrow keys or `p`/`n` to move, Space to toggle and move
down, Backspace to toggle and move up, then Enter to continue.

For a non-mutating build and publication preview, add `--dry-run`:

```sh
./release-companion --interactive --dry-run
```

Dry runs build the selected artifacts, verify read-only GitHub access, and show
the proposed `index.json` change. They never pull, create a release, upload,
commit, or push; the release checkout may therefore contain local workflow
changes while you test it.

The initial tester release is `1.0.0`. From then on, developers can simply run
`./release-companion --interactive`. The script reads the source commit recorded
in the release for the current Companion version:

- If Vroff HEAD is unchanged, it resumes that release and uploads only missing
  selected platform artifacts.
- If Vroff HEAD has changed, it bumps the patch version (for example, `1.1.0`
  to `1.1.1`). Each component rolls over after `9`, so `1.0.9` becomes
  `1.1.0`, `1.1.9` becomes `1.2.0`, and `1.9.9` becomes `2.0.0`. It then
  commits and pushes that version-only Vroff change before building and
  publishing the new release.

Every tester build therefore has an immutable version and download URL, while a
failed or intentionally omitted platform can be completed without consuming a
new version. `--resume` remains available to require the first behavior
explicitly. A dry run refuses to auto-bump because it does not modify or commit
the Vroff checkout; an unchanged release can still be dry-run normally.

To build named targets without the picker:

```sh
./release-companion linux-deb linux-appimage windows-x64
```

With no arguments, `./release-companion` opens the picker. Use `--all` for a
non-interactive attempt at every available target, including Windows. Missing
target tools are reported and skipped in that mode; an explicitly named
unavailable target fails before any build. See `./release-companion --help` for
all target names and options.

The script requires a clean, pushed Vroff checkout and a clean release checkout.
It never replaces an existing release asset.

## NixOS

On x86_64 NixOS, the flake provides the packaging tools for the same script. It
opens the same picker and follows the same versioning rules:

```sh
nix run .
```

Pass script arguments after `--`, for example:

```sh
nix run . -- --dry-run
nix run . -- linux-deb linux-appimage
```

This is optional: developers with the required tools on `PATH` should use
`./release-companion` directly.

---

Copyright © Vroff. All rights reserved.
