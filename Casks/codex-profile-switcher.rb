cask "codex-profile-switcher" do
  version "1.0.0"
  sha256 "19a6c5bdc42ff573ffb907136fca79b2f85f9f2e158fd23ed5ba7cfa42a2e648"

  url "https://github.com/JakobStadlhuber/Codex-Profile-Switcher/releases/download/v#{version}/Codex-Profiles-#{version}.zip",
      verified: "github.com/JakobStadlhuber/Codex-Profile-Switcher/"
  name "Codex Profiles"
  desc "Menu bar app for switching local Codex CLI configuration profiles"
  homepage "https://github.com/JakobStadlhuber/Codex-Profile-Switcher"

  app "Codex Profiles.app"
end
