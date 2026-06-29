cask "codex-profile-switcher" do
  version "1.0.16"
  sha256 "bd03b7551f0a03bcde6dac8f7d47419868f33bc0534198f465a279e502cfd95e"

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
