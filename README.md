# Codex Profile Switcher

A macOS menu bar app for switching between local Codex CLI configuration profiles.

It stores profile snapshots in `~/.codex/profile-switcher/profiles` and applies a selected profile by writing it to `~/.codex/config.toml`, then restarting Codex.

This is an unofficial utility. It is not affiliated with, endorsed by, or sponsored by OpenAI.

## Install With Homebrew

Recommended install:

```sh
brew tap JakobStadlhuber/codex-profile-switcher https://github.com/JakobStadlhuber/Codex-Profile-Switcher && brew trust JakobStadlhuber/codex-profile-switcher && brew install --cask codex-profile-switcher
```

The personal tap clears macOS quarantine after install while releases are unsigned. A future Developer ID signed and notarized release will remove that workaround.

## Screenshots

Menu bar profile switching:

![Menu bar profile switcher](Assets/Screenshots/menu-bar.png)

Profile manager:

![Codex Profile Manager](Assets/Screenshots/profile-manager.png)

## Features

- Switch between saved Codex configuration profiles from the menu bar.
- Manage, edit, duplicate, and delete profiles in a SwiftUI window.
- Create a profile from the current `~/.codex/config.toml`.
- Optionally attach a file-based Codex login snapshot to a profile.
- Back up `~/.codex/config.toml` before applying a profile.
- Launch automatically after login from the menu bar toggle.
- Prevent multiple menu bar instances from running at the same time.

## Profiles

Profiles are plain TOML files stored here:

```text
~/.codex/profile-switcher/profiles
```

The filename is used as the display name:

```text
OpenAI Account.toml
Azure OpenAI API.toml
Ollama GLM 5.2 Cloud.toml
```

## Optional Login Switching

Profiles can optionally capture the current file-based Codex login from:

```text
~/.codex/auth.json
```

Saved login snapshots are stored privately under:

```text
~/.codex/profile-switcher/auth
```

To use this feature, configure Codex to use file-based credential storage:

```toml
cli_auth_credentials_store = "file"
```

Then sign in with Codex, select a profile, and click **Capture Current Login**. Applying that profile later restores its saved login before restarting Codex. Treat saved auth snapshots like passwords; they contain Codex access tokens.

## Build From Source

Open the project in Xcode and run the `CodexProfileSwitcher` scheme.

From the command line:

```sh
xcodebuild -project "Codex Profile Switcher.xcodeproj" -scheme CodexProfileSwitcher -configuration Debug build
```

## Notes

- Codex is expected at `/Applications/Codex.app`.
- Applying a profile writes to `~/.codex/config.toml`.
- Applying a profile with an attached login writes to `~/.codex/auth.json`.
- Automatic launch starts the menu bar app when the user logs in after a reboot.
- Do not distribute personal profile files, API keys, or generated config backups.
