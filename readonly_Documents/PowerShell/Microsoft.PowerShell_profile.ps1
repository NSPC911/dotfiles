Set-Location $HOME
$CACHE = "$PROFILE/../cache"
if (-not (Test-Path $CACHE)) {
    New-Item -ItemType Directory -Path $CACHE | Out-Null
}
##### Cache Completions #####
$cacheCompletionLocation = "$cache/completion-cache.ps1"
function regenCache {
    Remove-Item $cacheCompletionLocation -ErrorAction Ignore
    New-Item -Path $cacheCompletionLocation -Force
    Clear-Host

    $completions = @()

    Write-Host "`e[HSetting up carapace `e[s" -NoNewLine
    # check existence of scoop (because im going to start using linux)
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        # setup only specific completions
        $dontwant = @("bat", "gh", "git", "rg", "rustup", "taplo", "wezterm")
        $scooplist = scoop list
        # set up things that I want, and not just everything
        $scooplist | Select-Object -ExpandProperty name | ForEach-Object {
            if ($dontwant -notcontains $_) {
                $caracomplete = carapace $_ powershell
                if ($null -ne $caracomplete) {
                    $completions += $caracomplete
                    Write-Host "`e[u`e[0K$_"
                }
            }
        }
        $include = @("file", "tar", "curl", "carapace", "cargo", "aria2c")
        $include | ForEach-Object {
            $caracomplete = carapace $_ powershell
            if ($null -ne $caracomplete) {
                $completions += $caracomplete
                Write-Host "`e[u`e[0K$_"
            }
        }
    } else {
        $completions += carapace _carapace powershell
    }

    # `e[2K to clear line
    Write-Output "`e[H`e[2KSetting up zoxide"
    $completions += zoxide init powershell

    Write-Output "`e[0J`e[HSetting up oh-my-posh"
    $completions += oh-my-posh init powershell --config $HOME/.config/kushal.omp.json

    Write-Output "`e[0J`e[HSetting up gh completions"
    $completions += gh completion -s powershell

    Write-Output "`e[0J`e[HSetting up ty completions"
    $completions += ty generate-shell-completion powershell

    Write-Output "`e[0J`e[HSetting up uv completions"
    $completions += uv generate-shell-completion powershell

    Write-Output "`e[0J`e[HSetting up uvx completions"
    $completions += uvx --generate-shell-completion powershell

    Write-Output "`e[0J`e[HSetting up gix completions"
    $completions += gix completions -s powershell

    Write-Output "`e[HSetting up pixi completions"
    $completions += pixi completion --shell powershell

    # Write-Output "`e[HSetting up tuios completions"
    # $completions += tuios completion powershell

    Write-Output "`e[0J`e[HSetting up delta completions"
    $completions += delta --generate-completion powershell

    Write-Output "`e[0J`e[HSetting up taplo completions"
    $completions += taplo completions powershell

    Write-Output "`e[0J`e[HSetting up tombi completions"
    $completions += tombi completion powershell

    Write-Output "`e[0J`e[HSetting up typst completions"
    $completions += typst completions powershell

    Write-Output "`e[0J`e[HSetting up batcat completions"
    $completions += bat --completion ps1

    Write-Output "`e[0J`e[HSetting up rustup completions"
    $completions += rustup completions powershell

    Write-Output "`e[0J`e[HSetting up chezmoi completions"
    $completions += chezmoi completion powershell

    Write-Output "`e[0J`e[HSetting up ripgrep completions"
    $completions += rg --generate complete-powershell

    Write-Output "`e[0J`e[HSetting up wezterm completions"
    $completions += wezterm shell-completion --shell power-shell

    Write-Output "`e[0J`e[HSetting up regolith completions"
    $completions += regolith completion powershell

    Write-Output "`e[0J`e[HSetting up onefetch completions"
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
    if ($IsWindows) {
        Start-Process pwsh -Verb RunAs -ArgumentList "-Command regenCache" -WindowStyle Hidden
    } else {
        regenCache
    }
} else {
    Write-Output "Using script cache..."
}

. $cacheCompletionLocation

