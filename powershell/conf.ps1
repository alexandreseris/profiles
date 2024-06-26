set-alias "w" "where.exe"
set-alias "n" "notepad"
set-alias "n+" "notepad++"
set-alias "c" "code"

Set-PSReadlineKeyHandler -Key ctrl+d -Function ViExit
Set-PSReadlineKeyHandler -Key ctrl+l -Function ClearScreen
Set-PSReadlineKeyHandler -Key ctrl+k -ScriptBlock { Clear-Host; write-host "" }
Set-PSReadlineKeyHandler -Key ctrl+w -Function BackwardDeleteWord

# encoding
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
$OutputEncoding = [Text.UTF8Encoding]::UTF8
[Console]::OutputEncoding = [Text.UTF8Encoding]::UTF8

# colors
Set-PSReadLineOption -Colors @{ "Type" = "#ff8ae4" }

# startup actions
if ($env:SKIP_STARTUP -ne "y") {
    Import-Module posh-git
    $GitPromptSettings.WindowTitle = ""
    $GitPromptSettings.DefaultPromptBeforeSuffix.text = ""
    $GitPromptSettings.DefaultPromptAbbreviateHomeDirectory = $true
    $GitPromptSettings.DefaultPromptAbbreviateGitDirectory = $true
    $GitPromptSettings.DefaultPromptWriteStatusFirst = $true
    $GitPromptSettings.DefaultPromptPath.ForegroundColor = 'Orange'
    function prompt {
        $last_is_err = -not $?
        $prompt = Write-Prompt "$(date_to_string) :: " -ForegroundColor ([ConsoleColor]::Yellow)
        if ($LASTEXITCODE -ne 0 -or $last_is_err) {
            $err_message = $LASTEXITCODE
            if ($LASTEXITCODE -eq 0) {
                $err_message = "FAIL"
            }
            $prompt += Write-Prompt "($err_message) " -ForegroundColor ([ConsoleColor]::Red)
        }
        $prompt += & $GitPromptScriptBlock
        $prompt += Write-Prompt "$(">" * ($nestedPromptLevel + 1))" -ForegroundColor ([ConsoleColor]::Magenta)
        $prompt += Write-Prompt "`n"
        if ($prompt) { "$prompt " } else { " " }
    }


    # vscode shenanigans
    if ($null -ne $env:VSCODE_WS) {
        Set-Location $env:VSCODE_WS
    } else {
        
    }
}
