# Validates every trigger prototype name in mod/phases.lua against the installed
# Factorio base data. A typo or a name that only exists in Space Age produces a
# task that can never auto-complete, which is silent at runtime - so this is a
# hard gate in build-mod.ps1.
#
#   pwsh -File validate-phases.ps1
#   pwsh -File validate-phases.ps1 -DataPath "D:\Factorio\data\base"

param(
    [string]$DataPath
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$phasesFile = Join-Path $root "mod\phases.lua"

if (-not $DataPath) {
    $candidates = @(
        "C:\Program Files (x86)\Steam\steamapps\common\Factorio\data\base",
        "C:\Program Files\Steam\steamapps\common\Factorio\data\base",
        "$env:ProgramFiles\Factorio\data\base"
    )
    $DataPath = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
}
if (-not $DataPath -or -not (Test-Path $DataPath)) {
    Write-Warning "Factorio base data not found - skipping prototype validation. Pass -DataPath to enable."
    exit 0
}

# Space Age data, if installed, is NOT a valid source: this mod targets the
# vanilla base game, so a name that only resolves under Space Age is a bug.
$blob = [System.Text.StringBuilder]::new()
Get-ChildItem -Path $DataPath -Filter *.lua -Recurse | ForEach-Object {
    [void]$blob.Append((Get-Content $_.FullName -Raw))
}
$data = $blob.ToString()

$src = Get-Content $phasesFile -Raw

# One task per line in phases.lua, so scan line-wise to keep the match anchored
# to a single task entry.
$triggers = @()
foreach ($line in ($src -split "`r?`n")) {
    $m = [regex]::Match($line, 'id\s*=\s*"(?<task>[\w]+)".*?type\s*=\s*"(?<type>\w+)",\s*name\s*=\s*"(?<name>[\w-]+)"')
    if ($m.Success) {
        $triggers += [pscustomobject]@{
            Task = $m.Groups['task'].Value
            Type = $m.Groups['type'].Value
            Name = $m.Groups['name'].Value
        }
    }
}

if ($triggers.Count -eq 0) { throw "No triggers parsed from $phasesFile - the parser or the file format changed." }

$bad = @()
foreach ($t in $triggers) {
    if ($data -notmatch ('name\s*=\s*"' + [regex]::Escape($t.Name) + '"')) {
        $bad += $t
    }
}

# Every task must either carry a name trigger we validated, or be one of the
# nameless trigger types (currently only "rocket"). Anything else means the
# line-wise parser silently skipped a task.
$taskCount = ([regex]::Matches($src, 'id\s*=\s*"p\d+_\w+"')).Count
$nameless = ([regex]::Matches($src, 'trigger\s*=\s*\{\s*type\s*=\s*"\w+"\s*\}')).Count
if ($triggers.Count + $nameless -ne $taskCount) {
    throw "Parsed $($triggers.Count) name triggers + $nameless nameless, but found $taskCount tasks - the parser missed something."
}

Write-Host "Validated $($triggers.Count) triggers ($taskCount tasks, $nameless nameless) against $DataPath"
if ($bad.Count -gt 0) {
    foreach ($b in $bad) {
        Write-Host ("  BAD  {0,-20} {1,-9} {2}" -f $b.Task, $b.Type, $b.Name) -ForegroundColor Red
    }
    throw "$($bad.Count) trigger name(s) do not exist in the vanilla base data."
}
Write-Host "All trigger prototype names exist in the vanilla base data." -ForegroundColor Green
