cask "codex-profile-switcher" do
  version "1.0.21"
  sha256 "a08bd23b84a64efbaaa009c008e3b0f19d7369f22b74aaf8c7bf45794bbe8373"

  url "https://github.com/JakobStadlhuber/Codex-Profile-Switcher/releases/download/v#{version}/Codex-Profiles-#{version}.zip"
  name "Codex Profiles"
  desc "Menu bar app for switching local Codex CLI configuration profiles"
  homepage "https://github.com/JakobStadlhuber/Codex-Profile-Switcher"

  depends_on macos: :sonoma

  app "Codex Profiles.app"

  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{appdir}/Codex Profiles.app"],
                   sudo: false
  end
end
