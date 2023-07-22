# Install and configure system

# Install chezmoi if it doesn't exist
function Install-Chezmoi {

  $binDir = "$env:USERPROFILE\.local\bin"
  $chezmoi = Get-Command chezmoi -ErrorAction SilentlyContinue
  
  # Check if chezmoi is already installed
  if ($chezmoi) {
    Write-Output $chezmoi.Source
    return
  }

  $chezmoi = "$binDir\chezmoi"

    # Get install script
  if (Test-Path (Get-Command curl -ErrorAction SilentlyContinue)) {
    $installScript = Invoke-WebRequest -Uri "https://chezmoi.io/get" -UseBasicParsing
  } elseif (Test-Path (Get-Command wget -ErrorAction SilentlyContinue)) {
    $installScript = Invoke-WebRequest -Uri "https://chezmoi.io/get" -UseBasicParsing
  } else {
    Write-Output "To install chezmoi, you must have curl or wget installed." 2>&1
    exit 1
  }

  $installScript.Content | Invoke-Expression

  Write-Output $chezmoi
}


#################### Main Program ####################

Set-StrictMode -Version Latest

# Get chezmoi
$chezmoi = Install-Chezmoi

# PowerShell way to get the script's directory
$scriptDir = Split-Path $MyInvocation.MyCommand.Path

$PSBoundParameters.Clear()
$PSBoundParameters.Add("source", $scriptDir)

# Replace the current process with chezmoi
Write-Output "Running 'chezmoi init --apply --source=$scriptDir'" 2>&1
Start-Process $chezmoi -ArgumentList "init", "--apply", "--source=$scriptDir" -Wait
