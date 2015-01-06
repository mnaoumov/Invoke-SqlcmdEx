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
        
        $batches = Get-Batches -Path $InputFile
        
        foreach ($batch in $batches)
        {
            Execute-Batch -Connection $connection -Batch $batch
        }
    }
    finally
    {
        $connection.Dispose()
    }
}

function Get-Batches
{
    param
    (
        [string] $Path
    )
    
    $scriptLines = @(Get-Content -Path $Path)
    $scriptLines += "GO" # Add trailing GO
    $batches = @()
    $batchLines = @()
    $offset = 0
    for ($i = 0; $i -lt $scriptLines.Length; $i++)
    {
        $scriptLine = $scriptLines[$i]
        if ($scriptLine -match "\s*GO\s*")
        {
            $query = $batchLines -join "`r`n"
            if ($query -notmatch "^\s*$")
            {
                $batches += New-Object -TypeName PSObject -Property `
                @{
                    Query = $query;
                    Offset = $offset;
                }
            }

            $offset = $i + 1
            $batchLines = @()
        }
        else
        {
            $batchLines += $scriptLine
        }
    }
    
    $batches
}

function Execute-Batch
{
    param
    (
        [System.Data.SqlClient.SqlConnection] $Connection,
        [PSObject] $Batch
    )
    
    $command = $Connection.CreateCommand()
    $command.CommandText = $Batch.Query
    $command.ExecuteNonQuery()
}

Main