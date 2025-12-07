Set-Location $HOME
##### Cache Completions #####
$cacheCompletionLocation = "$PROFILE/../completion-cache.ps1"
function regenCache {
    Remove-Item $cacheCompletionLocation -ErrorAction Ignore
    New-Item -Path $cacheCompletionLocation -Force
    Clear-Host

    $completions = @()

    Write-Output "`e[HSetting up zoxide"
    $completions += zoxide init powershell

    Write-Output "`e[HSetting up oh-my-posh"
    $completions += oh-my-posh init powershell --config $HOME\.config\kushal.omp.json

    Write-Output "`e[HSetting up uv completions"
    $completions += uv generate-shell-completion powershell

    Write-Output "`e[HSetting up gh completions"
    $completions += gh completion -s powershell

    # Write-Output "`e[HSetting up pixi completions"
    # $completions += pixi completion --shell powershell

    Write-Output "`e[HSetting up tuios completions"
    $completions += tuios completion powershell

    Write-Output "`e[HSetting up tombi completions"
    $completions += tombi completion powershell

    Write-Output "`e[HSetting up batcat completions"
    $completions += bat --completion ps1

    Write-Output "`e[HSetting up rustup completions"
    $completions += rustup completions powershell

    Write-Output "`e[HSetting up chezmoi completions"
    $completions += chezmoi completion powershell

    Write-Output "`e[HSetting up ripgrep completions"
    $completions += rg --generate complete-powershell

    Write-Output "`e[HSetting up wezterm completions"
    $completions += wezterm shell-completion --shell power-shell

    # Write-Output "`e[HSetting up regolith completions"
    # $completions += regolith completion powershell

    Write-Output "`e[HSetting up onefetch completions"
    $completions += onefetch --generate powershell

    # Extract all 'using' statements and remove duplicates
    $usingStatements = @()
    $cleanedCompletions = @()

    foreach ($completion in $completions) {
        $lines = $completion -split "`n"
        $nonUsingLines = @()

        foreach ($line in $lines) {
            if ($line.Trim() -match '^using\s+') {
                if ($usingStatements -notcontains $line.Trim()) {
                    $usingStatements += $line.Trim()
                }
            } else {
                $nonUsingLines += $line
            }
        }

        $cleanedCompletions += ($nonUsingLines -join "`n")
    }

    # Write consolidated file: using statements first, then completions
    $finalContent = @()
    $finalContent += $usingStatements
    $finalContent += ""  # Empty line separator
    $finalContent += $cleanedCompletions

    $finalContent -join "`n" | Out-File $cacheCompletionLocation -Encoding UTF8
}
if (-not (Test-Path $cacheCompletionLocation)) {
    Write-Output "Creating cache..."
    regenCache
} elseif ((Get-Item $cacheCompletionLocation).LastWriteTime -lt (Get-Date).AddDays(-1)) {
    Write-Output "Regenerating cache..."
    Start-Process pwsh -Verb RunAs -ArgumentList "-Command regenCache" -WindowStyle Hidden
} else {
    Write-Output "Using script cache..."
}

. $cacheCompletionLocation

## zoxide cant add them for some reason /shrug
Set-Alias -Option AllScope -Name "cd" -Value "__zoxide_z"
Set-Alias -Option AllScope -Name "cdi" -Value "__zoxide_zi"
Set-Alias -Option AllScope -Name "cdb" -Value "__zoxide_bin"
# temporary fix for zoxide
$prevloc = "$PROFILE/../prevloc"
function global:__zoxide_cd($dir, $literal) {
    $dir = if ($literal) {
        Set-Location -LiteralPath $dir -Passthru -ErrorAction Stop
        zoxide add .
        pwd | select -Expand Path | Out-File $prevloc
    } else {
        if ($dir -eq '-' -and ($PSVersionTable.PSVersion -lt 6.1)) {
            Write-Error "cd - is not supported below PowerShell 6.1. Please upgrade your version of PowerShell."
        }
        elseif ($dir -eq '+' -and ($PSVersionTable.PSVersion -lt 6.2)) {
            Write-Error "cd + is not supported below PowerShell 6.2. Please upgrade your version of PowerShell."
        }
        else {
            Set-Location -Path $dir -Passthru -ErrorAction Stop
            zoxide add .
        }
    }
}

