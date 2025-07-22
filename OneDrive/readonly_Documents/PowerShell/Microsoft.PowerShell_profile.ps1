cd $HOME
##### Cache Completions #####
$shouldGenerate = $false
$cacheCompletionLocation = "$PROFILE/../completion-cache.ps1"
if (-not (Test-Path $cacheCompletionLocation)) {
    New-Item -Path $cacheCompletionLocation -Force
    $shouldGenerate = $true
} elseif ((Get-Item $cacheCompletionLocation).LastWriteTime -lt (Get-Date).AddDays(-3)) {
    $shouldGenerate = $true
}

if ($shouldGenerate) {
    Remove-Item $cacheCompletionLocation
    New-Item -Path $cacheCompletionLocation -Force

    $completions = @()

    Write-Output "`e[HSetting up oh-my-posh"
    $completions += oh-my-posh init powershell --config $HOME\.config\kushal.omp.json

    Write-Output "`e[HSetting up zoxide    "
    $completions += zoxide init powershell --no-cmd

    Write-Output "`e[HSetting up uv completions"
    $completions += uv generate-shell-completion powershell

    Write-Output "`e[HSetting up gh completions"
    $completions += gh completion -s powershell
    $completions += gh copilot alias -- pwsh

    Write-Output "`e[HSetting up batcat completions  "
    $completions += bat --completion ps1

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
}

. $cacheCompletionLocation

## zoxide cant add them for some reason /shrug
Set-Alias -Option AllScope -Name "cd" -Value "__zoxide_z"
Set-Alias -Option AllScope -Name "cdi" -Value "__zoxide_zi"
Set-Alias -Option AllScope -Name "cdb" -Value "__zoxide_bin"
function zd {
    Write-Output "Did you mean cd?"
}

##### Completions #####
##### cool zoxide + onefetch #####
# waste of time
# function zoxide_with_onefetch {
# 	param (
#         [string[]]$Params
#     )
# 	__zoxide_z @Params

# 	if (Test-Path ".git") {
# 		onefetch --no-color-palette --nerd-fonts
# 	}
# }

##### Superfile Go To Last Dir #####
Write-Output "`e[HDealing with functions and aliases..."
function spf {
    param ( [string[]]$Params )
    $spf_location = "C:\Users\notso\scoop\shims\spf.exe"
    $SPF_LAST_DIR_PATH = [Environment]::GetFolderPath("LocalApplicationData") + "\superfile\lastdir"

    & $spf_location @Params
    if (Test-Path $SPF_LAST_DIR_PATH) {
        $SPF_LAST_DIR = Get-Content -Path $SPF_LAST_DIR_PATH
        Invoke-Expression $SPF_LAST_DIR
        Remove-Item -Force $SPF_LAST_DIR_PATH
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

function Search-For-String {
    param(
        [Parameter(Position = 0)]
        [string]$ItemToSearchFor,

        [Parameter(ValueFromRemainingArguments)]
        [string[]]$AdditionalArgs
    )
    Invoke-Expression "rg --ignore-case --pretty --context-separator=... `"$ItemToSearchFor`" $AdditionalArgs"
}
Set-Alias -Name searchfor -Value Search-For-String

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

##### better fzf #####
function fzf {
    param(
        [Parameter(Position = 0)]
        [string]$SearchQuery,

        [Parameter(ValueFromRemainingArguments)]
        [string[]]$AdditionalArgs
    )

    $fzfArgs = @()
    if ($SearchQuery) {
        $fzfArgs += "-q"
        $fzfArgs += "$SearchQuery"
    }
    if ($AdditionalArgs) { $fzfArgs += $AdditionalArgs }

    if ($fzfArgs.Count -gt 0) { & fzf.exe --border rounded --multi --separator "-" --input-border "rounded" --preview "bat --color always --number --theme Nord {}" --color "dark" --preview-border "rounded" $fzfArgs }
    else { & fzf.exe --border rounded --multi --separator "-" --input-border "rounded" --preview "bat --color always --number --theme Nord {}" --color "dark" --preview-border "rounded" }
}


##### Python Venv #####
function pyvenv() {
    if (Test-Path .venv\Scripts) {
        Write-Output "Using .venv"
        Write-Output "Activating virtual environment"
        .\.venv\Scripts\Activate.ps1
    } elseif (-not (Test-Path venv)) {
        Write-Output "Creating new virtual environment"
        uv venv venv
    }
    if (Test-Path venv\Scripts) {
        Write-Output "Activating virtual environment"
        .\venv\Scripts\Activate.ps1
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

##### better than to search for nothing in the tasklist.exe #####
function taskfind { Invoke-Expression "tasklist.exe | Out-String | rg $args --ignore-case" }

##### better sudo (not really) #####
function sd { Start-Process pwsh -Verb RunAs -ArgumentList "-Command cd '$pwd'; Clear-Host ; $args ; Read-Host 'Exit Now?'" }

#### LazyGit #####
Set-Alias -Name "lz" -Value "lazygit"

##### tabb #####
Write-Output "`e[HAdding Tab Autocomplete...               "
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete

##### Give me my full history man #####
function Get-FullHistory {
    Get-Content (Get-PSReadlineOption).HistorySavePath | ? {$_ -like "*$find*"} | Get-Unique
}

##### Other stuff #####
Clear-Host
fastfetch
