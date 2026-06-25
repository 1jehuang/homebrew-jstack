cask "jstack" do
  arch arm: "aarch64", intel: "x86_64"

  version "0.31.2"
  sha256 arm:   "504915b45449fb5d32b5a9a8b732e958edc17ed1811f20770c9d1b12fce4d02b",
         intel: "4f01552931b650635ec69d6e791ca5efb26bb13eeb2b784bb33b938dc8987594"

  url "https://github.com/1jehuang/jcode/releases/download/v#{version}/jcode-macos-#{arch}.tar.gz"
  name "jstack"
  name "jcode + ScrollWM"
  desc "Bundle of the jcode terminal coding agent and ScrollWM window manager"
  homepage "https://github.com/1jehuang/jstack"

  conflicts_with cask: "1jehuang/jstack/jcode"
  depends_on cask: "1jehuang/jstack/scrollwm"

  binary "jcode-macos-#{arch}", target: "jcode"

  # The jcode binary is ad-hoc signed (not notarized); macOS sends SIGKILL to a
  # quarantined ad-hoc binary, so strip quarantine after staging.
  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{staged_path}/jcode-macos-#{arch}"],
                   sudo: false
  end

  caveats <<~CAVEATS
    Installed the jstack bundle:
      - jcode    -> run `jcode` in any terminal
      - ScrollWM -> launch from /Applications (grant Accessibility permission)
  CAVEATS
end