##### Superfile Go To Last Dir #####
Write-Output "`e[HDealing with functions and aliases..."
function spf {
    $spf_location = "C:\Users\notso\scoop\shims\spf.exe"
    $SPF_LAST_DIR_PATH = [Environment]::GetFolderPath("LocalApplicationData") + "\superfile\lastdir"

    & spf.exe $args
    if (Test-Path $SPF_LAST_DIR_PATH) {
        $SPF_LAST_DIR = Get-Content -Path $SPF_LAST_DIR_PATH
        Invoke-Expression $SPF_LAST_DIR
        Remove-Item -Force $SPF_LAST_DIR_PATH
    }
}

##### rovr Go To Last Dir #####
function rovr {
    $cwd_file = New-TemporaryFile
    & rovr.exe --cwd-file $cwd_file $args
    if (Test-Path $cwd_file) {
        $new_loc = Get-Content $cwd_file
        if (-not [String]::IsNullOrEmpty($new_loc) -and $new_loc -ne (Get-Location).Path) {
            Set-Location $new_loc -ErrorAction SilentlyContinue
        }
        Remove-Item $cwd_file
    }
}

##### Aliases #####
function nuke {
    param($ProcessName)
    if (-not $ProcessName.EndsWith('.exe')) { $ProcessName = "$ProcessName.exe" }
    taskkill.exe /F /IM $ProcessName
}
Set-Alias -Name "whereis" -Value "where.exe"

function Remove-Location { Remove-Item -Recurse -Force $args }
Set-Alias -Name rmloc -Value Remove-Location

function symlink {
    param(
        [Parameter(Position = 0)]
        [string]$ItemToSymlinkFrom,

        [Parameter(Position = 1)]
        [string]$ItemToSymlinkTo
    )
    New-Item -ItemType SymbolicLink -Path $ItemToSymlinkTo -Target (Resolve-Path $ItemToSymlinkFrom).Path
}

function Get-Folder-Size {
    Get-ChildItem -Recurse | Measure-Object -Property Length -Sum | Select-Object @{Name="Size(GB)";Expression={[math]::round($_.Sum/1GB,2)}}
}

function touch {
    New-Item -ItemType File -Force -Path $args
}

Set-Alias -Name extract -Value Expand-Archive

