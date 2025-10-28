Set-Location $HOME
##### Cache Completions #####
$shouldGenerate = $false
$cacheCompletionLocation = "$PROFILE/../completion-cache.ps1"
if (-not (Test-Path $cacheCompletionLocation) -or (Get-Item $cacheCompletionLocation).LastWriteTime -lt (Get-Date).AddDays(-1)) {
    $shouldGenerate = $true
}

if ($shouldGenerate) {
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
    $completions += gh copilot alias -- pwsh

    Write-Output "`e[HSetting up tuios completions"
    $completions += tuios completion powershell

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

    Write-Output "`e[HSetting up regolith completions"
    $completions += regolith completion powershell

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
    $cwd_file = [System.IO.Path]::GetTempFileName()
    & rovr.exe --cwd-file $cwd_file $args
    if (Test-Path $cwd_file) {
        Set-Location -Path (Get-Content $cwd_file)
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
    New-Item -ItemType SymbolicLink -Path $ItemToSymlinkTo -Target (Resolve-Path $ItemToSymlinkFrom | Select -Expand Path)
}

function Get-Folder-Size {
    Get-ChildItem -Recurse | Measure-Object -Property Length -Sum | Select-Object @{Name="Size(GB)";Expression={[math]::round($_.Sum/1GB,2)}}
}

function touch {
    New-Item -ItemType File -Force -Path $args
}

Set-Alias -Name extract -Value Expand-Archive

##### better fzf #####
function fzf {
    & fzf.exe --border rounded --multi --separator "-" --input-border "rounded" --preview "bat --color always --number --theme Nord {}" --color "dark" --preview-border "rounded" $args
}


##### Python Venv #####
function pyvenv() {
    if (Test-Path venv\Scripts) {
        Write-Output "Using venv"
        Write-Output "Activating virtual environment"
        .\venv\Scripts\Activate.ps1
    } elseif (-not (Test-Path .venv)) {
        Write-Output "Creating new virtual environment"
        uv venv
    }
    if (Test-Path .venv\Scripts) {
        Write-Output "Activating virtual environment"
        .\.venv\Scripts\Activate.ps1
    }
    Write-Output "Virtual Environment is active!"
    if (Test-Path pyproject.toml) {
        Write-Output "Installing packages with 'pyproject.toml'"
        uv sync --active
    } elseif (Test-Path requirements.txt) {
        Write-Output "Installing packages with 'requirements.txt'"
        uv pip install -r requirements.txt
    } else {
        Write-Output "Creating a new requirements.txt"
        touch requirements.txt
    }
    Write-Output "Virtual Environment has been synced!"
}

##### Pretty Print 'Invoke-Webrequest's #####
function curlout {
    param(
        [Parameter(Position = 0)]
        [string]$Url,

        [Parameter(Position = 1)]
        [string]$Lang
    )
    Invoke-Expression "Invoke-WebRequest $Url | Select-Object -ExpandProperty Content | bat -l $Lang"
}

##### Convert SVG to other image files #####
function svg2 {
    param([string]$InputFile, [string]$OutputFile)
    resvg --monospace-family "CaskaydiaCove NFM" --font-family "CaskaydiaCove NFM" --shape-rendering crispEdges --serif-family "CaskaydiaCove NFM" --dpi 4000 $InputFile $OutputFile
}

##### better than to search for nothing in the tasklist.exe #####
function taskfind { Invoke-Expression "tasklist.exe | Out-String | rg $args --ignore-case" }

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

##### pwd ish #####
function cwd {
    Get-Location | Select -Expand Path
}

#### LazyGit #####
Set-Alias -Name "lz" -Value "lazygit"

##### Give me my full history man #####
function Get-FullHistory {
    Get-Content (Get-PSReadlineOption).HistorySavePath | ? {$_ -like "*$find*"} | Get-Unique
}

##### PS Plugins #####
Write-Output "`e[HAdding Plugins...                        "
Import-Module -Name Terminal-Icons
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete

##### Scoop #####
function scoop-find {
    param (
        [string]$query
    )
    cd ~/scoop/buckets/
    fd --type f | rg $query | rg ".json" | ForEach-Object {
        scoop info $_
    }
}

##### chezmoi #####
function chezcd { __zoxide_cd (chezmoi source-path) }
function chezedit { chezmoi edit --apply $args }
function chezadd { chezmoi add $args }
function chezgit { chezmoi git $args }

##### fzf plugin (needs that one powershell plugin) #####
function fuzzy {
    param(
        [ValidateSet("edit", "git", "status", "kill", "nuke", "scoop", "install")]
        [string]$type,
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$extra
    )
    if ($type -eq "edit") {
        hx (fzf)
    } elseif ($type -eq "status") {
        Invoke-FuzzyGitStatus
    } elseif (($type -eq "history") -or ($type -eq "git")) {
        Invoke-FuzzyHistory
    } elseif (($type -eq "kill") -or ($type -eq "nuke")) {
        Invoke-FuzzyKillProcess
    } elseif (($type -eq "scoop") -or ($type -eq "install")) {
        Invoke-FuzzyScoop
    } else {
        Write-Error "Unknown operation $type. Allowed: edit, status, history, kill/nuke or scoop/install"
    }
}


##### Other stuff #####
Clear-Host
function fetch {
    gitfetch --graph-only
    Write-Host "`e[1A"
    fastfetch
}
fetch
if (Test-Path $prevloc) {
    $newloc = Get-Content $prevloc
    if ($newloc -ne $HOME) {
        Set-Location $newloc
        Write-Host -ForegroundColor DarkGray "`e[1AChanged directory to " -NoNewLine
        Write-Host -ForegroundColor DarkBlue (Get-Location | Select -Expand Path)
        Write-Host
    }
}

