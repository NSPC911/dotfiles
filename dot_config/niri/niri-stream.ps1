# centers above 50% width
$lastHighlighted = -1
$wasCentered = $false

# config here
$doCentering = $false
$doPopupFollowWorkspace = $true

$thisFileMtime = (Get-Item $MyInvocation.MyCommand.Path).LastWriteTime

systemctl --user -q is-active niri-patched.service
$np = $LASTEXITCODE
systemctl --user -q is-active niri.service
$p = $LASTEXITCODE

if (($np -eq 0) -and ($p -eq 0)) {
    Write-Error "Both niri and niri-patched are running. Please stop one of them."
    exit 1
} elseif ($np -ne 0 -and $p -ne 0) {
    Write-Error "Neither niri nor niri-patched is running. Please start one of them."
    exit 1
} elseif ($np -eq 0) {
    $niri = "niri-patched"
} else {
    $niri = "niri"
}

Write-Host "Using $niri"

function niri {
    param(
        # Captures everything else passed to the function
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$rags
    )
    & $niri @rags
}

niri msg -j event-stream | ForEach-Object {
    if ((Get-Item $MyInvocation.MyCommand.Path).LastWriteTime -ne $thisFileMtime) {
        Write-Host "Reloading script due to file change..."
        niri msg action spawn -- powershell -NoProfile $MyInvocation.MyCommand.Path
        dms notify "Reloaded niri-stream.ps1 due to file change."
        exit
    }
    $parsed = $_ | ConvertFrom-Json -AsHashtable
    if ($doCentering) {
        if ($parsed.ContainsKey("WindowFocusChanged")) {
            $windowID = $parsed.WindowFocusChanged.id
            $window = (niri msg -j windows | ConvertFrom-Json | Where-Object { $_.id -eq $windowID })
        } elseif ($parsed.ContainsKey("WindowLayoutsChanged")) {
            $window = (niri msg -j focused-window | ConvertFrom-Json)
            $windowID = $window.id
        } elseif ($parsed.ContainsKey("WorkspaceActiveWindowChanged")) {
            $windowID = $parsed.WorkspaceActiveWindowChanged.active_window_id
            $window = (niri msg -j windows | ConvertFrom-Json | Where-Object { $_.id -eq $windowID })
        } else {
            $window = $null
        }
        if ($null -ne $window) {
            $outputs = (niri msg -j outputs | ConvertFrom-Json -AsHashtable)
            if ($outputs.ContainsKey("DP-1")) {
                # my external monitor
                $screenwidth = $outputs["DP-1"].logical.width
            } else {
                # my internal monitor
                $screenwidth = $outputs["eDP-1"].logical.width
            }
            $windowwidth = $window.layout.window_size[0]
            if (
                (
                    ($screenwidth / 2) -lt $windowwidth
                ) -or (
                    $lastHighlighted -eq $windowID -and $wasCentered
                )
            ) {
                # kinda parse
                $windows = (niri msg -j windows | ConvertFrom-Json)
                $workspaceID = ($windows | Where-Object { $_.id -eq $windowID }).workspace_id
                # find the last pos in scrolling layout
                $lastX = 0
                ForEach ($w in $windows) {
                    if ($w.workspace_id -eq $workspaceID -and -not $w.is_floating) {
                        $lastX = [Math]::Max($lastX, $w.layout.pos_in_scrolling_layout[0])
                    }
                }
                if (
                    $window.layout.pos_in_scrolling_layout[0] -ne 1 -and $window.layout.pos_in_scrolling_layout[0] -ne $lastX
                ) {
                    # make window centered if it's too wide
                    niri msg -j action center-window --id $windowID
                    $wasCentered = $true
                }
            } else {
                $wasCentered = $false
            }
            $lastHighlighted = $windowID
        }
    }
    if ($doPopupFollowWorkspace) {
        if ($parsed.ContainsKey("WorkspaceActivated")) {
            # so stupid right? I could have used `$workspaceID = $parsed.WorkspaceActivated.id`
            # but niri only sends workspace id, but uses idx for moving windows
            $workspaceID = (niri msg -j workspaces | ConvertFrom-JSON | Where-Object { $_.is_active -eq $true }).idx
            $popupwindows = niri msg -j windows | ConvertFrom-JSON | Where-Object { $_.is_floating -eq $true }
            $popupwindows | ForEach-Object { niri msg action move-window-to-workspace --window-id $_.id $workspaceID }
        }
    }
}
