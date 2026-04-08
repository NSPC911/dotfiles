$niriOutput = (niri msg --json outputs | jq --sort-keys)

$niriObj = ($niriOutput | ConvertFrom-Json)

$monitors = ($niriOutput | jq "keys" | ConvertFrom-Json)

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
    niri msg output $($monitors[1]) off
} elseif ($monitorStates.$($monitors[0]) -eq "off") {
    niri msg output $($monitors[0]) on
    niri msg output $($monitors[1]) on
} else {
    niri msg output $($monitors[1]) on
    Start-Sleep -Seconds 2
    niri msg output $($monitors[0]) off
}
