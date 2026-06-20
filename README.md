# Codex Profile Switcher

A small macOS menu bar app for switching between local Codex CLI configuration profiles.

The app stores profile snapshots in `~/.codex/profile-switcher/profiles` and applies a selected profile by writing it to `~/.codex/config.toml`. When a profile is applied, the app restarts Codex so the new configuration is picked up.

## Status

This is an unofficial utility. It is not affiliated with, endorsed by, or sponsored by OpenAI.

## Features

- Switch between saved Codex configuration profiles from the menu bar.
- Manage, edit, duplicate, and delete profiles in a small SwiftUI window.
- Create a profile from the current `~/.codex/config.toml`.
- Automatically backs up `~/.codex/config.toml` before applying a profile.
- Prevents multiple menu bar instances from running at the same time.

## Profiles

Profiles are plain TOML files stored here:

```text
~/.codex/profile-switcher/profiles
```

The filename is used as the display name. For example:

```text
OpenAI Account.toml
Azure OpenAI API.toml
Ollama GLM 5.2 Cloud.toml
```

## Build

Open the project in Xcode and run the `CodexProfileSwitcher` scheme.

From the command line:

```sh
xcodebuild -project "Codex Profile Switcher.xcodeproj" -scheme CodexProfileSwitcher -configuration Debug build
```

## Notes

- The app expects Codex to be installed at `/Applications/Codex.app`.
- Profile switching writes to `~/.codex/config.toml`.
- The app is intended for local use and should not be distributed with personal profile files, API keys, or generated config backups.