Write-Output "`e[0J`e[HDealing with functions and aliases..."
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
        Get-Location | Select-Object -Expand Path | Out-File $prevloc
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
function global:__zoxide_zi {
    $result = __zoxide_bin query --list | Invoke-Fzf -Preview 'dir /B {}'
    if ($null -ne $result) {
        __zoxide_cd $result $true
    }
}

##### Superfile Go To Last Dir #####
function spf {
    $SPF_LAST_DIR_PATH = [Environment]::GetFolderPath("LocalApplicationData") + "/superfile/lastdir"
    $spfPath = (Get-Command spf -CommandType Application | Select-Object -ExpandProperty Source)
    & $spfPath $args
    if (Test-Path $SPF_LAST_DIR_PATH) {
        $SPF_LAST_DIR = Get-Content -Path $SPF_LAST_DIR_PATH
        Invoke-Expression $SPF_LAST_DIR
        Remove-Item -Force $SPF_LAST_DIR_PATH
    }
}

##### rovr Go To Last Dir #####
function rovr {
    $cwd_file = New-TemporaryFile
    $rovrPath = Get-Command rovr -CommandType Application -TotalCount 1 | Select-Object -ExpandProperty Source
    & $rovrPath --cwd-file $cwd_file $args
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

Set-Alias -Name "omp" -Value "oh-my-posh"

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

function imgcat {
    wezterm imgcat --resample-filter nearest --resample-format png $args
}

if (-not ($IsWindows)) {
    Set-Alias -Name "ls" -Value "Get-ChildItem"
    Set-Alias -Name "rm" -Value "Remove-Item"
    Set-Alias -Name "mv" -Value "Move-Item"
    Set-Alias -Name "cp" -Value "Copy-Item"
    Set-Alias -Name "ps" -Value "Get-Process"
    Set-Alias -Name "kill" -Value "Kill-Process"
    Set-Alias -Name "sleep" -Value "Start-Sleep"
    Set-PSReadLineKeyHandler -Chord Ctrl+LeftArrow -Function BackwardWord
    Set-PSReadLineKeyHandler -Chord Ctrl+RightArrow -Function ForwardWord
    Set-PSReadLineKeyHandler -Chord Ctrl+Delete -Function DeleteWord
    Set-PSReadLineKeyHandler -Chord Ctrl+Backspace -Function BackwardDeleteWord
}

Set-Alias -Name "cat" -Value "bat"

function Register-Completion {
    $out = carapace $args powershell
    if ($null -eq $out) {
        Write-Error "Carapace has no completion for $args"
    } else {
        $out | Out-String | Invoke-Expression
    }
}

##### bat print #####
function Write-PoshHighlighted {
    Write-Output $args | bat --force-colorization --style plain --language Powershell --paging=never
}

function Watch-OMPrompt {
    param(
        [Parameter()][string]$ConfigPath = "~/.config/kushal.omp.json"
    )
    $newTab = wezterm cli spawn -- $env:EDITOR $ConfigPath
    Start-Sleep -Milliseconds 500
    # keep in mind that omp-test folder isn't added to the dotfiles
    # you need to `uv init`, `cargo init`, `go mod init`, `pnpm init`, `bun init`, `touch test.lua`
    wezterm cli split-pane --bottom --cells 3 --pane-id $newTab --cwd "C:/Users/notso/Git/omp-test" -- pwsh -noni -nop -nol -c @"
oh-my-posh print primary --config $ConfigPath
`$lastMod = `(Get-Item $ConfigPath`).LastWriteTime
while `(`$true`) `{
    Start-Sleep -Seconds 1
    `$newLastMod = `(Get-Item $ConfigPath`).LastWriteTime
    if `(`$lastMod -ne `$newLastMod`) `{
        Clear-Host
        oh-my-posh print primary --config `"$ConfigPath`"
        `$lastMod = `$newLastMod
    `}
    # check if editor is open in other pane
    wezterm cli get-text --pane-id $newTab `*`>`$null
    if `(`$LASTEXITCODE -ne 0`) `{
        break
    `}
    # resize always to 3
    if `(`$Host.UI.RawUI.WindowSize.Height -ne 3`) `{
        wezterm cli adjust-pane-size Down --amount 100
        wezterm cli adjust-pane-size Up --amount 2
        # force redraw
        `$lastMod = `$null
    `}
`}
"@ | Out-Null
    Start-Sleep -Milliseconds 500
    wezterm cli activate-pane --pane-id $newTab
}

##### Python Venv #####
function pyvenv() {
    param(
        [Parameter()][switch]$Poetry,
        [Parameter()][switch]$AllGroups,
        [Parameter()][switch]$AllExtras,
        [Parameter()][switch]$Upgrade,
        [Parameter()][switch]$Update,
        [Parameter()][switch]$NoSync,
        [Parameter()][switch]$Offline
    )
    if ((Test-Path ".\pyproject.toml") -and ($null -ne (bat "./pyproject.toml" | ConvertFrom-Toml).tool.poetry)) {
        $Poetry = $true
    }
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
        if (-not $NoSync) {
            Write-Host "┌❯ Installing packages with 'pyproject.toml'"
            Write-Host "└─ " -NoNewLine
            $flags = ""
            if ($AllGroups) {
                $flags += "--all-groups "
            }
            if ($AllExtras) {
                $flags += "--all-extras "
            }
            $flags = $flags.Trim()
            if ($flags -eq "") {
                Write-Host "poetry install --sync" -ForegroundColor Yellow
                poetry install --sync *>$null
            } else {
                Write-Host "poetry install --sync $flags" -ForegroundColor Yellow
                poetry install --sync $flags.Split() *>$null
            }
            return
        }
        Write-Host "Virtual Environment has been synced!" -ForegroundColor Green
    } else {
        if (Test-Path "venv/") {
            Write-Host "┌❯ Using " -NoNewLine
            Write-Host "venv " -ForegroundColor Cyan
            Write-Host "├❯ Activating virtual environment"
            Write-Host "└─ " -NoNewLine
            if (Test-Path "venv/Scripts") {
                Write-Host "./venv/Scripts/Activate.ps1" -ForegroundColor Yellow
                ./venv/Scripts/Activate.ps1
            } elseif (Test-Path "venv/bin") {
                Write-Host "./venv/bin/activate.ps1" -ForegroundColor Yellow
                ./venv/bin/activate.ps1
            }
        } elseif (-not (Test-Path .venv)) {
            Write-Host "┌❯ Creating new virtual environment"
            Write-Host "└─ " -NoNewLine
            Write-Host "uv venv" -ForegroundColor Yellow
            uv venv --quiet
        }
        if (Test-Path ".venv") {
            Write-Host "┌❯ Using " -NoNewLine
            Write-Host ".venv" -ForegroundColor Cyan
            Write-Host "├❯ Activating virtual environment"
            Write-Host "└─ " -NoNewLine
            if (Test-Path ".venv/Scripts") {
                Write-Host "./.venv/Scripts/Activate.ps1" -ForegroundColor Yellow
                ./.venv/Scripts/Activate.ps1
            } elseif (Test-Path ".venv/bin") {
                Write-Host "./.venv/bin/activate.ps1" -ForegroundColor Yellow
                ./.venv/bin/activate.ps1
            }
        }
        Write-Host "Virtual Environment is active!" -ForegroundColor Green -NoNewLine
        $pyVersion = uv run --no-sync python --version 2>$null
        Write-Host " ($pyVersion)" -ForegroundColor Cyan
        if (-not $NoSync) {
            if (Test-Path pyproject.toml) {
                Write-Host "┌❯ Syncing packages with 'pyproject.toml'"
                Write-Host "└─ " -NoNewLine
                $flags = ""
                if ($AllGroups) {
                    $flags += "--all-groups "
                }
                if ($AllExtras) {
                    $flags += "--all-extras "
                }
                if ($Update -or $Upgrade) {
                    $flags += "--upgrade "
                }
                if ($Offline) {
                    $flags += "--offline"
                }
                $flags = $flags.Trim()
                if ($flags -eq "") {
                    Write-Host "uv sync --active" -ForegroundColor Yellow
                    uv sync --active *>$null
                } else {
                    Write-Host "uv sync --active $flags" -ForegroundColor Yellow
                    uv sync --active $flags.Split() *>$null
                }
            } elseif (Test-Path requirements.txt) {
                Write-Host "┌❯ Syncing packages with 'requirements.txt'"
                Write-Host "└─ " -NoNewLine
                Write-Host "uv pip sync requirements.txt" -ForegroundColor Yellow
                uv pip sync requirements.txt *>$null
            } else {
                Write-Host "┌❯ There are no packages available to be synced"
                Write-Host "└❯ Make sure to either " -NoNewLine
                Write-Host "uv init --bare" -ForegroundColor Cyan -NoNewLine
                Write-Host " or " -NoNewLine
                Write-Host "touch requirements.txt" -ForegroundColor Cyan -NoNewLine
                Write-Host "!"
            }
            Write-Host "Virtual Environment has been synced!" -ForegroundColor Green -NoNewLine
            $packagesJson = (uv pip list --format json)
            if ($packagesJson -eq "[]") {
                Write-Host " (0 packages installed)" -ForegroundColor Cyan
            } else {
                $packages = ($packagesJson | jq .[].name).Split("`n").Length
                Write-Host " ($packages packages installed)" -ForegroundColor Cyan
            }
        }
    }
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
    Get-Content (Get-PSReadlineOption).HistorySavePath | Where-Object {$_ -like "*$find*"} | Get-Unique
}

