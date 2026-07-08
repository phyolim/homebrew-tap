class Outerloop < Formula
  desc "Single-user agent inbox: triage, prioritize, and gate agent-driven work"
  homepage "https://github.com/phyolim/outerloop"
  url "https://github.com/phyolim/outerloop/releases/download/v0.3.11/outerloop-full-0.3.11.tar.gz"
  sha256 "43a3bea84da1467593911274316cae4657507200840514ae99be5ea7fb07bf21"
  license "MIT"

  depends_on "gh" # real mode shells `gh` for clone/PR/merge; guarantee it's present
  depends_on "python@3.13"

  def install
    # config.py resolves schema.sql/prompts/ui relative to the package's parent,
    # so installing the tree into libexec untouched Just Works.
    libexec.install "outerloop", "schema.sql", "ui"
    (bin/"outerloop").write <<~SH
      #!/bin/bash
      export PYTHONPATH="#{libexec}${PYTHONPATH:+:$PYTHONPATH}"
      export OUTERLOOP_HOME="${OUTERLOOP_HOME:-$HOME/Library/Application Support/outerloop}"
      # -P: never prepend the CWD to sys.path — without it, running `outerloop`
      # from inside a repo checkout silently executes the checkout's package
      # instead of this install (python -m puts CWD ahead of PYTHONPATH).
      exec "#{formula_opt_bin("python@3.13")}/python3.13" -P -m outerloop "$@"
    SH
  end

  service do
    run [opt_bin/"outerloop", "service"]
    keep_alive true
    # launchd's default PATH is /usr/bin:/bin:/usr/sbin:/sbin — no /opt/homebrew/bin,
    # so a brew-installed gh (or anything else) is invisible to the service without
    # this. std_service_path_env prepends the brew prefix. (claude still needs the
    # app-side resolution: it self-installs to a per-user ~/.local/bin no formula
    # can know about.)
    environment_variables PATH: std_service_path_env
    log_path var/"log/outerloop.log"
    error_log_path var/"log/outerloop.log"
  end

  def post_install
    # brew upgrade never restarts a running service, and shelling out to
    # `brew services restart` from here deadlocks on brew's own lock — so kick
    # launchd directly. kickstart -k kills + restarts the loaded service (opt
    # symlink already points at the new keg by post_install time). quiet_system
    # swallows the failure when the service isn't loaded (e.g. first install).
    quiet_system "launchctl", "kickstart", "-k", "gui/#{Process.uid}/homebrew.mxcl.outerloop"
  end

  def caveats
    <<~EOS
      State lives in ~/Library/Application Support/outerloop (override with OUTERLOOP_HOME).
      This is the same dir the menu-bar app uses, so the two share one store.

      Pick this box's role, then start the daemon:
        outerloop local role hub|worker|both  (or the menu-bar app asks on first launch)
        brew services start outerloop

      A hub defaults to REAL mode, LAN bind (<hub>.local:8765), and auth on; it
      self-generates a dashboard password if you never set one — see it with
      `outerloop status`, change it with `outerloop config ui_token <secret>`.
      Real mode needs: claude (logged in), gh (authed), git (identity set) — check
      with `outerloop doctor`. An unconfigured box stays FAKE + loopback-only.

      Do NOT also run the .pkg installer on this machine — two hubs/workers would
      double-claim against the same GitHub repos in real mode.
    EOS
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/outerloop version").strip
    ENV["OUTERLOOP_HOME"] = testpath/"data"
    ENV["OUTERLOOP_FAKE"] = "1"
    system bin/"outerloop", "init"
    assert_path_exists testpath/"data/inbox.db"
  end
end
