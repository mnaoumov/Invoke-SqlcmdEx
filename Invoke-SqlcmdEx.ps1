#requires -version 2.0

[CmdletBinding()]
param
(
    [Parameter(Mandatory = $true)]
    [string] $ConnectionString,

    [Parameter(Mandatory = $true)]
    [string] $InputFile
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
function PSScriptRoot { $MyInvocation.ScriptName | Split-Path }

trap { throw $Error[0] }

function Main
{
    $connection = New-Object -TypeName System.Data.SqlClient.SqlConnection -ArgumentList @($ConnectionString)
    
    try
    {
        $connection.Open()
    }
    finally
    {
        $connection.Dispose()
    }
}

Main