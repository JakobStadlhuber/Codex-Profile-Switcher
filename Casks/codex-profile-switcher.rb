cask "codex-profile-switcher" do
  version "1.0.2"
  sha256 "e4ce8efa224f47ef38fdf60890e25c57ed507f6b1a86c501dc7185a778e60549"

  url "https://github.com/JakobStadlhuber/Codex-Profile-Switcher/releases/download/v#{version}/Codex-Profiles-#{version}.zip"
  name "Codex Profiles"
  desc "Menu bar app for switching local Codex CLI configuration profiles"
  homepage "https://github.com/JakobStadlhuber/Codex-Profile-Switcher"

  depends_on macos: ">= :sonoma"

  app "Codex Profiles.app"
end
