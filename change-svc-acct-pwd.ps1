#https://mcpmag.com/articles/2015/01/22/password-for-a-service-account-in-powershell.aspx
$svcAcct="yolo\all.day"
$Service = (Get-WmiObject -Class Win32_Service) | Where-Object startname -eq '$svcAcct'
$Service | Select Name, StartName, State
$Password = Read-Host -Prompt "Enter password for $svcAcct" -AsSecureString
#required to decrypt PWD from securestring before applying
$BSTR = [system.runtime.interopservices.marshal]::SecureStringToBSTR($Password)
$Password = [system.runtime.interopservices.marshal]::PtrToStringAuto($BSTR)
$Service.Change($Null,$Null,$Null,$Null,$Null,$Null,$Null,$Password,$Null,$Null,$Null)
$Service.StopService().ReturnValue
$Service.StartService().ReturnValue 
Remove-Variable Password,BSTR
[Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR) 