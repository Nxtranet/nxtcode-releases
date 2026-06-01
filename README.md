# NxtCode for Mac

> Signed, notarized macOS .pkg releases of the NxtCode wrapper. Source is closed-beta; this repo exists so the install URL is stable and auditable.

## What is NxtCode?

NxtCode mirrors your terminal-based AI coding sessions (Claude Code, Codex CLI, Grok CLI) from your Mac to your iPhone in real time. When the agent pauses for input, your phone pings — tap to respond, keep it moving from anywhere. Full overview: <https://mobilecoder.app/nxtcode>.

## Install

One-line install:

```bash
curl -fsSL https://mobilecoder.app/nxtcode/install.sh | bash
```

Or download the .pkg directly:

<https://github.com/nxtranet/nxtcode-releases/releases/latest/download/NxtCode.pkg>

After install, in any terminal:

```bash
nxtcode claude     # or: nxtcode codex / nxtcode grok
```

Open the **NxtCode** app on iPhone → **Pair with your Mac** → scan the QR.

## Verify the binary

The .pkg is signed with our Developer ID Installer certificate and notarized by Apple. To verify before installing:

```bash
spctl --assess --type install -vv NxtCode.pkg
# expected: NxtCode.pkg: accepted
#           source=Notarized Developer ID

pkgutil --check-signature NxtCode.pkg | head
# expected: Developer ID Installer: Nxtranet (R6YB6F978N)
```

## System requirements

- macOS 12 (Monterey) or newer
- Apple Silicon (M1+) or Intel — the .pkg ships a universal binary
- ~60 MB disk

## Uninstall

```bash
sudo rm /usr/local/bin/nxtcode
rm -rf ~/.config/nxtcode
```

## Issues

Bug reports and feature requests: <https://github.com/nxtranet/nxtcode-releases/issues>.

## License

The .pkg binaries are proprietary — All Rights Reserved. The installer script (`install.sh`) and the CI workflow (`.github/workflows/release.yml`) are MIT licensed. See [LICENSE](./LICENSE).
