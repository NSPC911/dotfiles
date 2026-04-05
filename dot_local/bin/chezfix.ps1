$path = chezmoi source-path
Set-Location $path
git reset HEAD --hard
git checkout main
git pull --rebase --autostash
Copy-Item ./dot_wezterm.lua ~/.wezterm.lua -Force
@("lazygit", "rovr", "rio") | ForEach-Object {
    Copy-Item "./AppData/Local/$_" ~/.config/ -Recurse -Force
    Write-Host "./AppData/Local/$_"
}
@("alacritty", "helix") | ForEach-Object {
    Copy-Item "./AppData/Roaming/$_" ~/.config/ -Recurse -Force
    Write-Host "./AppData/Roaming/$_"
}
@("fastfetch", "opencode", "ov", "rovr") | ForEach-Object {
    Copy-Item "./dot_config/$_" ~/.config/ -Recurse -Force
    Write-Host "./dot_config/$_"
}
@("kushal.omp.json", "omp_export.json") | ForEach-Object {
    Copy-Item "./dot_config/$_" "~/.config/$_" -Force
    Write-Host "./dot_config/$_"
}
Copy-Item "./readonly_Documents/PowerShell/*" "~/.config/powershell/" -Force
Copy-Item "./dot_copilot/*" "~/.copilot/" -Force 
git checkout linux
chezsync -NoAsk