##### run something foreva!! #####
function forever {
    while ($true) { $args | Invoke-Expression }
}

##### PS Plugins #####
Write-Host "`e[0J`e[0J`e[HAdding Plugins `e[s" -NoNewLine

# https://github.com/devblackops/Terminal-Icons
Write-Output "`e[u`e[0KTerminal-Icons"
Import-Module -Name Terminal-Icons

# should be available if you installed scoop
if (Get-Command scoop -ErrorAction SilentlyContinue) {
    Write-Output "`e[u`e[0KScoop Completions"
    Import-Module "$($(Get-Item $(Get-Command scoop.ps1).Path).Directory.Parent.FullName)/modules/scoop-completion"
}

# https://github.com/PowerShell/PSReadLine
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Chord Ctrl+Enter -Function SwitchPredictionView
if ($IsWindows) {
    Remove-PSReadLineKeyHandler -Key "F2"
}
Set-PSReadLineOption -BellStyle None
# carapace stuff idk
Set-PSReadLineOption -Colors @{
    ListPredictionSelected = "`e[7m"
    Selection = "`e[7m"
    Parameter = "`e[38;5;245m"
    Operator = "`e[38;5;245m"
}
# fuzzy: https://github.com/kelleyma49/PSFzf
Write-Output "`e[u`e[0KPsFzf"
Set-PSReadLineKeyHandler -Chord "Shift+Tab" -ScriptBlock { Invoke-FzfTabCompletion }
Set-PsFzfOption -EnableAliasFuzzySetEverything
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
# git completions https://github.com/kzrnm/git-completion-pwsh
Write-Output "`e[u`e[0KGit Completions"
Import-Module -Name git-completion
# spectre.console https://github.com/ShaunLawrie/PwshSpectreConsole
Write-Output "`e[u`e[0KPwshSpectreConsole"
$OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

