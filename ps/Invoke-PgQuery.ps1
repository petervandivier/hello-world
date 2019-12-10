function Invoke-PgQuery {
    [CmdletBinding()]
    param (
        [Parameter(Position=0)]
        [string]
        $Query = 'select version();',

        [Alias('Connection', 'Conn')]
        [ValidateNotNullOrEmpty()]
        [string]
        $SQLConnection = '127.0.0.1',

        [string]
        $Database = 'postgres'
    )

    $iniFile = Invoke-Expression "odbcinst -j | grep DRIVERS | awk '{print `$2}'"

    if((Get-Content $iniFile -Raw) -notmatch $Driver){
        Write-Error "Cannot find Driver configuration for '$Driver' in '$iniFile'."
        return
    }

    $conn = New-Object System.Data.Odbc.OdbcConnection
    $conn.ConnectionString="Driver={$Driver};Server=$SQLConnection;Port=5432;Database=$Database;"
    $conn.Open()
    
    $cmd = New-Object System.Data.Odbc.OdbcCommand($Query,$conn)
    $ds = New-Object System.Data.DataSet
    $da = New-Object System.Data.Odbc.OdbcDataAdapter($cmd)

    $da.Fill($ds) | Out-Null

    $conn.close()
    $conn.Dispose()

    $ds.Tables[0].Rows[0].Table[0]
    $da.Dispose()
    $ds.Dispose()
}
