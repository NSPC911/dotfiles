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

    Write-Output "`e[0J`e[HSetting up uv completions"
    $completions += uv generate-shell-completion powershell

    Write-Output "`e[0J`e[HSetting up gh completions"
    $completions += gh completion -s powershell

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
    Start-Process pwsh -Verb RunAs -ArgumentList "-Command regenCache" -WindowStyle Hidden
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
    if ($null -ne (bat "./pyproject.toml" | ConvertFrom-Toml).tool.poetry) {
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
            Write-Host "poetry self sync" -ForegroundColor Yellow
            poetry self sync *>$null
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
                Write-Host "./venv/bin/Activate.ps1" -ForegroundColor Yellow
                ./venv/bin/Activate.ps1
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
                Write-Host "./.venv/bin/Activate.ps1" -ForegroundColor Yellow
                ./.venv/bin/Activate.ps1
            }
        }
        Write-Host "Virtual Environment is active!" -ForegroundColor Green -NoNewLine
        $pyVersion = uv run --no-sync python --version
        Write-Host " ($pyVersion)" -ForegroundColor Cyan
        if ((-not $NoSync)) {
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
                    Write-Host "uv sync --active $flags" -ForegroundColor Yellow
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
            $packages = (uv pip list --format json | jq .[].name).Split("`n").Length
            Write-Host " ($packages packages installed)" -ForegroundColor Cyan
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
    while ($true) { Invoke-Expression "$args" }
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
Remove-PSReadLineKeyHandler -Key "F2"
Set-PSReadLineOption -BellStyle None
# carapace stuff idk
Set-PSReadLineOption -Colors @{
    ListPredictionSelected = "`e[7m"
    Selection = "`e[7m"
}
# fuzzy: https://github.com/kelleyma49/PSFzf
Write-Output "`e[u`e[0KPsFzf"
Set-PSReadLineKeyHandler -Chord "Shift+Tab" -ScriptBlock { Invoke-FzfTabCompletion }
Set-PsFzfOption -EnableAliasFuzzySetEverything
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
        [Parameter()][switch]$ask
    )
    # I know `chezmoi re-add` is a thing, but this
    # looks nicer + I know what was changed
    chezmoi status | ForEach-Object {
        $path = "~/$(($_.Split(" ")[-1]))"
        Write-Output "  $path"
        if ($ask) {
            Write-Host "   Add to chezmoi? (Y/N)" -NoNewLine -ForegroundColor Yellow
            if ([System.Console]::ReadKey($true).Key -ne "Y") {
                Write-Host "`e[2K`e[1F- $path" -ForegroundColor Yellow
                return
            } else {
                # cleanup
                Write-Host "`e[2K`e[1F"
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
            return (Get-ChildItem | Select-Object -ExpandProperty Name | Join-String -Separator "`n" -OutputPrefix "../`n" | Invoke-Fzf -Preview 'dir /B {}')
        }
        while ($true) {
            $fzout = setter
            if ($null -eq $fzout) {
                return
            } elseif (Test-Path $fzout -PathType Container) {
                Set-Location ($fzout)
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
        if ($extra -eq $null) {
            $extra = ""
        }
        Invoke-PsFzfRipgrep $extra
    } else {
        Write-Error "Unknown operation $type. Allowed: edit, status, history/his/h, kill/nuke, checkout/switch/branch, scoop/install, cd, rg, fd"
    }
}

##### gh copilot cli but local #####
$ollamaSuggesterModel = "codegemma:7b"
$opencodeSuggesterModel = "mistral/codestral-latest"
$ollamaExplainerModel = "codegemma:2b"
$opencodeExplainerModel = "github-copilot/gpt-5.1-codex-mini"
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

    $output = Invoke-SpectreCommandWithStatus -Spinner "Arrow3" -Title "[cyan]Thinking...[/]" -ScriptBlock {
        $result = opencode run --model $opencodeSuggesterModel "$prompt" 2>$null
        if ($LASTEXITCODE -ne 0) {
            $result = ollama run $ollamaSuggesterModel $prompt
        }
        return $result
    }
    $command = ($output | Out-String).Trim()
    Write-Host "`e[1G╭─ Suggested command:"
    Write-Host "│"
    Write-Host "·  " -NoNewLine
    Write-PoshHighlighted $command
    Write-Host "│"
    $options = @("Run", "Copy", "Edit", "Improve", "Quit")
    $selectedIndex = 0

    do {
        # claude sonnet helped do this part, pretty cool imo
        Write-Host "╰❯ " -NoNewLine
        for ($i = 0; $i -lt $options.Count; $i++) {
            if ($i -eq $selectedIndex) { Write-Host " [$($options[$i][0])]$($options[$i].Substring(1)) " -ForegroundColor Black -BackgroundColor Cyan -NoNewLine }
            else { Write-Host " [$($options[$i][0])]$($options[$i].Substring(1)) " -NoNewLine }
        }
        Write-Host "`e[?25l`n"
        $key = [System.Console]::ReadKey($true)
        Write-Host "`e[2F`e[2K" -NoNewLine
        $shouldExecute = $false
        if ($null -ne $key.modifiers) {
            switch ($key.key) {
                # Left arrow
                "LeftArrow3" { $selectedIndex = ($selectedIndex - 1 + $options.Count) % $options.Count }
                # Right arrow
                "RightArrow3" { $selectedIndex = ($selectedIndex + 1) % $options.Count }
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
                    Write-Host " [$($options[$i][0])]$($options[$i].Substring(1)) " -ForegroundColor Black -BackgroundColor Cyan -NoNewLine
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
                    Write-PoshHighlighted "$command`n"
                    Invoke-Expression "$command"
                    Write-Host ""
                    return
                }
                1 {
                    Write-Host "·  $(Write-PoshHighlighted 'Set-Clipboard `"$command`"')"
                    Set-Clipboard "$command"
                    Write-Host "│"
                    Write-Host "╰─ Command copied to clipboard!" -ForegroundColor Green
                    Write-Host ""
                    return
                }
                2 {
                    Write-Host "·  $(Write-PoshHighlighted '$editThis = New-TemporaryFile')"
                    $editThis = New-TemporaryFile
                    Write-Host "·  $(Write-PoshHighlighted '$editThis = Rename-Item -Path $editThis.FullName -NewName ($editThis.BaseName + ".ps1") -PassThru')"
                    $editThis = Rename-Item -Path $editThis.FullName -NewName ($editThis.BaseName + ".ps1") -PassThru
                    Write-Host "·  $(Write-PoshHighlighted '$command | Out-File $editThis')"
                    "$command" | Out-File $editThis
                    Write-Host "·  $(Write-PoshHighlighted '& $env:EDITOR $editThis')"
                    & $env:EDITOR $editThis
                    Write-Host "·  $(Write-PoshHighlighted '$command = (Get-Content $editThis)')"
                    $command = (Get-Content $editThis)
                    Write-Host "·  $(Write-PoshHighlighted 'Remove-Item $editThis -ErrorAction SilentlyContinue -Force')"
                    Remove-Item $editThis -ErrorAction SilentlyContinue -Force
                    Write-Host "│"
                    Write-Host "├─ Modified command:"
                    Write-Host "│"
                    Write-Host "·  $(Write-PoshHighlighted $command)"
                    Write-Host "│"
                }
                3 {
                    Write-Host "├─ How should the command be improved?"
                    Write-Host "╰─❯ " -NoNewLine
                    $improvement = Read-Host
                    Write-Host "`e[2F├─ How should the command be improved?" -ForegroundColor Green
                    Write-Host "╰── $improvement  " -ForegroundColor Green
                    $improvePrompt = "Improve this PowerShell command`n$command`nUser wants:`n'$improvement'`nRespond with ONLY the improved command as plain text, no formatting or code blocks. This is a Windows environment with pwsh as the active shell."
                    $output = Invoke-SpectreCommandWithStatus -Spinner "Arrow3" -Title "[cyan]Improving...[/]" -ScriptBlock {
                        $result = opencode run --model $opencodeSuggesterModel "$improvePrompt" 2>$null
                        if ($LASTEXITCODE -ne 0) {
                            $result = ollama run $ollamaSuggesterModel $improvePrompt
                        }
                        return $result
                    }
                    $command = ($output | Out-String).Trim()
                    Write-Host "`e[1G╭─ Improved command:"
                    Write-Host "│"
                    Write-Host "·  " -NoNewLine
                    Write-PoshHighlighted $command
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
    $prompt = "Explain this PowerShell command: '$Command'. Include what it does, any parameters, and provide examples if helpful. Be concise. Format your response using Markdown (but do not wrap it in the markdown codeblock)"

    $result = Invoke-SpectreCommandWithStatus -Spinner "Arrow3" -Title "[cyan]Thinking...[/]" -ScriptBlock {
        $out = opencode run --model $opencodeExplainerModel "$prompt" 2>$null
        if ($LASTEXITCODE -eq 0) {
            return @{ output = $out; model = $opencodeExplainerModel }
        } else {
            $out = ollama run $ollamaExplainerModel $prompt
            return @{ output = $out; model = $ollamaExplainerModel }
        }
    }
    $output = ($result.output | Out-String).Trim()
    $model = $result.model
    $maxWidth = [int]($Host.UI.RawUI.WindowSize.Width - 8)
    $output | rich --markdown --panel rounded --expand --guides --hyperlinks --caption "Using [cyan]$model[/]" --width $maxWidth --center -
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


##### something is wrong with my wifi #####
function Reset-WiFi {
    cmd /c "" "netsh interface set interface `"Wi-Fi`" admin=disable"
    Start-Sleep -Seconds 5
    cmd /c "" "netsh interface set interface `"Wi-Fi`" admin=enable"
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
