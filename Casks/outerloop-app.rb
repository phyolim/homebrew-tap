cask "outerloop-app" do
  version "0.3.7"
  sha256 "de2ab129baa372a3c28bcc41ae314950e2d3b6c3a12c389886058426fb155bb1"

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
