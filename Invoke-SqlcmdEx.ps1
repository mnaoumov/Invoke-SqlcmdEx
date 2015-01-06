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
    
    $sqlCmdArguments = Get-SqlCmdArguments

    sqlcmd.exe $sqlCmdArguments
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
            1
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