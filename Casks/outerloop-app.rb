cask "outerloop-app" do
  version "0.1.6"
  sha256 "8dbbf2d7a47eca6f991ef7beb201e365af841af04476363438d223f874141a59"

  url "https://github.com/phyolim/outerloop/releases/download/v#{version}/Outerloop-#{version}.zip"
  name "Outerloop"
  desc "Menu-bar control app for the outerloop agent fleet"
  homepage "https://github.com/phyolim/outerloop"

  depends_on formula: "phyolim/tap/outerloop"
  depends_on macos: :monterey

  app "Outerloop.app"

  # Never touch ~/Library/Application Support/outerloop — that's the live state
  # store owned by the CLI/daemon (DB, tokens), shared with the formula.
  zap trash: [
    "~/Library/Caches/com.outerloop.menubar",
    "~/Library/Preferences/com.outerloop.menubar.plist",
  ]

  caveats <<~EOS
    The app controls the daemon installed by the outerloop formula:
      brew services start outerloop   (role from `outerloop local role hub|worker`)
    State stays in ~/Library/Application Support/outerloop and is NOT removed on
    uninstall or zap.
  EOS
end
