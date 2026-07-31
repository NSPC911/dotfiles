$niriOutput = (niri msg --json outputs | jq --sort-keys)

$niriObj = ($niriOutput | ConvertFrom-Json)

$monitors = ($niriOutput | jq "keys" | ConvertFrom-Json)
if ($monitors.Length -ne 2) {
    exit
}

# what we want to do is replicate something like win+p on windows, but using
# niri and without duplicating (niri has no support for that yet unless
# you use wl-mirror, but thats quite finicky)

$monitorStates = [PSCustomObject]@{}
$isBothOn = $true

foreach ($monitor in $monitors) {
    $monitorInfo = ($niriObj | Select-Object -ExpandProperty $monitor)
    if ($null -eq $monitorInfo.current_mode) {
        $monitorStates | Add-Member -NotePropertyName $monitor -NotePropertyValue "off"
        $isBothOn = $false
    } else {
        $monitorStates | Add-Member -NotePropertyName $monitor -NotePropertyValue "on"
    }
}

# must follow a True-True, False-True, True-False for the monitor state
# so basically first is extend, second is second screen only, third is primary only
if ($isBothOn) {
    # turn off the second monitor
    niri msg output $($monitors[0]) on
    $zeroOn = $true
    niri msg output $($monitors[1]) off
    $oneOn = $false
} elseif ($monitorStates.$($monitors[0]) -eq "off") {
    niri msg output $($monitors[0]) on
    $zeroOn = $true
    niri msg output $($monitors[1]) on
    $oneOn = $true
} else {
    niri msg output $($monitors[1]) on
    $oneOn = $true
    niri msg output $($monitors[0]) off
    $zeroOn = $false
}

Stop-Process -Name "linux-wallpaperengine" -ErrorAction SilentlyContinue
Stop-Process -Name "swaybg" -ErrorAction SilentlyContinue
if ($zeroOn) {
    niri msg action spawn -- linux-wallpaperengine 1176090049 "--scaling" "fill" "--screenshot" "$HOME/Pictures/Wallpapers/1176090049.png" "--disable-mouse" "--disable-parallax" "--fullscreen-pause-only-active" "--fps" "20" "--silent" "--screen-root" $($monitors[0])
}
if ($oneOn) {
    niri msg action spawn -- linux-wallpaperengine 1176090049 "--scaling" "fill" "--screenshot" "$HOME/Pictures/Wallpapers/1176090049.png" "--disable-mouse" "--disable-parallax" "--fullscreen-pause-only-active" "--fps" "20" "--silent" "--screen-root" $($monitors[1])
}
Start-Sleep -Seconds 1
magick ~/Pictures/Wallpapers/1176090049.png -blur 0x15 ~/Pictures/Wallpapers/blurred_1176090049.png

niri msg action spawn-sh -- "swaybg --image ~/Pictures/Wallpapers/blurred_1176090049.png --output '*'"

