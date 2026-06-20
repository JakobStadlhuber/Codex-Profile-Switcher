cask "codex-profile-switcher" do
  version "1.0.0"
  sha256 :no_check

  url "https://github.com/JakobStadlhuber/homebrew-codex-profile-switcher/releases/download/v#{version}/Codex-Profiles-#{version}.zip",
      verified: "github.com/JakobStadlhuber/homebrew-codex-profile-switcher/"
  name "Codex Profiles"
  desc "Menu bar app for switching local Codex CLI configuration profiles"
  homepage "https://github.com/JakobStadlhuber/homebrew-codex-profile-switcher"

  app "Codex Profiles.app"
end

