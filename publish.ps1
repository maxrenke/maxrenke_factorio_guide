# Publish helper for the Vanilla Progress Guide mod.
#
# First publish (build + step-by-step checklist):
#   pwsh -File publish.ps1
#   pwsh -File publish.ps1 -OpenPortal        # also open the portal in your browser
#
# After you have made code changes (bump version, add changelog, rebuild):
#   pwsh -File publish.ps1 -Update                              # bumps patch (1.0.0 -> 1.0.1)
#   pwsh -File publish.ps1 -Update -Bump minor                  # 1.0.0 -> 1.1.0
#   pwsh -File publish.ps1 -Update -NewVersion 2.0.0            # explicit version
#   pwsh -File publish.ps1 -Update -Change "Fixed X","Added Y"  # changelog entries (else prompts)
#
# The mod portal is web-only for uploads; this script cannot push for you. It builds
# the zip and tells you exactly what to click.

param(
    [switch]$Update,
    [string]$NewVersion,
    [ValidateSet('major','minor','patch')][string]$Bump = 'patch',
    [string[]]$Change,
    [switch]$OpenPortal,
    [switch]$NoBuild
)

$ErrorActionPreference = "Stop"
$root      = Split-Path -Parent $MyInvocation.MyCommand.Path
$infoPath  = Join-Path $root "mod\info.json"
$changelog = Join-Path $root "mod\changelog.txt"
$portalUrl = "https://mods.factorio.com/"
$uploadUrl = "https://mods.factorio.com/upload"

function Read-Info { Get-Content $infoPath -Raw | ConvertFrom-Json }

function Set-Version([string]$version) {
    # Regex-replace just the version line so the rest of info.json formatting is preserved.
    $raw = Get-Content $infoPath -Raw
    $raw = $raw -replace '("version"\s*:\s*")[^"]*(")', "`${1}$version`${2}"
    Set-Content -Path $infoPath -Value $raw -NoNewline -Encoding utf8
}

function Bump-Version([string]$current, [string]$kind) {
    if ($current -notmatch '^\d+\.\d+\.\d+$') { throw "Version '$current' is not x.y.z; use -NewVersion." }
    $p = $current.Split('.') | ForEach-Object { [int]$_ }
    switch ($kind) {
        'major' { $p[0]++; $p[1] = 0; $p[2] = 0 }
        'minor' { $p[1]++; $p[2] = 0 }
        'patch' { $p[2]++ }
    }
    "$($p[0]).$($p[1]).$($p[2])"
}

function Prepend-Changelog([string]$version, [string[]]$entries) {
    $sep   = '-' * 99
    $date  = Get-Date -Format 'yyyy-MM-dd'
    $lines = @($sep, "Version: $version", "Date: $date", "  Changes:")
    foreach ($e in $entries) { $lines += "    - $e" }
    $block = ($lines -join "`n") + "`n"
    $existing = if (Test-Path $changelog) { Get-Content $changelog -Raw } else { "" }
    Set-Content -Path $changelog -Value ($block + $existing) -Encoding utf8
}

# ---- Update mode: bump version + changelog before building -------------------
if ($Update) {
    $info = Read-Info
    $old  = $info.version
    $new  = if ($NewVersion) { $NewVersion } else { Bump-Version $old $Bump }

    if (-not $Change -or $Change.Count -eq 0) {
        Write-Host "Enter changelog entries for $new (one per line, blank line to finish):" -ForegroundColor Cyan
        $Change = @()
        while ($true) {
            $line = Read-Host "  -"
            if ([string]::IsNullOrWhiteSpace($line)) { break }
            $Change += $line.Trim()
        }
        if ($Change.Count -eq 0) { $Change = @("Maintenance update.") }
    }

    Set-Version $new
    Prepend-Changelog $new $Change
    Write-Host "Version $old -> $new, changelog updated." -ForegroundColor Green
}

# ---- Build -------------------------------------------------------------------
$info    = Read-Info
$name    = $info.name
$version = $info.version
$zip     = Join-Path $root "dist\${name}_${version}.zip"

if (-not $NoBuild) {
    Write-Host "Building $name $version ..." -ForegroundColor Cyan
    & pwsh -File (Join-Path $root "build-mod.ps1")
    if ($LASTEXITCODE -ne 0) { throw "build-mod.ps1 failed (exit $LASTEXITCODE)." }
}

if (-not (Test-Path $zip)) { throw "Expected zip not found: $zip" }
$zipFull = (Resolve-Path $zip).Path

# ---- Manual steps ------------------------------------------------------------
$bar = '=' * 70
Write-Host ""
Write-Host $bar -ForegroundColor DarkGray
Write-Host "  ZIP READY:  $zipFull" -ForegroundColor Green
Write-Host $bar -ForegroundColor DarkGray

if ($Update) {
    Write-Host @"

  PUBLISH AN UPDATE (mod already exists on the portal):

  1. Sign in at $portalUrl with your Factorio.com account
     (same login as the game launcher - NOT your GitHub account).
  2. Go to your mod page -> Edit -> Releases, or open:
       $uploadUrl
  3. Upload the new zip:
       $zipFull
     The portal reads the new version ($version) and the changelog block from
     inside the zip. It rejects a version that already exists, so the bump above
     is required.
  4. (Optional) Update the long description / images on the mod page if they changed.

  Commit the version + changelog bump to git when you are happy:
     git add mod/info.json mod/changelog.txt
     git commit -m "release: v$version"
     git push
"@ -ForegroundColor White
}
else {
    Write-Host @"

  FIRST-TIME PUBLISH:

  1. Sign in at $portalUrl with your Factorio.com account
     (same login as the game launcher - NOT your GitHub account).

  2. BEFORE committing to a name, verify it is free. Try opening:
       https://mods.factorio.com/mod/$name
     If that page 404s, the name is available. The internal name is PERMANENT
     and globally unique once published.

  3. Click "Upload a Mod" (top right) or open:
       $uploadUrl
     - Internal name MUST equal:  $name
     - License: choose MIT (matches the LICENSE in the repo).
     - Upload the zip:
         $zipFull

  4. The portal pulls title, description, thumbnail.png, and changelog.txt
     from INSIDE the zip - you do not retype them. Add screenshots / a longer
     description on the mod page if you want.

  5. Publish. Done.

  Later, when you change the mod, run:
       pwsh -File publish.ps1 -Update
"@ -ForegroundColor White
}

Write-Host $bar -ForegroundColor DarkGray

if ($OpenPortal) {
    Write-Host "Opening the portal in your browser..." -ForegroundColor Cyan
    Start-Process $(if ($Update) { $uploadUrl } else { $portalUrl })
}
