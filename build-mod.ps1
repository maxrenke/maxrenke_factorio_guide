# Builds the Factorio mod zip for upload to the mod portal.
#
#   pwsh -File build-mod.ps1
#
# Produces  dist\<name>_<version>.zip  with the structure the portal requires:
# a single top-level folder named <name>_<version> containing info.json at its root.

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$modDir = Join-Path $root "mod"

$info = Get-Content (Join-Path $modDir "info.json") -Raw | ConvertFrom-Json
$name = $info.name
$version = $info.version
if (-not $name -or -not $version) { throw "info.json missing name or version" }

$folder = "${name}_${version}"
$dist = Join-Path $root "dist"
$stage = Join-Path $dist $folder
$zip = Join-Path $dist "$folder.zip"

# Clean stage
if (Test-Path $stage) { Remove-Item -Recurse -Force $stage }
if (Test-Path $zip) { Remove-Item -Force $zip }
New-Item -ItemType Directory -Force -Path $stage | Out-Null

# Files that belong in the mod zip (NOT the HTML guide or server)
$include = @(
    "control.lua", "gui.lua", "phases.lua", "sync.lua",
    "info.json", "changelog.txt", "thumbnail.png"
)
foreach ($f in $include) {
    $src = Join-Path $modDir $f
    if (-not (Test-Path $src)) { throw "Missing required mod file: $f" }
    Copy-Item $src (Join-Path $stage $f)
}
# License from repo root
Copy-Item (Join-Path $root "LICENSE") (Join-Path $stage "LICENSE")

# Zip the folder (so the archive contains  <folder>/info.json )
Compress-Archive -Path $stage -DestinationPath $zip -Force

# Validate: the zip must contain exactly one top folder == $folder, with info.json inside
Add-Type -AssemblyName System.IO.Compression.FileSystem
$archive = [System.IO.Compression.ZipFile]::OpenRead($zip)
$entries = $archive.Entries | ForEach-Object { $_.FullName }
$archive.Dispose()
if (-not ($entries -contains "$folder/info.json")) {
    throw "Zip structure invalid: '$folder/info.json' not found. Entries: $($entries -join ', ')"
}

Write-Host "Built $zip"
Write-Host "Top folder: $folder  (info.json verified at root)"
Write-Host "Upload this .zip at https://mods.factorio.com/  -> your mod -> Upload"
