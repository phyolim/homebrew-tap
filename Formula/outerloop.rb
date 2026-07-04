class Outerloop < Formula
  desc "Single-user agent inbox: triage, prioritize, and gate agent-driven work"
  homepage "https://github.com/phyolim/outerloop"
  url "https://github.com/phyolim/outerloop/archive/refs/tags/v0.1.2.tar.gz"
  sha256 "720a389b33a307b46e8b66a0eba1c1687e66f363ec789f0e089dc0377be11176"
  license "MIT"

  depends_on "python@3.13"

  def install
    # config.py resolves schema.sql/prompts/ui relative to the package's parent,
    # so installing the tree into libexec untouched Just Works.
    libexec.install "inbox", "schema.sql", "prompts"
    (bin/"outerloop").write <<~SH
      #!/bin/bash
      export PYTHONPATH="#{libexec}${PYTHONPATH:+:$PYTHONPATH}"
      export INBOX_HOME="${INBOX_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/outerloop}"
      exec "#{formula_opt_bin("python@3.13")}/python3" -m inbox "$@"
    SH
  end

  service do
    run [opt_bin/"outerloop", "coordinator"]
    keep_alive true
    log_path var/"log/outerloop.log"
    error_log_path var/"log/outerloop.log"
  end

  def caveats
    <<~EOS
      State lives in ~/.local/share/outerloop (override with INBOX_HOME).
      FAKE mode is the default (no external deps). For real mode (INBOX_FAKE=0),
      this machine also needs: claude (logged in), gh (authed), git (identity set).

      Start the hub:   brew services start outerloop
      Quickstart:      outerloop init && outerloop serve   # UI at :8765

      Do NOT also run the .pkg installer on this machine — two hubs/workers would
      double-claim against the same GitHub repos in real mode.
    EOS
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/outerloop version").strip
    ENV["INBOX_HOME"] = testpath/"data"
    ENV["INBOX_FAKE"] = "1"
    system bin/"outerloop", "init"
    assert_path_exists testpath/"data/inbox.db"
  end
end
