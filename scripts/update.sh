#!/usr/bin/env bash
# Regenerate the jcode + jstack casks for the latest jcode release and the
# scrollwm cask for the latest scrollwm release, pulling real SHA256 sums from
# each project's published checksums file.
#
# Usage: scripts/update.sh [jcode_version] [scrollwm_version]
#   Versions default to each repo's latest GitHub release tag.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CASKS="$ROOT/Casks"

latest_tag() { curl -fsSL "https://api.github.com/repos/$1/releases/latest" | grep '"tag_name"' | cut -d'"' -f4; }

JCODE_TAG="${1:-$(latest_tag 1jehuang/jcode)}"
SCROLLWM_TAG="${2:-$(latest_tag 1jehuang/scrollwm)}"
JV="${JCODE_TAG#v}"
SV="${SCROLLWM_TAG#v}"

echo "jcode:    $JCODE_TAG"
echo "scrollwm: $SCROLLWM_TAG"

# --- jcode checksums ---
JSUMS="$(curl -fsSL "https://github.com/1jehuang/jcode/releases/download/$JCODE_TAG/SHA256SUMS")"
J_ARM="$(echo "$JSUMS"   | awk '/jcode-macos-aarch64\.tar\.gz/{print $1}')"
J_INTEL="$(echo "$JSUMS" | awk '/jcode-macos-x86_64\.tar\.gz/{print $1}')"
[ -n "$J_ARM" ] && [ -n "$J_INTEL" ] || { echo "missing jcode checksums" >&2; exit 1; }

# --- scrollwm checksum ---
SSUMS="$(curl -fsSL "https://github.com/1jehuang/scrollwm/releases/download/$SCROLLWM_TAG/SHA256SUMS.txt")"
S_ZIP="$(echo "$SSUMS" | awk '/ScrollWM-.*\.zip/{print $1}')"
[ -n "$S_ZIP" ] || { echo "missing scrollwm checksum" >&2; exit 1; }

postflight_jcode() {
cat <<EOF
  # The jcode binary is ad-hoc signed (not notarized); macOS sends SIGKILL to a
  # quarantined ad-hoc binary, so strip quarantine after staging.
  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{staged_path}/jcode-macos-#{arch}"],
                   sudo: false
  end
EOF
}

cat > "$CASKS/jcode.rb" <<EOF
cask "jcode" do
  arch arm: "aarch64", intel: "x86_64"

  version "$JV"
  sha256 arm:   "$J_ARM",
         intel: "$J_INTEL"

  url "https://github.com/1jehuang/jcode/releases/download/v#{version}/jcode-macos-#{arch}.tar.gz"
  name "jcode"
  desc "Proactive terminal coding agent"
  homepage "https://github.com/1jehuang/jcode"

  conflicts_with cask: "1jehuang/jstack/jstack"

  binary "jcode-macos-#{arch}", target: "jcode"

$(postflight_jcode)

  caveats <<~CAVEATS
    jcode has been installed as \`jcode\`. Run \`jcode\` to get started.
  CAVEATS
end
EOF

cat > "$CASKS/jstack.rb" <<EOF
cask "jstack" do
  arch arm: "aarch64", intel: "x86_64"

  version "$JV"
  sha256 arm:   "$J_ARM",
         intel: "$J_INTEL"

  url "https://github.com/1jehuang/jcode/releases/download/v#{version}/jcode-macos-#{arch}.tar.gz"
  name "jstack"
  name "jcode + ScrollWM"
  desc "Bundle of the jcode terminal coding agent and ScrollWM window manager"
  homepage "https://github.com/1jehuang/jstack"

  conflicts_with cask: "1jehuang/jstack/jcode"
  depends_on cask: "1jehuang/jstack/scrollwm"

  binary "jcode-macos-#{arch}", target: "jcode"

$(postflight_jcode)

  caveats <<~CAVEATS
    Installed the jstack bundle:
      - jcode    -> run \`jcode\` in any terminal
      - ScrollWM -> launch from /Applications (grant Accessibility permission)
  CAVEATS
end
EOF

cat > "$CASKS/scrollwm.rb" <<EOF
cask "scrollwm" do
  version "$SV"
  sha256 "$S_ZIP"

  url "https://github.com/1jehuang/scrollwm/releases/download/v#{version}/ScrollWM-#{version}.zip"
  name "ScrollWM"
  desc "Scrolling, PaperWM-style window manager"
  homepage "https://github.com/1jehuang/scrollwm"

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
EOF

echo "Updated Casks/{jcode,jstack,scrollwm}.rb"
