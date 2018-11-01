param([Parameter(Mandatory=$true)]$AWS_MFA_Code)

$serial_number = (aws sts get-caller-identity --output text --query 'Arn').Replace('user','mfa')

$json = aws sts get-session-token --serial-number $serial_number --token-code $AWS_MFA_Code
$obj = $json | ConvertFrom-Json

Set-item -path env:AWS_ACCESS_KEY_ID -value $obj.Credentials.AccessKeyId
Set-item -path env:AWS_SESSION_TOKEN -value $obj.Credentials.SessionToken
Set-item -path env:AWS_SECRET_ACCESS_KEY -value $obj.Credentials.SecretAccessKey