##### chezmoi #####
function chezcd {
    __zoxide_cd (chezmoi source-path)
    if ($IsWindows) {
        chezmoi status
    }
}
function chezedit { chezmoi edit --apply $args }
function chezadd { chezmoi add $args }
function chezgit { chezmoi git $args }
function chezsync {
    param(
        [Parameter()][switch]$noAsk
    )
    # I know `chezmoi re-add` is a thing, but this
    # looks nicer + I know what was changed
    chezmoi status | ForEach-Object {
        $path = "~/$(($_.Split(" ")[-1]))"
        Write-Output "  $path"
        # refactor this to continue asking if nothing reasonable is pressed, or d is pressed
        if ($false -eq $noAsk) {
            $hasPrompted = $false
            while ($true) {
                if (-not $hasPrompted) {
                    Write-Host "  Add to chezmoi? (Y/N/D) " -NoNewLine -ForegroundColor Yellow
                    $hasPrompted = $true
                }
                $key = [System.Console]::ReadKey($true).Key
                if (($key -eq "n") -or ($key -eq "q")) {
                    Write-Host "`e[2K`e[1F- $path" -ForegroundColor Yellow
                    return
                } elseif ($key -eq "y") {
                    # cleanup
                    Write-Host "`e[2K`e[1F"
                    break
                } elseif ($key -eq "d") {
                    chezmoi diff "$path"
                    continue
                } else {
                    # Invalid input, prompt again
                    continue
                }
            }
        }
        chezmoi add "$path" *>$null
        if ($LASTEXITCODE -eq 0) { Write-Host "`e[1F+ $path" -ForegroundColor Green }
        else { Write-Host "`e[1F! $path" -ForegroundColor Red }
    }
    Write-Host "`e[2K`e[1F"
}

