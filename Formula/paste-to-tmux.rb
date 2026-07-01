class PasteToTmux < Formula
  desc "Drop a clipboard image or dragged file into a remote tmux pane over SSH"
  homepage "https://github.com/kentaccn/paste-to-tmux"
  url "https://github.com/kentaccn/paste-to-tmux/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "REPLACE_WITH_SHA256_AFTER_PUSHING_THE_v0.1.0_TAG"
  license "MIT"
  head "https://github.com/kentaccn/paste-to-tmux.git", branch: "main"

  def install
    bin.install "paste-to-tmux"
  end

  def caveats
    <<~EOS
      paste-to-tmux drives ssh + scp + tmux on the REMOTE host:
        - the remote host needs tmux installed, with a session running
        - passwordless SSH (keys) is recommended so transfers don't prompt

      For clipboard-image paste on macOS, also install pngpaste:
        brew install pngpaste

      To make a one-word shortcut for a host you use often, drop a small
      wrapper in your PATH that runs:  paste-to-tmux <your-host>
    EOS
  end

  test do
    output = shell_output("#{bin}/paste-to-tmux 2>&1", 2)
    assert_match "paste-to-tmux setup", output
  end
end
