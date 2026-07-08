cask "outerloop-app" do
  version "0.3.0"
  sha256 "0e41a542a438eff73c44ec1973717e805fa4b7e7fbc3d18a8ff889dbdb978499"

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
    On first launch the app asks whether this Mac is the Hub or a Worker.
    Picking Hub finishes setup by itself: it sets a dashboard password (shown
    once + copied to the clipboard) and starts the daemon — a real LAN hub with
    auth on. Forgot the password? `outerloop status` shows it.
    State stays in ~/Library/Application Support/outerloop and is NOT removed on
    uninstall or zap.
  EOS
end
