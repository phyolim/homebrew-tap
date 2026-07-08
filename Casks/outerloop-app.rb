cask "outerloop-app" do
  version "0.3.14"
  sha256 "93b6a704517ff362c77f1a593b5fcf7e4c01a3b6ada07fa4fd4c6bdae31efcd9"

  url "https://github.com/phyolim/outerloop/releases/download/v#{version}/Outerloop-#{version}.zip"
  name "Outerloop"
  desc "Menu-bar control app for the outerloop agent fleet"
  homepage "https://github.com/phyolim/outerloop"

  # The app updates itself (same-team bundle swap needs no App Management TCC
  # grant, unlike brew moving it from a terminal) — brew upgrade skips it.
  auto_updates true

  depends_on formula: "phyolim/tap/outerloop"
  depends_on macos: :monterey

  app "Outerloop.app"

  # Relaunch the app once the new bundle is in place — brew itself never
  # launches GUI apps (the `uninstall quit:` below stops the old build first).
  # Also fires on first install, which is what we want: the app's first-launch
  # flow asks Hub/Worker and finishes setup.
  postflight do
    system_command "/usr/bin/open", args: ["#{appdir}/Outerloop.app"]
  end

  # Quit the running menu-bar app on upgrade/uninstall so the swap doesn't leave
  # the stale build running in memory. (Homebrew never auto-relaunches a GUI app;
  # Open-at-Login brings it back next login, or reopen it manually.)
  uninstall quit: "com.outerloop.menubar"

  # Never touch ~/Library/Application Support/outerloop — that's the live state
  # store owned by the CLI/daemon (DB, tokens), shared with the formula.
  zap trash: [
    "~/Library/Caches/com.outerloop.menubar",
    "~/Library/Preferences/com.outerloop.menubar.plist",
  ]

  caveats <<~EOS
    The app updates itself: the menu-bar popover's version footer shows an
    Update button when a new release is out, so `brew upgrade` skips this cask
    (auto_updates). If you ever upgrade it via brew anyway (`--greedy`), your
    terminal needs App Management permission (System Settings → Privacy &
    Security → App Management) or macOS blocks the swap with "Operation not
    permitted".

    On first launch the app asks whether this Mac is the Hub or a Worker.
    Picking Hub finishes setup by itself: it sets a dashboard password (shown
    once + copied to the clipboard) and starts the daemon — a real LAN hub with
    auth on. Forgot the password? `outerloop status` shows it.
    State stays in ~/Library/Application Support/outerloop and is NOT removed on
    uninstall or zap.
  EOS
end
