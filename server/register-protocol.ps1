# Registers a one-time custom URL protocol so the "Start Server" button in the
# HTML guide can launch the local sync server.
#
#   Run once:        pwsh -File register-protocol.ps1
#   Undo:            pwsh -File register-protocol.ps1 -Unregister
#
# Registration is per-user (HKCU) - no admin rights required. After this, the
# browser can open  factorio-guide://start  which runs launch-server-silent.bat.

param([switch]$Unregister)

$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$bat  = Join-Path $here "launch-server-silent.bat"
$root = "HKCU:\Software\Classes\factorio-guide"

if ($Unregister) {
    if (Test-Path $root) {
        Remove-Item -Path $root -Recurse -Force
        Write-Host "Unregistered factorio-guide:// protocol."
    } else {
        Write-Host "Nothing to unregister."
    }
    return
}

if (-not (Test-Path $bat)) {
    Write-Error "launch-server-silent.bat not found at $bat"
    exit 1
}

# The protocol handler. We do NOT include %1, so Windows appends the URL as a
# trailing arg; launch-server-silent.bat ignores extra args.
$command = 'cmd /c "' + $bat + '"'

New-Item -Path $root -Force | Out-Null
Set-ItemProperty -Path $root -Name "(default)" -Value "URL:Factorio Guide Server"
Set-ItemProperty -Path $root -Name "URL Protocol" -Value ""

$cmdKey = Join-Path $root "shell\open\command"
New-Item -Path $cmdKey -Force | Out-Null
Set-ItemProperty -Path $cmdKey -Name "(default)" -Value $command

Write-Host "Registered factorio-guide:// -> $bat"
Write-Host "The 'Start Server' button in the guide will now work."
