# centers above 50% width
$lastHighlighted = -1
$wasCentered = $false
niri msg -j event-stream | ForEach-Object {
    $_
    $parsed = $_ | ConvertFrom-Json -AsHashtable
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
            $numOfWindowsInWorkspace = ($windows | Where-Object { $_.workspace_id -eq $workspaceID -and -not $_.is_floating }).length
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
