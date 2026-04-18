function uvdate {
    Write-Host "Checking for package updates..." -ForegroundColor Yellow
    $changes = (uv sync --dry-run --upgrade --output-format json 2>$null | ConvertFrom-Json).sync.changes

    if ($changes.Length -ne 0) {
        Write-Host "`e[1A`e[2KParsing package updates..." -ForegroundColor Yellow
        $stats = @{}
        $tableRows = [System.Collections.Generic.List[object]]::new()
        foreach ($change in $changes) {
            $name = $change.name
            if (-not $stats.ContainsKey($name)) {
                $stats[$name] = [PSCustomObject]@{
                    Name = $name
                    Uninstalled = $null
                    Installed = $null
                }
                [void]$tableRows.Add($stats[$name])
            }

            if ($change.action -eq "uninstalled") {
                $stats[$name].Uninstalled = $change.version
            } else {
                $stats[$name].Installed = $change.version
            }
        }
        $statAsString = ($tableRows | Out-String).Trim().Split("`n") | ForEach-Object { $_.Trim() }
        $header = $statAsString | Select-Object -first 1
        $options = $statAsString | Select-Object -skip 2
        [System.Console]::SetCursorPosition(0, [System.Console]::CursorTop - 1)
        $output = $options | fzf --footer $header --multi --cycle --preview-window="hidden" --height="~100%"
        if ($null -eq $output) {
            Write-Host "No packages selected for upgrade." -ForegroundColor Cyan
            return
        }
        $toUpdate = $output | ForEach-Object { $_.split(" ")[0] }

        $uvargs = @()
        foreach ($name in $toUpdate) {
            $uvargs += '--upgrade-package'
            $uvargs += "$name"
        }
        Write-Host "> uv sync $($uvargs -join ' ')" -ForegroundColor Green
        uv sync @uvargs
    } else {
        # go up one cursor
        [System.Console]::SetCursorPosition(0, [System.Console]::CursorTop - 1)
        Write-Host No packages to upgrade -ForegroundColor Green
    }
}