##### fzf plugin (needs that one powershell plugin) #####
function fz {
    param(
        [ValidateSet(
            "edit",
            "status",
            "history", "his", "h",
            "kill", "nuke",
            "checkout", "switch", "branch",
            "stash",
            "scoop", "install",
            "cd",
            "rg", "fd"
        )]
        [string]$type,
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$extra
    )
    if ($type -eq "edit") {
        $file = Invoke-Fzf
        if ($null -ne $file) {
            hx $file
        }
    } elseif ($type -eq "status") {
        Invoke-FuzzyGitStatus
    } elseif ($type -eq "stash") {
        Invoke-PSFzfGitStashes
    } elseif (($type -eq "history") -or ($type -eq "his") -or ($type -eq "h")) {
        Invoke-FuzzyHistory
    } elseif (($type -eq "kill") -or ($type -eq "nuke")) {
        Invoke-FuzzyKillProcess
    } elseif (($type -eq "scoop") -or ($type -eq "install")) {
        if (Get-Command scoop -ErrorAction SilentlyContinue) {
            Invoke-FuzzyScoop
        } else {
            Write-Error "Scoop is not installed on this system."
        }
    } elseif ($type -eq "cd") {
        function script:setter {
            return (Get-ChildItem | Select-Object -ExpandProperty Name | Join-String -Separator "`n" -OutputPrefix "../`n" | Invoke-Fzf -Preview 'ls {} | select -expand name' -Header $PWD.Path -Cycle)
        }
        while ($true) {
            $fzout = setter
            if ($null -eq $fzout) {
                return
            } elseif (Test-Path $fzout -PathType Container) {
                Set-Location ($fzout)
            } elseif (Test-Path $fzout -PathType Leaf) {
                hx $fzout
            } else {
                return
            }
        }
    } elseif (($type -eq "switch") -or ($type -eq "checkout") -or ($type -eq "branch")) {
        $branch = Invoke-PsFzfGitBranches
        if ($null -ne $branch) {
            git checkout $branch
        }
    } elseif (($type -eq "rg") -or ($type -eq "fd")) {
        if ($null -eq $extra) {
            $extra = ""
        }
        Invoke-PsFzfRipgrep $extra
    } else {
        Write-Error "Unknown operation $type. Allowed: edit, status, history/his/h, kill/nuke, checkout/switch/branch, scoop/install, cd, rg, fd"
    }
}

. "$PROFILE/../suggest-and-explain.ps1"

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


##### something is wrong with my wifi #####
function Reset-WiFi {
    cmd /c "" "netsh interface set interface `"Wi-Fi`" admin=disable"
    Start-Sleep -Seconds 5
    cmd /c "" "netsh interface set interface `"Wi-Fi`" admin=enable"
}


##### ghet from gh #####
. "$PROFILE/../ghet.ps1"

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
    gitfetch --graph-only --custom-box 
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
        } else {
            Write-Host -ForegroundColor Red "`e[1AAttempted to navigate to " -NoNewLine
            Write-Host -ForegroundColor Blue $newloc -NoNewLine
            Write-Host -ForegroundColor Red " but it no longer exists now."
        }
    }
}
# check for venv and deactivate
if (Get-Command -Name "deactivate" -CommandType Function -ErrorAction SilentlyContinue) {
    deactivate
}
