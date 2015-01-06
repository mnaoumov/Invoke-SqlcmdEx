#requires -version 2.0

[CmdletBinding()]
param
(
    [string] $ServerInstance,
    [string] $Database,
    [string] $User,
    [string] $Password,
    [string] $InputFile
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
function PSScriptRoot { $MyInvocation.ScriptName | Split-Path }

trap { throw $Error[0] }

function Main
{
    if (-not (Get-Command -Name sqlcmd.exe -ErrorAction SilentlyContinue))
    {
        throw "sqlcmd.exe not found"
    }

    $scriptLines = Get-Content -Path $InputFile
    $extendedLines = @()
    foreach ($line in $scriptLines)
    {
        if ($line -match "\s*GO\s*")
        {
            $extendedLines += "PRINT '~~~ Invoke-SqlcmdEx Helper - Offset #TODO'"
        }

        $extendedLines += $line
    }

    $tempFile = [System.IO.Path]::GetTempFileName()
    
    $extendedLines > $tempFile

    $sqlCmdArguments = Get-SqlCmdArguments
    
    $ErrorActionPreference = "Continue"
    $result = sqlcmd.exe $sqlCmdArguments -i $tempFile 2>&1
    $ErrorActionPreference = "Stop"
    
    $result | % { "$_" }
}

function Get-SqlCmdArguments
{
    $sqlCmdArguments = `
        @(
            "-S",
            $ServerInstance,
            "-d",
            $Database,
            "-b",
            "-r",
            0
        )
        
    if ($User)
    {
        $sqlCmdArguments += `
            @(
                "-U",
                $User,
                "-P",
                $Password
            )
    }
    else
    {
        $sqlCmdArguments += "-E"
    }

    $sqlCmdArguments
}

Main