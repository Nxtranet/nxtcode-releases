# NxtCode for Mac & Windows

> Signed, notarized macOS .pkg releases and the Windows zip of the NxtCode wrapper. Source is closed; this repo exists so the install URLs are stable and auditable.

## What is NxtCode?

NxtCode mirrors your terminal-based AI coding sessions (Claude Code, Codex CLI, Grok CLI) from your Mac or Windows PC to your iPhone in real time. When the agent pauses for input, your phone pings — tap to respond, keep it moving from anywhere. Full overview: <https://mobilecoder.app/nxtcode>.

## Install (macOS)

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

Open the **NxtCode** app on iPhone → **Pair** → scan the QR.

## Install (Windows)

One-line install, in PowerShell or Windows Terminal (no admin rights needed):

```powershell
irm https://mobilecoder.app/nxtcode/install.ps1 | iex
```

Or download the zip directly, extract it, and run `powershell -ExecutionPolicy Bypass -File .\install.ps1`:

<https://github.com/nxtranet/nxtcode-releases/releases/latest/download/NxtCode-Windows.zip>

Then, in two terminals:

```powershell
nxtcode-mirror     # terminal 1: relay + tunnel, leave running
nxtcode claude     # terminal 2: prints the QR — scan it with the iPhone app
```

Windows 10 (1809+) / 11, x64 or ARM64. Needs Node.js 20+ (the installer offers to install it via winget) and Claude Code (`npm install -g @anthropic-ai/claude-code`). The zip is not code-signed; verify its SHA-256 against `NxtCode-Windows.zip.sha256` on the release page.

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

macOS:

```bash
sudo rm /usr/local/bin/nxtcode
rm -rf ~/.config/nxtcode
```

Windows:

```powershell
powershell -ExecutionPolicy Bypass -File "$env:LOCALAPPDATA\Programs\NxtCode\uninstall.ps1"
```

## Issues

Bug reports and feature requests: <https://github.com/nxtranet/nxtcode-releases/issues>.

## License

The .pkg and zip binaries are proprietary — All Rights Reserved. The installer scripts (`install.sh`, `install.ps1`) and the CI workflow (`.github/workflows/release.yml`) are MIT licensed. See [LICENSE](./LICENSE).
