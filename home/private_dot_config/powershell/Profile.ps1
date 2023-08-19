#  ______           __ _ _
#  | ___ \         / _(_) |
#  | |_/ / __ ___ | |_ _| | ___
#  |  __/ '__/ _ \|  _| | |/ _ \
#  | |  | | | (_) | | | | |  __/
#  \_|  |_|  \___/|_| |_|_|\___|
#
#


# XDG Base Directory Specification
$env:XDG_CACHE:Windows_HOME = "$HOME/.cache"
$env:XDG_CONFIG_HOME = "$HOME/.config"
$env:XDG_DATA_HOME = "$HOME/.local/share"

# Import modules
Import-Module PSReadLine
Import-Module Terminal-Icons

# Theme
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/space.omp.json" | Invoke-Expression

## Set PSReadLine options and keybindings
$PSROptions = @{
    "EditMode"            = "Windows"
    "PredictionSource"    = "History"
    "PredictionViewStyle" = "ListView"
}
Set-PSReadLineOption @PSROptions
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward

# Aliases
Set-Alias clr "clear"
Set-Alias cz "chezmoi"
Set-Alias msbuild "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe"
Set-Alias sonar-scanner "C:\Program Files\sonar-scanner\SonarScanner.MSBuild.exe"
Set-Alias speedtest "C:\Program Files\speedtest\speedtest.exe"
