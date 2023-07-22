
#######################################
# Copy settings files
# Globals:
#   None
# Arguments:
#   $Source: The source path to copy the settings from.
#   $Target: The destination path to copy the settings to.
#######################################
function Apply-Settings() {
  param( [string]$Source, [string]$Target )
  try {
    if (-Not (Test-Path -Path $Target -PathType Container)) {  New-Item -ItemType Directory -Path $Target -Force | Out-Null }
    Copy-Item -Path $Source -Destination $Target -Recurse -Force
  } catch {
    Write-Host "Error applying settings: $_"
  }
}


#################### Main Program ####################

# Stop script on error
$ErrorActionPreference = 'Stop'

# Apply Powershell profile
Write-Host "Applying Powershell profile..."
Apply-Settings -Source "$env:USERPROFILE/.config/powershell/Profile.ps1" -Target "$env:USERPROFILE/Documents/PowerShell"

# Apply VSCode settings
Write-Host "Applying VSCode settings..."
Apply-Settings -Source "$env:USERPROFILE/.config/vscode/*" -Target "$env:APPDATA/Code/User"

# Apply Windows Terminal settings
Write-Host "Applying Windows Terminal settings..."
Apply-Settings -Source "$env:USERPROFILE/.config/wt/*" -Target "$env:LOCALAPPDATA/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState"
