# homebrew-jstack

A Homebrew tap that installs the **jstack** developer setup on macOS:

- [**jcode**](https://github.com/1jehuang/jcode) - proactive terminal coding agent
- [**ScrollWM**](https://github.com/1jehuang/scrollwm) - scrolling, PaperWM-style window manager

## Install everything (recommended)

```sh
brew tap 1jehuang/jstack
brew install --cask jstack
```

This installs the `jcode` CLI **and** the ScrollWM app in one shot.

## Install pieces individually

```sh
brew install --cask jcode      # just the jcode CLI
brew install --cask scrollwm   # just the ScrollWM window manager
```

## After installing

- `jcode` - run it in any terminal to get started.
- **ScrollWM** - launch it from `/Applications` (or run `scrollwm`). Grant it
  Accessibility permission when prompted so it can manage windows.

## Notes

- macOS Sonoma (14) or newer is required for ScrollWM.
- Both binaries are ad-hoc signed (not notarized). The casks strip the
  `com.apple.quarantine` attribute on install so macOS Gatekeeper lets them run.
- `jstack` and `jcode` both provide the `jcode` binary, so they conflict with
  each other - pick `jstack` for the bundle or `jcode` for just the CLI.

## Updating

```sh
brew update
brew upgrade --cask jstack   # or jcode / scrollwm
```
