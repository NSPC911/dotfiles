##### posh setup #####
oh-my-posh init powershell --config $env:USERPROFILE\.config\kushal.omp.json | Out-String | Invoke-Expression

##### Completions #####
uv generate-shell-completion powershell | Out-String | Invoke-Expression
regolith completion powershell | Out-String | Invoke-Expression
zoxide init powershell --cmd zd | Out-String | Invoke-Expression
onefetch --generate powershell | Out-String | Invoke-Expression

##### Superfile Go To Last Dir #####
function spf {
    param (
        [string[]]$Params
    )
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
    Invoke-Expression "rg --ignore-case --pretty --context-separator=... `"$ItemToSearchFor`" $AdditionalArgs"}
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
        $fzfArgs += "`"$SearchQuery`""
    }
    if ($AdditionalArgs) {
        $fzfArgs += $AdditionalArgs
    }
    
    if ($fzfArgs.Count -gt 0) {
        & fzf.exe $fzfArgs
    } else {
        & fzf.exe
    }
}


##### Python Venv #####
function goto {
    param(
        [Parameter(Position = 0)]
        [string]$NewDir
    )
    $cdArgs = ""
    if ($NewDir) {
        $cdArgs += "$NewDir"
    }
    & Set-Location $cdArgs
    if (Test-Path ".\venv\Scripts\Activate.ps1") {
       .\venv\Scripts\Activate.ps1
    }
    if (Test-Path ".\.venv\Scripts\Activate.ps1") {
        .\venv\Scripts\Activate.ps1
    }
}
function pyvenv() {
    if (Test-Path .venv) {
        echo "Using .venv"
        echo "Activating virtual environment"
        .\.venv\Scripts\Activate.ps1
    } elseif (-not (Test-Path venv)) {
        echo "Creating new virtual environment"
        uv venv venv
    }
    if (Test-Path venv) {
        echo "Activating virtual environment"
        .\venv\Scripts\Activate.ps1
    }
    if (Test-Path pyproject.toml) {
        echo "Installing packages with 'pyproject.toml'"
        uv sync --active
    } elseif (Test-Path requirements.txt) {
        echo "Installing packages with 'requirements.txt'"
        uv pip install -r requirements.txt
    } else {
        echo "Creating a new requirements.txt"
        touch requirements.txt
    }
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
function taskfind {
    Invoke-Expression "tasklist.exe | Out-String | rg $args --ignore-case"
}

##### better sudo (not really) #####
function sd { Start-Process powershell -Verb RunAs -ArgumentList "-Command cd '$pwd'; Clear-Host ; $args ; Write-Output 'This window will close in 5 seconds' ; Start-Sleep -Seconds 1" }

##### ffmpeg extract one #####
function extractFrame {
    ffmpeg -i "$args" -vf "select=eq(n\,0)" -update 1 -frames:v 1 -q:v 3 output.jpg
}

##### Other stuff #####
fastfetch
