# =============================================================================
# NxtCode for Windows — one-line installer
# =============================================================================
#
#   irm https://mobilecoder.app/nxtcode/install.ps1 | iex
#
# Downloads the latest NxtCode-Windows.zip from the public releases repo,
# extracts it to a temp folder, and runs the install.ps1 inside it, which:
#   - checks for Node.js 20+ (installs OpenJS.NodeJS.LTS via winget if missing)
#   - copies the wrapper to %LOCALAPPDATA%\Programs\NxtCode
#   - adds that folder to your user PATH (no admin rights needed)
#   - installs cloudflared via winget if missing (tunnel so your iPhone can reach this PC)
#
# Nothing is written outside your user profile. Uninstall:
#   powershell -ExecutionPolicy Bypass -File "$env:LOCALAPPDATA\Programs\NxtCode\uninstall.ps1"
#
# Source: https://github.com/nxtranet/nxtcode-releases
# Keep this file short and auditable — constants live in the block below.
# =============================================================================

$ErrorActionPreference = 'Stop'
$ZipUrl = 'https://github.com/nxtranet/nxtcode-releases/releases/latest/download/NxtCode-Windows.zip'
$Brand  = 'NxtCode'

if ($PSVersionTable.PSVersion.Major -lt 5) {
  throw "$Brand needs Windows PowerShell 5.1 or newer."
}
if (-not ($env:OS -eq 'Windows_NT')) {
  throw "$Brand for Windows can only be installed on Windows. On macOS use: curl -fsSL https://mobilecoder.app/nxtcode/install.sh | bash"
}

Write-Host "Installing $Brand for Windows..." -ForegroundColor Green
Write-Host "Source: https://github.com/nxtranet/nxtcode-releases"

$tmp = Join-Path ([IO.Path]::GetTempPath()) ("nxtcode-install-" + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tmp | Out-Null
try {
  $zip = Join-Path $tmp 'NxtCode-Windows.zip'
  Write-Host "Downloading latest release..."
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  Invoke-WebRequest -Uri $ZipUrl -OutFile $zip -UseBasicParsing
  Write-Host ("Downloaded {0:N1} MB" -f ((Get-Item $zip).Length / 1MB))

  Expand-Archive -Path $zip -DestinationPath $tmp -Force
  $inner = Get-ChildItem -Path $tmp -Recurse -Filter 'install.ps1' | Select-Object -First 1
  if (-not $inner) { throw "install.ps1 not found inside the downloaded zip." }

  & $inner.FullName
}
finally {
  Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
}