##### Python Venv #####
function pyvenv() {
    param(
        [Parameter()][switch]$Poetry,
        [Parameter()][switch]$AllGroups,
        [Parameter()][switch]$Upgrade,
        [Parameter()][switch]$Update,
        [Parameter()][switch]$NoSync,
        [Parameter()][switch]$Offline
    )
    if ($Poetry) {
        if (Get-Command -Name "deactivate" -CommandType Function -ErrorAction SilentlyContinue) {
            Write-Host "┌❯ Deactivating virtual environment"
            Write-Host "└─ " -NoNewLine
            Write-Host "deactivate" -ForegroundColor Yellow
            deactivate
        }
        Write-Host "┌❯ Activating virtual environment"
        Write-Host "└─ " -NoNewLine
        Write-Host "poetry env activate | Invoke-Expression" -ForegroundColor Yellow
        poetry env activate | Invoke-Expression
        Write-Host "Virtual Environment is active!" -ForegroundColor Green
        Write-Host "┌❯ Installing packages with 'pyproject.toml'"
        Write-Host "└─ " -NoNewLine
        if (-not $NoSync) {
            Write-Host "poetry self sync" -ForegroundColor Yellow
            poetry self sync --quiet
        }
        Write-Host "Virtual Environment has been synced!" -ForegroundColor Green
    } else {
        if (Test-Path venv\Scripts) {
            Write-Host "┌❯ Using " -NoNewLine
            Write-Host "venv" -ForegroundColor Cyan
            Write-Host "├❯ Activating virtual environment"
            Write-Host "└─ " -NoNewLine
            Write-Host ".\venv\Scripts\Activate.ps1" -ForegroundColor Yellow
            .\venv\Scripts\Activate.ps1
        } elseif (-not (Test-Path .venv)) {
            Write-Host "┌❯ Creating new virtual environment"
            Write-Host "└─ " -NoNewLine
            Write-Host "uv venv" -ForegroundColor Yellow
            uv venv --quiet
        }
        if (Test-Path .venv\Scripts) {
            Write-Host "┌❯ Using " -NoNewLine
            Write-Host ".venv" -ForegroundColor Cyan
            Write-Host "├❯ Activating virtual environment"
            Write-Host "└─ " -NoNewLine
            Write-Host ".\.venv\Scripts\Activate.ps1" -ForegroundColor Yellow
            .\.venv\Scripts\Activate.ps1
        }
        Write-Host "Virtual Environment is active!" -ForegroundColor Green
        if ((-not $NoSync)) {
            if (Test-Path pyproject.toml) {
                # get current diff
                $current = New-TemporaryFile
                uv pip freeze | Out-File -Path $current
                Write-Host "┌❯ Syncing packages with 'pyproject.toml'"
                Write-Host "└─ " -NoNewLine
                $flags = ""
                if ($AllGroups) {
                    $flags += "--all-groups "
                }
                if ($Update -or $Upgrade) {
                    $flags += "--upgrade "
                }
                if ($Offline) {
                    $flags += "--offline"
                }
                $flags = $flags.Trim()
                if ($flags -eq "") {
                    Write-Host "uv sync --active $flags" -ForegroundColor Yellow
                    uv sync --active --quiet
                } else {
                    Write-Host "uv sync --active $flags" -ForegroundColor Yellow
                    uv sync --active $flags.Split() --quiet
                }
                $synced = New-TemporaryFile
                uv pip freeze | Out-File -Path $synced
                git diff --no-index $current $synced -U0 --no-prefix
            } elseif (Test-Path requirements.txt) {
                Write-Host "┌❯ Syncing packages with 'requirements.txt'"
                Write-Host "└─ " -NoNewLine
                Write-Host "uv pip sync -r requirements.txt" -ForegroundColor Yellow
                uv pip install -r requirements.txt --quiet
            } else {
                Write-Host "┌❯ There are no packages available to be synced"
                Write-Host "└❯ Make sure to either " -NoNewLine
                Write-Host "uv init --bare" -ForegroundColor Cyan -NoNewLine
                Write-Host " or " -NoNewLine
                Write-Host "touch requirements.txt" -ForegroundColor Cyan -NoNewLine
                Write-Host "!"
            }
            Write-Host "Virtual Environment has been synced!" -ForegroundColor Green
        }
    }
}

##### Pretty Print 'CURL's #####
function curlout {
    param(
        [Parameter(Position = 0)]
        [string]$Url,

        [Parameter(Position = 1)]
        [string]$Lang
    )
    Invoke-RestMethod $Url | bat -l $Lang
}

##### id like a sha256 please ######
function sha256 { Get-FileHash -Algorithm SHA256 $args | Select-Object -ExpandProperty Hash }

##### figlet #####
function figlet {
    param([Parameter(Position = 0)][string]$name)
    $figlets = uvx pyfiglet --list_fonts | Out-String -Stream
    Write-Host "Obtained " -NoNewLine
    Write-Host $figlets.count -ForegroundColor Cyan -NoNewLine
    Write-Host " figlet styles!"
    $figlets | ForEach-Object { Write-Output $_; uvx pyfiglet -f $_ $name -w $Host.UI.RawUI.WindowSize.Width }
}

#### LazyGit #####
Set-Alias -Name "lz" -Value "lazygit"

##### Give me my full history man #####
function Get-FullHistory {
    Get-Content (Get-PSReadlineOption).HistorySavePath | ? {$_ -like "*$find*"} | Get-Unique
}

##### run something foreva!! #####
function forever {
    while ($true) { Invoke-Expression "$args" }
}

##### PS Plugins #####
Write-Output "`e[HAdding Plugins...                        "
# https://github.com/devblackops/Terminal-Icons
Import-Module -Name Terminal-Icons
# should be available if you installed scoop
Import-Module "$($(Get-Item $(Get-Command scoop.ps1).Path).Directory.Parent.FullName)\modules\scoop-completion"
# https://github.com/PowerShell/PSReadLine
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Chord "Shift+Tab" -ScriptBlock { Invoke-FzfTabCompletion }
Set-PSReadLineKeyHandler -Chord Ctrl+Enter -Function SwitchPredictionView
Remove-PSReadLineKeyHandler -Key "F2"
Set-PSReadLineOption -Colors @{
  ListPredictionSelected = "`e[7m"
}
Set-PSReadLineOption -BellStyle None

