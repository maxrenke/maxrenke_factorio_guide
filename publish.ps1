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
#   pwsh -File publish.ps1 -Update -FromGit                     # changelog from git commits since last release
#   pwsh -File publish.ps1 -Update -Change "Fixed X","Added Y"  # OVERRIDE: use these entries verbatim, no prompt
#
# Changelog source priority in -Update mode:
#   1. -Change   -> used verbatim, no prompting (the non-interactive override; use this
#                   when Claude/CI runs the script).
#   2. -FromGit  -> generated from commit subjects touching mod/ since the last git tag.
#   3. neither   -> interactive prompt; type entries, or 'G' to pull from git.
#
# The mod portal is web-only for uploads; this script cannot push for you. It builds
# the zip and tells you exactly what to click.

param(
    [switch]$Update,
    [string]$NewVersion,
    [ValidateSet('major','minor','patch')][string]$Bump = 'patch',
    [string[]]$Change,
    [switch]$FromGit,
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

function Get-GitChangelog {
    # Commit subjects touching mod/ since the last git tag (else full history).
    Push-Location $root
    try {
        $lastTag = git describe --tags --abbrev=0 2>$null
        $hasTag  = ($LASTEXITCODE -eq 0 -and $lastTag)
        $logArgs = @('log', '--no-merges', '--pretty=format:%s')
        if ($hasTag) { $logArgs += "$lastTag..HEAD" }
        $logArgs += @('--', 'mod')
        $subjects = & git @logArgs 2>$null
    } finally { Pop-Location }
    if (-not $subjects) { return @() }
    $seen = @{}; $out = @()
    foreach ($s in $subjects) {
        $t = ($s -replace '\s+', ' ').Trim()
        if ($t -and -not $seen.ContainsKey($t)) { $seen[$t] = $true; $out += $t }
    }
    return $out
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

    if ($Change -and $Change.Count -gt 0) {
        # Override: use the supplied entries verbatim, no prompting (Claude/CI path).
        Write-Host "Using supplied changelog entries (-Change)." -ForegroundColor Cyan
    }
    elseif ($FromGit) {
        $Change = Get-GitChangelog
        Write-Host "Changelog generated from git commits since last release:" -ForegroundColor Cyan
        $Change | ForEach-Object { Write-Host "    - $_" }
    }
    else {
        Write-Host "Changelog for $new. Type entries one per line, or 'G' to generate from git. Blank line finishes:" -ForegroundColor Cyan
        $collected = @()
        while ($true) {
            $line = Read-Host "  -"
            if ([string]::IsNullOrWhiteSpace($line)) { break }
            if ($line.Trim() -eq 'G') { $collected = Get-GitChangelog; break }
            $collected += $line.Trim()
        }
        $Change = if ($collected.Count -gt 0) { $collected } else { Get-GitChangelog }
    }
    if (-not $Change -or $Change.Count -eq 0) { $Change = @("Maintenance update.") }

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

  Commit the version + changelog bump to git when you are happy, and tag the
  release so the next -FromGit run knows where to start:
     git add mod/info.json mod/changelog.txt
     git commit -m "release: v$version"
     git tag v$version
     git push --follow-tags
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
