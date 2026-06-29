cask "codex-profile-switcher" do
  version "1.0.19"
  sha256 "e443b60c1936a18db99bf2bba5346f41b62a7ac886cebdb8b39588d82fe25d0a"

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