##### chezmoi #####
function chezcd { __zoxide_cd (chezmoi source-path) }
function chezedit { chezmoi edit --apply $args }
function chezadd { chezmoi add $args }
function chezgit { chezmoi git $args }

##### fzf plugin (needs that one powershell plugin) #####
function fuzzy {
    param(
        [ValidateSet("edit", "git", "status", "kill", "nuke", "scoop", "install", "cd", "history")]
        [string]$type,
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$extra
    )
    if ($type -eq "edit") {
        hx (fz)
    } elseif (($type -eq "status") -or ($type -eq "git")) {
        Invoke-FuzzyGitStatus
    } elseif (($type -eq "history")) {
        Invoke-FuzzyHistory
    } elseif (($type -eq "kill") -or ($type -eq "nuke")) {
        Invoke-FuzzyKillProcess
    } elseif (($type -eq "scoop") -or ($type -eq "install")) {
        Invoke-FuzzyScoop
    } elseif (($type -eq "cd")) {
        Get-ChildItem . -Recurse | ? { $_.PSIsContainer } | Invoke-Fzf | Set-Location
    } else {
        Write-Error "Unknown operation $type. Allowed: edit, status/git, history, kill/nuke or scoop/install"
    }
}

##### posh print #####
function posh-print {
    (oh-my-posh print --config ~\.config\kushal.omp.json primary).Split("`n") | ForEach { Write-Host ; Write-Host $_ -NoNewLine }
    Write-Host -ForegroundColor Yellow $args
    Write-Host
}

