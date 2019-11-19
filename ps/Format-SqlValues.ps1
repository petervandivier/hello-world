
function Format-SqlValues {
<#
.DESCRIPTION
    Returns a valid "INSERT INTO {object} VALUES {...};" statement

.PARAMETER InputObject
    Generic PSObject, probably Import-Csv. pipelineable.

.PARAMETER TableName
    The target table to be inserted against. Returns "{0}" token if not supplied

.PARAMETER TypeMap
    Hashtable to set datatypes of individual columns in the InputObject

.PARAMETER BatchSize
    The number of rows per insert statement. Defaults to 1000 (SQL Server max batch size).
    NULL BatchSize will provide a single batch

.TODO
    Add-back -Pretty & -Everything is text switches
    Test handling of $InputObject with nested properties (detect arrays)
    Handle non-text types in $InputObject


#>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline=$true)]
        $InputObject,
        [Parameter()]
        [ValidateRange("NonNegative")]
        [int]
        $BatchSize = 1000,
        [Parameter()]
        [string]
        $TableName,
        [Parameter()]
        [hashtable]
        $TypeMap
    )

    begin {
        function Get-DataType {
            [CmdletBinding()]
            param (
                [Parameter()]
                [string]
                $InputObject
            )
            switch ($InputObject) {
                {$_ -in ("NULL",$null)}         { "EMPTY";    break }
                {$_ -as [datetime]}             { "DATETIME"; break }
                {$null -ne ($_ -as [decimal])}  { "NUMERIC";  break }
                {$_ -in ('TRUE','FALSE')}       { "BOOL";     break }
                Default                         { "STRING";   break }
            }
        }

        $Columns = @{}
        $RowCount = $InputObject.Count
        if($null -eq $BatchSize){$BatchSize = $RowCount}

        $InputObject | 
        ForEach-Object {
            $PSItem.PSObject.Properties.Name
        } | 
        Select-Object -Unique | 
        ForEach-Object {
            $Columns.Add($PSItem, @{
                Type      = $null
                TypeCount = @{
                    EMPTY    = 0
                    DATETIME = 0
                    NUMERIC  = 0
                    BOOL     = 0
                    STRING   = 0
                }
            })
        }
 
        foreach($key in $TypeMap.Keys) {
            $type = $TypeMap.$key
            $Columns.$key.Type = $type
        }

        $ColumnNames = $Columns.Keys 
        $BATCH_HEADER = @"
INSERT INTO {1} 
{0}
VALUES

"@
        # TODO: Pad Column Header
        $COLUMN_HEADER = ($ColumnNames -join ',')
        $COLUMN_HEADER = "($COLUMN_HEADER)"
        $BATCH_HEADER = $BATCH_HEADER -f $COLUMN_HEADER, '{0}'

        foreach($column in $ColumnNames) {
            $group = $InputObject.$column | Group-Object 
        
            [int]$MaxLength = ($group.Name | Measure-Object -Maximum -Property Length).Maximum
            
            $Columns.$column.Add('MaxLength',$MaxLength)
            
            $group | ForEach-Object {
                $DataType = (Get-DataType $_.Name)
                $Columns.$column.TypeCount.$DataType += $_.Count
            }

            if($null -eq $Columns.$column.Type){
                $DataType = switch ($Columns.$column.TypeCount) {
                    {$_.EMPTY -eq $RowCount}                 { "EMPTY";    break }
                    {($_.DATETIME + $_.EMPTY) -eq $RowCount} { "DATETIME"; break }
                    {($_.NUMERIC + $_.EMPTY) -eq $RowCount}  { "NUMERIC";  break }
                    {($_.BOOL + $_.EMPTY) -eq $RowCount}     { "BOOL";     break }
                    default                                  { "STRING";   break }
                }
                $Columns.$column.Type = $DataType
            }
        }
    }
    
    process {
        $valuesArray = foreach($row in $InputObject){
            $literals = foreach($column in $ColumnNames){
                $pad = $Columns.$column.MaxLength
                
                [string]$value = switch ($Columns.$column.Type) {
                    { [string]::IsNullOrEmpty($row.$column) } { "NULL"; break }
                    { $_ -eq "EMPTY" }    { "NULL";                           break }
                    { $_ -eq "DATETIME" } { "'$($row.$column)'";              break }
                    { $_ -eq "NUMERIC" }  { Invoke-Expression ($row.$column); break }
                    { $_ -eq "BOOL" }     { "'$($row.$column)'";              break }
                    Default { "'$($row.$column -replace "'", "''")'";         break }
                }
                
                $value = "$value,"
                
                $value.PadRight($pad + 3)
            }

            ("(", ($literals -join ' '), ")") -join ''
        }

        $output = for($i = 0; $i -lt $RowCount; $i += $BatchSize){
            @(
                $BATCH_HEADER
                $valuesArray[$i..($i + $BatchSize - 1)] -join ",`n"
                ";"
            ) -join ''
        }

        if($TableName){
            $output =  $output -f $TableName
        }
    }
    
    end {
        $output
    }
}