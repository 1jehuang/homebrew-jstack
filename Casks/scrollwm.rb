cask "scrollwm" do
  version "0.2.1"
  sha256 "6208cdcb4d6356c7620333ee8c048d85b1c39b07d9d639299f1ae972b5fdf2e4"

  url "https://github.com/1jehuang/scrollwm/releases/download/v#{version}/ScrollWM-#{version}.zip"
  name "ScrollWM"
  desc "Scrolling, PaperWM-style window manager"
  homepage "https://github.com/1jehuang/scrollwm"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: :sonoma

  app "ScrollWM.app"
  binary "#{appdir}/ScrollWM.app/Contents/MacOS/ScrollWM", target: "scrollwm"

  # The app is ad-hoc signed (not notarized); strip quarantine so it opens
  # without the Gatekeeper block.
  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{appdir}/ScrollWM.app"],
                   sudo: false
  end

  uninstall quit: "dev.scrollwm.app"

  zap trash: [
    "~/Library/Application Support/ScrollWM",
    "~/Library/Application Support/ScrollWM-Sandbox",
  ]
end
