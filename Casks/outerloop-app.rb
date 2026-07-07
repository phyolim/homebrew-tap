cask "outerloop-app" do
  version "0.1.7"
  sha256 "8eb91333893cf2150a604cb28cdaf23cf95e780453598e6fc91974a37f7b9074"

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
