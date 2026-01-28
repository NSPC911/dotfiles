if (Get-Command bat -ErrorAction SilentlyContinue -WarningAction SilentlyContinue) {}
else { throw "Please install 'bat' to use this script. Either via winget, scoop, or choco." }
function Write-PoshHighlighted {
    Write-Output $args | bat --force-colorization --style plain --language Powershell --paging=never
}
if ($env:EDITOR -eq $null -or $env:EDITOR -eq "") {
    if (Get-Command edit -ErrorAction SilentlyContinue) {
        $env:EDITOR = "edit"
    } elseif (Get-Command code -ErrorAction SilentlyContinue) {
        $env:EDITOR = "code --wait"
    } elseif (Get-Command nano -ErrorAction SilentlyContinue) {
        $env:EDITOR = "nano"
    } else {
        throw "No reasonable editor found in PATH. Please set the EDITOR environment variable to your preferred text editor."
    }
}

##### gh copilot cli but local #####
$ollamaSuggesterModel = "codegemma:7b"
$opencodeSuggesterModel = "mistral/codestral-latest"
$ollamaExplainerModel = "codegemma:2b"
$opencodeExplainerModel = "github-copilot/gemini-3-flash-preview"

$opencodeAvailable = (Get-Command opencode -ErrorAction SilentlyContinue) -ne $null

function suggest {
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

    $output = Invoke-SpectreCommandWithStatus -Spinner "Point" -Title "[cyan]Thinking...[/]" -ScriptBlock {
        if ($opencodeAvailable) {
            $result = opencode run --model $opencodeSuggesterModel "$prompt" 2>$null
        }
        if ($LASTEXITCODE -ne 0 -or -not ($opencodeAvailable)) {
            $result = ollama run $ollamaSuggesterModel $prompt
        }
        return $result
    }
    $command = ($output | Out-String).Trim()
    Write-Host "`e[1G╭─ Suggested command:"
    Write-Host "│"
    Write-PoshHighlighted $command | ForEach-Object { Write-Host "·  $_" }
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
                    Write-Host "╰─ Command copied to clipboard!`n" -ForegroundColor Green
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
                    Write-PoshHighlighted $command | ForEach-Object { Write-Host "·  $_" }
                    Write-Host "│"
                }
                3 {
                    Write-Host "├─ How should the command be improved?"
                    Write-Host "╰─❯ " -NoNewLine
                    $improvement = Read-Host
                    Write-Host "`e[2F├─ How should the command be improved?" -ForegroundColor Green
                    Write-Host "╰── $improvement  " -ForegroundColor Green
                    $improvePrompt = "Improve this PowerShell command`n$command`nUser wants:`n'$improvement'`nRespond with ONLY the improved command as plain text, no formatting or code blocks. This is a Windows environment with pwsh as the active shell."
                    $output = Invoke-SpectreCommandWithStatus -Spinner "Point" -Title "[cyan]Improving...[/]" -ScriptBlock {
                        if ($opencodeAvailable) {
                            $result = opencode run --model $opencodeSuggesterModel "$improvePrompt" 2>$null
                        }
                        if ($LASTEXITCODE -ne 0 -or -not ($opencodeAvailable)) {
                            $result = ollama run $ollamaSuggesterModel $improvePrompt
                        }
                        return $result
                    }
                    $command = ($output | Out-String).Trim()
                    Write-Host "`e[1G╭─ Improved command:"
                    Write-Host "│"
                    Write-PoshHighlighted $command | ForEach-Object { Write-Host "·  $_" }
                    Write-Host "│"
                    $selectedIndex = 0
                }
                4 {
                    Write-Host "╰─ Exited.`n" -ForegroundColor Magenta
                    return
                }
            }
        }
    } while ($true)
}

function explain {
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

    $result = Invoke-SpectreCommandWithStatus -Spinner "Point" -Title "[cyan]Thinking...[/]" -ScriptBlock {
        if ($opencodeAvailable) {
            $out = opencode run --model $opencodeExplainerModel "$prompt" 2>$null
        }
        if ($LASTEXITCODE -eq 0 -or -not ($opencodeAvailable)) {
            return @{ output = $out; model = $opencodeExplainerModel }
        } else {
            $out = ollama run $ollamaExplainerModel $prompt
            return @{ output = $out; model = $ollamaExplainerModel }
        }
    }
    $output = ($result.output | Out-String).Trim()
    $model = $result.model
    $maxWidth = [int]($Host.UI.RawUI.WindowSize.Width - 8)
    if (Get-Command rich -ErrorAction SilentlyContinue) {
        $output | rich --markdown --panel rounded --expand --guides --hyperlinks --caption "Using [cyan]$model[/]" --width $maxWidth --center -
    } elseif (Get-Command uv -ErrorAction SilentlyContinue) {
        $output | uvx --from rich-cli rich --markdown --panel rounded --expand --guides --hyperlinks --caption "Using [cyan]$model[/]" --width $maxWidth --center -
    } else {
        $output | Show-Markdown
    }
    Write-Host ""
}
