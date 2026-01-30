if ($null -eq (Get-Module -Name PwshSpectreConsole -ListAvailable)) { Install-Module -Name PwshSpectreConsole }

function ghet {
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$RepoSlug
    )
    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'

    Write-Host ""

    if ($RepoSlug -match '^https://github\.com/([A-Za-z0-9_.-]+)/([A-Za-z0-9_.-]+)$') {
        $RepoSlug = "$($Matches[1])/$($Matches[2])"
    } elseif ($RepoSlug -notmatch '^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$') {
        Write-Host "Repo must be in 'user/repo' or 'https://github.com/user/repo' form. Provided: $RepoSlug" -ForegroundColor Red
        Write-Host ""
        return
    }

    $owner, $repo = $RepoSlug.Split('/')
    $api = "https://api.github.com/repos/$owner/$repo/releases/latest"
    $headers = @{ 'User-Agent' = 'ghet-script'; 'Accept' = 'application/vnd.github+json' }
    if ($env:GITHUB_TOKEN) { $headers['Authorization'] = "Bearer $env:GITHUB_TOKEN" }

    Write-Host "╭─ grabbing from $RepoSlug"

    try {
        $release = Invoke-RestMethod -Uri $api -Headers $headers -Method Get
    } catch {
        Write-Host "╰─ failed to fetch release: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
        return
    }

    if (-not $release.assets -or $release.assets.Count -eq 0) {
        Write-Host "╰─ no assets found in latest release '$(($release.name) -or $release.tag_name)'" -ForegroundColor Yellow
        Write-Host ""
        return
    }

    # Filter useful stuff
    $assets = @($release.assets) | Where-Object {
        $_.name -match '\.(exe|msi|bat|cmd)$' -or $_.name -match '\.(zip|tar\.gz|tgz)$'
    }
    if ($assets.Count -eq 0) {
        Write-Host "╰─ no matching executable-type assets (.exe/.msi/.zip/etc.)" -ForegroundColor Yellow
        Write-Host ""
        return
    }

    if ($release.name) {
        $releaser = $release.name
    } elseif ($release.tag_name) {
        $releaser = $release.tag_name
    } else {
        Write-Host "╰─ no tags found!" -ForegroundColor Red
        Write-Host ""
        return
    }
    Write-Host "│ " -NoNewLine
    Write-Host "release: $releaser" -ForegroundColor Green

    $docontinue = $true
    Write-Host "│ Select an asset to download:"
    $chosen = Read-SpectreSelection -Message "" -Choices $assets -ChoiceLabelProperty "name" -EnableSearch -SearchHighlightColor cyan3
    Write-Host "│ " -NoNewLine
    Write-Host "`e[?25h`downloading '$($chosen.name)' ..." -ForegroundColor Cyan
    $outFile = Join-Path -Path (Get-Location) -ChildPath $chosen.name
    try {
        Invoke-WebRequest -Uri $chosen.browser_download_url -Headers $headers -OutFile $outFile -UseBasicParsing
    } catch {
        Write-Host "╰─ Download failed: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
        return
    }
    Write-Host "╰─ " -NoNewLine
    Write-Host "Saved to $outFile" -ForegroundColor Green
    Write-Host ""
}
