function uvdate {
    Write-Host "Checking for package updates..." -ForegroundColor Yellow
    $changes = (uv lock --dry-run --upgrade 2>&1 | Select-Object -Skip 1)
    if ($changes -eq "No lockfile changes detected") {
        [System.Console]::SetCursorPosition(0, [System.Console]::CursorTop - 1)
        Write-Host "Nothing to update!" -ForegroundColor Green
        return
    }
    Write-Host "`e[1A`e[2KParsing package updates..." -ForegroundColor Yellow
    $options = @()
    $changes = $changes -split "`n"
    $changes | ForEach-Object {
        $parts = $_.split(" ")
        if (($parts[0] -ne "Update") -or ($parts[3] -ne "->")) {
            Write-Error "Received incorrect string: ``$_``"
            return
        }
        $options = $options + [PSCustomObject]@{
            Name = $parts[1]
            Current = $parts[2]
            New = $parts[4]
        }
    }
    [System.Console]::SetCursorPosition(0, [System.Console]::CursorTop - 1)
    $optionsAsArray = ($options | Out-String).Trim() -Split "`n"
    $header = $optionsAsArray | Select-Object -First 1
    $body = ($optionsAsArray | Select-Object -Skip 4 -SkipLast 1 | ForEach-Object { $_.Trim() }) -join "`n"
    $output = $body | fzf --footer "$($header.Trim())" --multi --cycle --preview-window="hidden" --height="~100%" --ignore-case
    if ($null -eq $output) {
        Write-Host "No packages selected for update." -ForegroundColor Yellow
        return
    }
    $toUpdate = $output | ForEach-Object { $_.split(" ")[0] } | Where-Object { $_ -ne "" }

    $uvargs = @()
    foreach ($name in $toUpdate) {
        $uvargs += "--upgrade-package"
        $uvargs += $name
    }
    Write-Host "> uv lock $($uvargs -join " ")" -ForegroundColor Cyan
    uv sync @uvargs
}
