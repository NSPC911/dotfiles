cd $HOME
##### Cache Completions #####
$shouldGenerate = $false
$cacheCompletionLocation = "$PROFILE/../completion-cache.ps1"
if (-not (Test-Path $cacheCompletionLocation) -or (Get-Item $cacheCompletionLocation).LastWriteTime -lt (Get-Date).AddDays(-3)) {
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
function global:__zoxide_cd($dir, $literal) {
    $dir = if ($literal) {
        Set-Location -LiteralPath $dir -Passthru -ErrorAction Stop
        zoxide add .
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

    & $spf_location $args
    if (Test-Path $SPF_LAST_DIR_PATH) {
        $SPF_LAST_DIR = Get-Content -Path $SPF_LAST_DIR_PATH
        Invoke-Expression $SPF_LAST_DIR
        Remove-Item -Force $SPF_LAST_DIR_PATH
    }
}

##### rovr Go To Last Dir #####
function rovr {
    & rovr.exe $args
    $cd_path_file = "$env:LOCALAPPDATA/rovr/rovr_quit_cd_path"
    if (Test-Path $cd_path_file) {
        Set-Location -Path (Get-Content $cd_path_file)
        Remove-Item $cd_path_file
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
    New-Item -ItemType SymbolicLink -Path "$ItemToSymlinkTo" -Target "$ItemToSymlinkFrom"
}

function Get-Folder-Size {
    Get-ChildItem -Recurse | Measure-Object -Property Length -Sum | Select-Object @{Name="Size(GB)";Expression={[math]::round($_.Sum/1GB,2)}}
}

function touch {
    New-Item -ItemType File -Force -Path $args
}

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
    $figlets = pyfiglet.exe --list_fonts | Out-String -Stream
    Write-Host "Obtained " -NoNewLine
    Write-Host $figlets.count -ForegroundColor Cyan -NoNewLine
    Write-Host " figlet styles!"
    $figlets | ForEach-Object { Write-Output $_; pyfiglet -f $_ $name -w $Host.UI.RawUI.WindowSize.Width }
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

##### stupid other aliases #####
Set-Alias -Name "wo" -Value "Write-Output"

##### chezmoi #####
function chez-cd {
    __zoxide_cd (chezmoi source-path)
}

##### Other stuff #####
Clear-Host
fastfetch
