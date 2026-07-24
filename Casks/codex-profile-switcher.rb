cask "codex-profile-switcher" do
  version "1.0.24"
  sha256 "37ed6a85cd2f4cf85bf563e95da1f561f8628da371225cb840a2befd29ba5ce2"

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
