class Outerloop < Formula
  desc "Single-user agent inbox: triage, prioritize, and gate agent-driven work"
  homepage "https://github.com/phyolim/outerloop"
  url "https://github.com/phyolim/outerloop/releases/download/v0.1.11/outerloop-full-0.1.11.tar.gz"
  sha256 "ac111ec0998c387109c4fc329086ace0b84ed24794464a75c9356619ef1b709f"
  license "MIT"

  depends_on "python@3.13"

  def install
    # config.py resolves schema.sql/prompts/ui relative to the package's parent,
    # so installing the tree into libexec untouched Just Works.
    libexec.install "outerloop", "schema.sql", "prompts", "ui"
    (bin/"outerloop").write <<~SH
      #!/bin/bash
      export PYTHONPATH="#{libexec}${PYTHONPATH:+:$PYTHONPATH}"
      export OUTERLOOP_HOME="${OUTERLOOP_HOME:-$HOME/Library/Application Support/outerloop}"
      exec "#{formula_opt_bin("python@3.13")}/python3.13" -m outerloop "$@"
    SH
  end

  service do
    run [opt_bin/"outerloop", "service"]
    keep_alive true
    log_path var/"log/outerloop.log"
    error_log_path var/"log/outerloop.log"
  end

  def caveats
    <<~EOS
      State lives in ~/Library/Application Support/outerloop (override with OUTERLOOP_HOME).
      This is the same dir the menu-bar app uses, so the two share one store.

      Pick this box's role, then start the daemon:
        outerloop local role hub|worker     (or the menu-bar app asks on first launch)
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
