# Start the Factorio Guide local sync server.
# Usage: right-click -> Run with PowerShell, or:  pwsh -File start-server.ps1
param(
    [int]$Port = 8777,
    [string]$ScriptOutput = "",
    [switch]$NoBrowser
)

$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path

# Find a Python interpreter.
$python = $null
foreach ($cmd in @("python", "py", "python3")) {
    $c = Get-Command $cmd -ErrorAction SilentlyContinue
    if ($c) { $python = $c.Source; break }
}
if (-not $python) {
    Write-Error "Python not found on PATH. Install Python 3 from https://python.org and retry."
    exit 1
}

$args = @((Join-Path $here "serve.py"), "--port", $Port)
if ($ScriptOutput -ne "") { $args += @("--script-output", $ScriptOutput) }
if ($NoBrowser) { $args += "--no-browser" }

Write-Host "Launching: $python $($args -join ' ')"
& $python @args
