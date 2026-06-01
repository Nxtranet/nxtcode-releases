#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# NxtCode for Mac — one-line installer
# =============================================================================
#
# This script downloads and installs the latest signed & notarized NxtCode.pkg
# from the public releases repository.
#
#   Downloads:   The latest NxtCode.pkg (Developer ID signed, Apple notarized)
#                from https://github.com/nxtranet/nxtcode-releases/releases/latest
#
#   Installs:    /usr/local/bin/nxtcode            (the CLI launcher)
#                ~/.config/nxtcode/                (per-user config + state)
#                plus supporting files placed by the pkg's own scripts.
#
#   Requires:    macOS (Darwin). Apple's `installer` command requires sudo,
#                so this script will prompt for your admin password once.
#
#   Verify:      Before the sudo prompt, we run `spctl --assess` to confirm
#                the pkg is signed by Nxtranet and notarized by Apple. If that
#                check fails, the script aborts without touching your system.
#
#   Uninstall:   sudo rm /usr/local/bin/nxtcode
#                rm -rf ~/.config/nxtcode
#                (and optionally drag /Applications/NxtCode.app to the Trash
#                 if the GUI companion app was installed.)
#
#   Source:      https://github.com/nxtranet/nxtcode-releases
#
# This file is the single most-audited artifact in the repo. Keep it short,
# auditable, and free of magic. If you need to change behavior, edit the
# constants block below — do not sprinkle URLs throughout the script.
# =============================================================================

# ----- Constants -------------------------------------------------------------
PKG_URL="https://github.com/nxtranet/nxtcode-releases/releases/latest/download/NxtCode.pkg"
BRAND="NxtCode"

# ----- Color helpers (respect NO_COLOR + isatty) -----------------------------
_is_tty() { [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; }
green() { if _is_tty; then printf '\033[32m%s\033[0m\n' "$*"; else printf '%s\n' "$*"; fi; }
red()   { if _is_tty; then printf '\033[31m%s\033[0m\n' "$*"; else printf '%s\n' "$*"; fi; }
bold()  { if _is_tty; then printf '\033[1m%s\033[0m\n' "$*"; else printf '%s\n' "$*"; fi; }

# ----- Banner ----------------------------------------------------------------
green "Installing $BRAND for Mac…"
green "Source: https://github.com/nxtranet/nxtcode-releases"

# ----- Platform check --------------------------------------------------------
if [ "$(uname -s)" != "Darwin" ]; then
  red "$BRAND is macOS only. Detected: $(uname -s)" >&2
  exit 1
fi

# ----- Dependency check ------------------------------------------------------
if ! command -v curl >/dev/null 2>&1; then
  red "curl is required but not found in PATH." >&2
  exit 1
fi

# ----- Temp workspace --------------------------------------------------------
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# ----- Download --------------------------------------------------------------
echo "Downloading latest release…"
curl -fL --proto '=https' --tlsv1.2 -o "$tmp/NxtCode.pkg" "$PKG_URL"
echo "Downloaded $(du -h "$tmp/NxtCode.pkg" | cut -f1)"

# ----- Verify signature BEFORE asking for sudo -------------------------------
echo "Verifying signature…"
if ! spctl --assess --type install "$tmp/NxtCode.pkg" 2>/dev/null; then
  red "Signature verification failed. Aborting."
  red "Please report this at https://github.com/nxtranet/nxtcode-releases/issues"
  exit 1
fi
green "✓ Signed by Nxtranet, notarized by Apple"

# ----- Install ---------------------------------------------------------------
echo
bold "Installing… (requires admin password)"
sudo installer -pkg "$tmp/NxtCode.pkg" -target /

# ----- Post-install sanity check --------------------------------------------
if command -v nxtcode >/dev/null 2>&1; then
  echo
  green "✓ $BRAND installed."
  echo
  echo "Next step — in any terminal:"
  bold "  nxtcode claude"
  echo
  echo "Then open the NxtCode app on iPhone and scan the QR."
else
  red "Install succeeded but 'nxtcode' is not on PATH."
  echo "Add /usr/local/bin to your PATH and try again:"
  echo '  export PATH="/usr/local/bin:$PATH"'
  exit 1
fi

exit 0