##### gh copilot cli but local #####
$suggesterModel = "codegemma:7b"
$explainerModel = "codegemma:2b"
function ols {
    param(
        [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
        [string]$Description
    )

    Write-Host ""

    if (-not $Description) {
        Write-Host "Usage: ols <description of what you want to do>" -ForegroundColor Red
        Write-Host ""
        return
    }

    $prompt = "You are a CLI assistant in a Windows environemnt with pwsh as the active shell. The user wants to: '$Description'. Respond with ONLY the raw pwsh command. Do not use markdown, code blocks or any formatting. Just output the plain command text."

    $rawOutput = ollama run $suggesterModel $prompt
    $command = ($rawOutput | out-string).Trim()
    Write-Host "`e[1G╭─ Suggested command:"
    Write-Host "│"
    Write-Host "·  " -NoNewLine
    $command | bat --language Powershell --plain
    Write-Host "│"
    $options = @("Run", "Copy", "Edit", "Improve", "Quit")
    $selectedIndex = 0

    do {
        # claude sonnet helped do this part, pretty cool imo
        Write-Host "╰❯ " -NoNewLine
        for ($i = 0; $i -lt $options.Count; $i++) {
            if ($i -eq $selectedIndex) { Write-Host " [$($options[$i][0])]$($options[$i].Substring(1)) " -ForegroundColor DarkGray -BackgroundColor Cyan -NoNewLine }
            else { Write-Host " [$($options[$i][0])]$($options[$i].Substring(1)) " -NoNewLine }
        }
        Write-Host "`e[?25l`n"
        $key = [System.Console]::ReadKey($true)
        Write-Host "`e[2F`e[2K" -NoNewLine
        $shouldExecute = $false
        if ($key.modifiers -ne $null) {
            switch ($key.key) {
                # Left arrow
                "LeftArrow" { $selectedIndex = ($selectedIndex - 1 + $options.Count) % $options.Count }
                # Right arrow
                "RightArrow" { $selectedIndex = ($selectedIndex + 1) % $options.Count }
                # Enter key
                "Enter" { $shouldExecute = $true }
                # C key
                "C" { $selectedIndex = 1; $shouldExecute = $true }
                # E key
                "E" { $selectedIndex = 2; $shouldExecute = $true }
                # I key
                "I" { $selectedIndex = 3; $shouldExecute = $true }
                # Q key
                "Q" { $selectedIndex = 4; $shouldExecute = $true }
                # R key
                "R" { $selectedIndex = 0; $shouldExecute = $true }
            }
        }
        if ($shouldExecute) {
            Write-Host "`e[?25h├─ " -NoNewLine
            for ($i = 0; $i -lt $options.Count; $i++) {
                if ($i -eq $selectedIndex) {
                    Write-Host " [$($options[$i][0])]$($options[$i].Substring(1)) " -ForegroundColor DarkGray -BackgroundColor Cyan -NoNewLine
                } else {
                    Write-Host " [$($options[$i][0])]$($options[$i].Substring(1)) " -NoNewLine
                }
            }
            Write-Host ""
            Write-Host "│"
            # after this part is just me

            switch ($selectedIndex) {
                0 {
                    Write-Host "├─ Running command..."
                    Write-Host "│"
                    Write-Host "╰── " -NoNewLine
                    'Invoke-Expression "$command"' | bat --language Powershell --plain
                    Invoke-Expression "$command"
                    Write-Host ""
                    return
                }
                1 {
                    Write-Host "·  $('Set-Clipboard `"$command`"' | bat --language Powershell --plain)"
                    Set-Clipboard "$command"
                    Write-Host "│"
                    Write-Host "╰─ Command copied to clipboard!" -ForegroundColor Green
                    Write-Host ""
                    return
                }
                2 {
                    Write-Host "·  $('$editThis = New-TemporaryFile' | bat --language Powershell --plain --force-colorization)"
                    $editThis = New-TemporaryFile
                    Write-Host "·  $('$editThis = Rename-Item -Path $editThis.FullName -NewName ($editThis.BaseName + ".ps1") -PassThru' | bat --language Powershell --plain --force-colorization)"
                    $editThis = Rename-Item -Path $editThis.FullName -NewName ($editThis.BaseName + ".ps1") -PassThru
                    Write-Host "·  $('$command | Out-File $editThis' | bat --language Powershell --plain --force-colorization)"
                    "$command" | Out-File $editThis
                    Write-Host "·  $('& $env:EDITOR $editThis' | bat --language Powershell --plain --force-colorization)"
                    & $env:EDITOR $editThis
                    Write-Host "·  $('$command = (Get-Content $editThis)' | bat --language Powershell --plain --force-colorization)"
                    $command = (Get-Content $editThis)
                    Write-Host "·  $('Remove-Item $editThis -ErrorAction SilentlyContinue -Force' | bat --language Powershell --plain --force-colorization)"
                    Remove-Item $editThis -ErrorAction SilentlyContinue -Force
                    Write-Host "│"
                    Write-Host "├─ Modified command:"
                    Write-Host "│"
                    Write-Host "·  $($command | bat --language Powershell --plain --force-colorization)"
                    Write-Host "│"
                }
                3 {
                    Write-Host "├─ How should the command be improved?"
                    Write-Host "╰─❯ " -NoNewLine
                    $improvement = Microsoft.PowerShell.Utility\Read-Host
                    Write-Host "`e[2F├─ How should the command be improved?" -ForegroundColor Green
                    Write-Host "╰── $improvement  " -ForegroundColor Green
                    $improvePrompt = "Improve this PowerShell command ``$command``. User wants: '$improvement'. Respond with ONLY the improved command as plain text, no formatting or code blocks. This is a Windows environment with pwsh as the active shell."
                    $rawImproved = ollama run $suggesterModel $improvePrompt
                    $command = ($rawImproved | Out-String).Trim()
                    Write-Host "`e[1G╭─ Improved command:"
                    Write-Host "│"
                    Write-Host "·  " -NoNewLine
                    $command | bat --language Powershell --plain
                    Write-Host "│"
                    $selectedIndex = 0
                }
                4 {
                    Write-Host "╰─ Exited." -ForegroundColor Magenta
                    Write-Host ""
                    return
                }
            }
        }
    } while ($true)
}

function ole {
    param(
        [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
        [string]$Command
    )
    Write-Host ""
    if (-not $Command) {
        Write-Host "Usage: ole <command to explain>" -ForegroundColor Red
        return
    }
    $prompt = "Explain this PowerShell command: '$Command'. Include what it does, any parameters, and provide examples if helpful. Be concise. Format your response using Markdown."

    Write-Host " Querying...`e[1A"
    $output = ollama run $explainerModel $prompt | Out-String
    Write-Host "Rendering...`e[1A" -ForegroundColor Yellow
    $maxWidth = [int]($Host.UI.RawUI.WindowSize.Width - 8)
    $output | rich --markdown --panel rounded --expand --guides --hyperlinks --caption "Using [cyan]$explainerModel[/]" --width $maxWidth --center -
    Write-Host ""
}


##### bytes to size #####
function Convert-IntToSize {
    param (
        [long]$Bytes
    )

    $units = "Bytes", "KB", "MB", "GB", "TB", "PB", "EB"
    $index = 0
    $size = [double]$Bytes

    while ($size -ge 1024 -and $index -lt ($units.Length - 1)) {
        $size /= 1024
        $index++
    }

    "{0:N2} {1}" -f $size, $units[$index]
}


##### ghet from gh #####
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

    $rawUI = $Host.UI.RawUI
    $selected = 0
    $visibleCount = [Math]::Min(5, $assets.Count)

    $docontinue = $true

    while ($docontinue) {
        # centered selection (edge-sticking)
        if ($assets.Count -le 5) {
            $windowStart = 0
        } else {
            # Try to center the selected item
            $windowStart = $selected - 2
            # Stick to edges
            if ($windowStart -lt 0) { $windowStart = 0 }
            if ($windowStart -gt ($assets.Count - 5)) { $windowStart = $assets.Count - 5 }
        }
        $windowEnd = [Math]::Min($windowStart + $visibleCount - 1, $assets.Count - 1)

        $rawUI.CursorPosition = @{ X = 0; Y = ($rawUI.CursorPosition.Y) }
        foreach ($i in 0..($visibleCount-1)) { Write-Host (" " * ($rawUI.WindowSize.Width - 1)) -NoNewline; Write-Host '' }
        $rawUI.CursorPosition = @{ X = 0; Y = ($rawUI.CursorPosition.Y - $visibleCount) }

        for ($i = $windowStart; $i -le $windowEnd; $i++) {
            $asset = $assets[$i]
            $posInWindow = $i - $windowStart
            $assetsize = " ($(Convert-IntToSize $asset.size)) "
            if ($visibleCount -eq 5) {
                if ((($posInWindow -eq 0) -and ($i -ne 0)) -or ($posInWindow -eq ($visibleCount - 1) -and ($i -ne $assets.Count - 1))) {
                    $line = "·`e[2m  " + $asset.name + $assetsize
                } else {
                    $line = "·  " + $asset.name + $assetsize
                }
            } else {
                $line = "·  " + $asset.name + $assetsize
            }

            if ($i -eq $selected) {
                Write-Host $line -ForegroundColor Black -BackgroundColor Yellow
            } else {
                Write-Host $line
            }
        }

        Write-Host "`e[?25l`e[$visibleCount`F" -NoNewLine
        $key = [System.Console]::ReadKey($true)
        if ($key.modifiers -ne $null) {
            switch ($key.key) {
                "UpArrow" {
                    if ($selected -gt 0) { $selected-- }
                }
                "DownArrow" {
                    if ($selected -lt ($assets.Count - 1)) { $selected++ }
                }
                "Enter" {
                    $docontinue = $false
                }
                "Escape" {
                    Write-Host "`e[$visibleCount`E" -NoNewLine
                    Write-Host "╰─ Cancelled." -ForegroundColor Magenta
                    Write-Host ""
                    return
                }
                default { }
            }
        }
    }

    Write-Host "`e[$visibleCount`E" -NoNewLine

    $chosen = $assets[$selected]
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


##### Other stuff #####
Clear-Host
function fetch {
    param (
        [Parameter()]
        [Switch]$Clear
    )
    if ($Clear) {
        Clear-Host
    }
    gitfetch --graph-only
    Write-Host "`e[1A"
    fastfetch
}
fetch
if (Test-Path $prevloc) {
    $newloc = Get-Content "$prevloc"
    if ($newloc -ne $HOME) {
        if (Test-Path $newloc) {
            Set-Location "$newloc"
            Write-Host -ForegroundColor DarkGray "`e[1AChanged directory to " -NoNewLine
            Write-Host -ForegroundColor DarkBlue (Get-Location).Path
            Write-Host
        } else {
            Write-Host -ForegroundColor Red "`e[1AAttempted to navigate to " -NoNewLine
            Write-Host -ForegroundColor Blue $newloc -NoNewLine
            Write-Host -ForegroundColor Red " but it no longer exists now."
            Write-Host
        }
    }
}
# check for venv and deactivate
if (Get-Command -Name "deactivate" -CommandType Function -ErrorAction SilentlyContinue) {
    deactivate
}
