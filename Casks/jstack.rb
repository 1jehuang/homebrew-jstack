cask "jstack" do
  arch arm: "aarch64", intel: "x86_64"

  version "0.34.0"
  sha256 arm:   "bfddb4810d76928c568ea3bc461c877204ae0419cf9d2c7b5fd28072ceedec66",
         intel: "52db1dcd1e79f88db3dca48f0bb744f0700a6078c97daf4b7905283685a6e2e4"

  url "https://github.com/1jehuang/jcode/releases/download/v#{version}/jcode-macos-#{arch}.tar.gz"
  name "jstack"
  name "jcode + ScrollWM"
  desc "Bundle of the jcode terminal coding agent and ScrollWM window manager"
  homepage "https://github.com/1jehuang/homebrew-jstack"

  livecheck do
    url "https://github.com/1jehuang/jcode"
    strategy :github_latest
  end

  conflicts_with cask: "1jehuang/jstack/jcode"
  depends_on cask: "1jehuang/jstack/scrollwm"
  # ScrollWM requires Sonoma, and the Intel jcode binary targets macOS 14.
  depends_on macos: :sonoma

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
