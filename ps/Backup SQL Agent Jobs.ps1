[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo') | Out-Null
$serverInstance = "localhost"
 
$server = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $serverInstance
 
$jobs = $server.JobServer.Jobs 
#$jobs = $server.JobServer.Jobs | where-object {$_.category -eq "[your category]"}
 
if ($jobs -ne $null)
{
 
$serverInstance = $serverInstance.Replace("\", "-")
 
ForEach ( $job in $jobs )
{
$FileName = "C:\temp\" + $serverInstance + "_" + $job.Name.Replace(":", "-") + ".sql"
$FileName = $FileName.Replace("/", "-")
$job.Script() | Out-File -filepath $FileName
}

#Copy-Item  C:\temp\* d:\temp

}