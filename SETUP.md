# Setup & Release Runbook

## 0. Create the public repo (one-time)

```bash
gh repo create nxtranet/nxtcode-releases --public \
  --description "Signed macOS .pkg releases of NxtCode" \
  --homepage "https://mobilecoder.app/nxtcode"

# Push this scaffold:
cd /Users/nxt3/dev/myRemoteAI/nxtcode-releases-scaffold
git init
git branch -M main
git add .
git commit -m "Initial scaffold"
git remote add origin git@github.com:nxtranet/nxtcode-releases.git
git push -u origin main
```

## 1. One-time GitHub secrets

For each secret below, run the `gh secret set` command shown. Always pass `--repo nxtranet/nxtcode-releases`.

### SOURCE_REPO_PAT

Fine-grained PAT with **Contents: Read-only** on `fkerkinni1/claude-pac`. The release workflow uses it to clone the private source.

1. Open https://github.com/settings/personal-access-tokens/new
2. Token name: `nxtcode-releases-ci`
3. Resource owner: `fkerkinni1` (your personal account — the source repo lives there, not in the Nxtranet org)
4. Repository access: Only select repositories → `fkerkinni1/claude-pac`
5. Permissions → Repository: Contents → Read-only
6. Expiration: 1 year, set a calendar reminder
7. Generate → copy token (one-shot view)
8. `gh secret set SOURCE_REPO_PAT --repo nxtranet/nxtcode-releases` → paste

### DEVELOPER_ID_APPLICATION_P12

Base64 of the exported **Developer ID Application** .p12.
This cert codesigns the `.app` bundle inside the .pkg via `xcodebuild`. Without
it the build fails immediately at the first codesign step.

```bash
# In Keychain Access on the dev Mac:
#   1. Find "Developer ID Application: Nxtranet (R6YB6F978N)"
#   2. Right-click → Export → Save As: application.p12 → set a strong password
# Then:
base64 -i ~/Desktop/application.p12 | pbcopy
gh secret set DEVELOPER_ID_APPLICATION_P12 --repo nxtranet/nxtcode-releases --body "$(pbpaste)"
rm -f ~/Desktop/application.p12  # don't leave it lying around
```

### DEVELOPER_ID_APPLICATION_PASSWORD

The password you set during the Application .p12 export.

```bash
gh secret set DEVELOPER_ID_APPLICATION_PASSWORD --repo nxtranet/nxtcode-releases
```

### DEVELOPER_ID_INSTALLER_P12

Base64 of the exported **Developer ID Installer** .p12.
This cert signs the outer .pkg via `productsign`. Separate cert from the
Application one above — Apple issues these as two distinct identities.

```bash
# In Keychain Access on the dev Mac:
#   1. Find "Developer ID Installer: Nxtranet (R6YB6F978N)"
#   2. Right-click → Export → Save As: installer.p12 → set a strong password
# Then:
base64 -i ~/Desktop/installer.p12 | pbcopy
gh secret set DEVELOPER_ID_INSTALLER_P12 --repo nxtranet/nxtcode-releases --body "$(pbpaste)"
rm -f ~/Desktop/installer.p12  # don't leave it lying around
```

### DEVELOPER_ID_INSTALLER_PASSWORD

The password you set during the Installer .p12 export.

```bash
gh secret set DEVELOPER_ID_INSTALLER_PASSWORD --repo nxtranet/nxtcode-releases
```

### APPLE_ID_EMAIL

The Apple Developer account email — **fuat@nxtranet.com** (NOT the gmail).

```bash
echo -n "fuat@nxtranet.com" | gh secret set APPLE_ID_EMAIL --repo nxtranet/nxtcode-releases
```

### APPLE_APP_PASSWORD

App-specific password for notarytool. NOT the account password.

```bash
# Generate at: https://appleid.apple.com → Sign-In and Security → App-Specific Passwords
# Label suggestion: "nxtcode-releases-notarytool"
gh secret set APPLE_APP_PASSWORD --repo nxtranet/nxtcode-releases
```

### APPLE_TEAM_ID

Nxtranet team ID, public-ish.

```bash
echo -n "R6YB6F978N" | gh secret set APPLE_TEAM_ID --repo nxtranet/nxtcode-releases
```

## 2. Cutting a release

**Recommended — manual dispatch (no source-repo tag needed):**

```bash
gh workflow run release.yml \
  --repo nxtranet/nxtcode-releases \
  -f version=v0.1.58
```

Watch progress:
```bash
gh run watch --repo nxtranet/nxtcode-releases
```

**Alternative — tag this repo:**

```bash
git tag v0.1.58 && git push origin v0.1.58
```

## 3. Verifying the release

After the action completes (~5-8 min on macos-14):

```bash
# URL resolves (302 → 200, ~55 MB):
curl -fIL https://github.com/nxtranet/nxtcode-releases/releases/latest/download/NxtCode.pkg

# Download + verify signature:
curl -fL -o /tmp/NxtCode.pkg \
  https://github.com/nxtranet/nxtcode-releases/releases/latest/download/NxtCode.pkg

spctl --assess --type install -vv /tmp/NxtCode.pkg
# expected: "accepted, source=Notarized Developer ID"

# End-to-end on a clean Mac VM (or your spare Intel Mac):
bash <(curl -fsSL https://mobilecoder.app/nxtcode/install.sh)
```

## 4. Rotating credentials

| Secret | Expiry | How to rotate |
|---|---|---|
| DEVELOPER_ID_INSTALLER_P12 | 5 years | Re-export from Keychain → re-base64 → `gh secret set` |
| APPLE_APP_PASSWORD | When revoked | Generate new at appleid.apple.com → `gh secret set` |
| SOURCE_REPO_PAT | 1 year | Regenerate at github.com/settings/personal-access-tokens |
| APPLE_ID_EMAIL / APPLE_TEAM_ID | n/a | Static, only change if Apple account moves |

## 5. Troubleshooting

- **"notarization failed"** → `xcrun notarytool log <submission-id> --keychain-profile notarytool-claudepac` from a workflow shell step, or download the log artifact.
- **"no signing identity found"** → the .p12 import step failed. Check that base64 didn't get newline-wrapped on paste — pbcopy should produce a single long string.
- **"gh release already exists"** → the workflow uses `--clobber` for re-runs, but a tag re-run with different content rewrites assets. Delete first if you need a clean state: `gh release delete v0.1.58 --yes`.
- **Source repo PAT 401** → expired or scoped wrong. Regenerate with **Contents: Read** on `fkerkinni1/claude-pac` only.
