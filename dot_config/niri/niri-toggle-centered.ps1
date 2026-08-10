$onoverflow = @"
layout {
    center-focused-column "on-overflow"
}
"@
$never = @"
layout {
    center-focused-column "never"
}
"@

if ((Get-Content "~/.config/niri/center-focused-column.kdl") -like "*on-overflow*") {
    $never | Set-Content "~/.config/niri/center-focused-column.kdl"
    dms notify --app "niri-toggle-centered.ps1" --icon "ps1" "centered never" --timeout 1000
} else {
    $onoverflow | Set-Content "~/.config/niri/center-focused-column.kdl"
    dms notify --app "niri-toggle-centered.ps1" --icon "ps1" "centered on-overflow" --timeout 1000
}
