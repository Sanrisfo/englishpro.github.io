param(
  [switch] $Coverage = $false,
  [switch] $Docs = $false
)

$ErrorActionPreference = 'Stop'

function Ensure-Tool($name) {
  if (-not (Get-Command $name -ErrorAction SilentlyContinue)) {
    Write-Error "Required tool '$name' not found in PATH."
  }
}

try {
  Ensure-Tool flutter

  $repoRoot = Split-Path -Parent $PSScriptRoot
  $appDir = Join-Path $repoRoot 'app'

  Push-Location $appDir
  Write-Host 'Resolving dependencies...' -ForegroundColor Cyan
  flutter pub get

  Write-Host 'Running tests...' -ForegroundColor Cyan
  if ($Coverage) {
    flutter test --coverage -r expanded
    Write-Host "Coverage file: $(Join-Path $appDir 'coverage/lcov.info')"
  } else {
    flutter test -r expanded
  }

  if ($Docs) {
    Write-Host 'Generating API docs (dartdoc)...' -ForegroundColor Cyan
    # Prefer `dart doc`, fallback to `flutter pub run dartdoc`
    if (Get-Command dart -ErrorAction SilentlyContinue) {
      dart doc
    } else {
      flutter pub run dartdoc
    }
    Write-Host "Docs generated at: $(Join-Path $appDir 'doc/api/index.html')"
  }
}
finally {
  Pop-Location
}

