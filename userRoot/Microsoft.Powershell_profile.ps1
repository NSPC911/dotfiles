##### posh setup #####
oh-my-posh init powershell --config $HOME\.config\kushal.omp.json | Out-String | Invoke-Expression

##### Completions #####
uv generate-shell-completion powershell | Out-String | Invoke-Expression
regolith completion powershell | Out-String | Invoke-Expression
zoxide init powershell --cmd zd | Out-String | Invoke-Expression
onefetch --generate powershell | Out-String | Invoke-Expression

##### Copilot really is built different bruh ####
function ghcs {
	# Debug support provided by common PowerShell function parameters, which is natively aliased as -d or -db
	# https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_commonparameters?view=powershell-7.4#-debug
	param(
		[Parameter()]
		[string]$Hostname,

		[ValidateSet('gh', 'git', 'shell')]
		[Alias('t')]
		[String]$Target = 'shell',

		[Parameter(Position=0, ValueFromRemainingArguments)]
		[string]$Prompt
	)
	begin {
		# Create temporary file to store potential command user wants to execute when exiting
		$executeCommandFile = New-TemporaryFile

		# Store original value of GH_* environment variable
		$envGhDebug = $Env:GH_DEBUG
		$envGhHost = $Env:GH_HOST
	}
	process {
		if ($PSBoundParameters['Debug']) {
			$Env:GH_DEBUG = 'api'
		}

		$Env:GH_HOST = $Hostname

		gh copilot suggest -t $Target -s "$executeCommandFile" $Prompt
	}
	end {
		# Execute command contained within temporary file if it is not empty
		if ($executeCommandFile.Length -gt 0) {
			# Extract command to execute from temporary file
			$executeCommand = (Get-Content -Path $executeCommandFile -Raw).Trim()

			# Insert command into PowerShell up/down arrow key history
			[Microsoft.PowerShell.PSConsoleReadLine]::AddToHistory($executeCommand)

			# Insert command into PowerShell history
			$now = Get-Date
			$executeCommandHistoryItem = [PSCustomObject]@{
				CommandLine = $executeCommand
				ExecutionStatus = [Management.Automation.Runspaces.PipelineState]::NotStarted
				StartExecutionTime = $now
				EndExecutionTime = $now.AddSeconds(1)
			}
			Add-History -InputObject $executeCommandHistoryItem

			# Execute command
			Write-Host "`n"
			Invoke-Expression $executeCommand
		}

		# Clean up temporary file used to store potential command user wants to execute when exiting
		Remove-Item -Path $executeCommandFile

		# Restore GH_* environment variables to their original value
		$Env:GH_DEBUG = $envGhDebug
	}
}

function ghce {
	# Debug support provided by common PowerShell function parameters, which is natively aliased as -d or -db
	# https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_commonparameters?view=powershell-7.4#-debug
	param(
		[Parameter()]
		[string]$Hostname,

		[Parameter(Position=0, ValueFromRemainingArguments)]
		[string[]]$Prompt
	)
	begin {
		# Store original value of GH_* environment variables
		$envGhDebug = $Env:GH_DEBUG
		$envGhHost = $Env:GH_HOST
	}
	process {
		if ($PSBoundParameters['Debug']) {
			$Env:GH_DEBUG = 'api'
		}

		$Env:GH_HOST = $Hostname

		gh copilot explain $Prompt
	}
	end {
		# Restore GH_* environment variables to their original value
		$Env:GH_DEBUG = $envGhDebug
		$Env:GH_HOST = $envGhHost
	}
}

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
function pyvenv() {
    if (Test-Path .venv\Scripts) {
        echo "Using .venv"
        echo "Activating virtual environment"
        .\.venv\Scripts\Activate.ps1
    } elseif (-not (Test-Path venv)) {
        echo "Creating new virtual environment"
        uv venv venv
    }
    if (Test-Path venv\Scripts) {
        echo "Activating virtual environment"
        .\venv\Scripts\Activate.ps1
    }
    echo "Virtual Environment is active!"
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
    echo "Virtual Environment has been synced!"
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
function sd { Start-Process pwsh -Verb RunAs -ArgumentList "-Command cd '$pwd'; Clear-Host ; $args ; Read-Host 'Exit Now?'" }

##### ffmpeg extract one #####
function extractFrame {
    ffmpeg -i "$args" -vf "select=eq(n\,0)" -update 1 -frames:v 1 -q:v 3 output.jpg
}

##### Other stuff #####
fastfetch
