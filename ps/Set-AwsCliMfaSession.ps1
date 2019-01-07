# TODO: dispose of vars properly... 
# not sure atm  why they persist in caller scope when dot-sourced :\
[cmdletbinding()]param(
     [Parameter(Mandatory=$true)]$AWS_MFA_Code
    ,$AwsProfile = "default"
)

$serial_number = (aws sts get-caller-identity --profile $AwsProfile --output text --query 'Arn').Replace('user','mfa')

$json = aws sts get-session-token --profile $AwsProfile --serial-number $serial_number --token-code $AWS_MFA_Code
$obj = $json | ConvertFrom-Json

if($null -ne $obj.Credentials){

    Set-item -path env:AWS_ACCESS_KEY_ID -value $obj.Credentials.AccessKeyId
    Set-item -path env:AWS_SESSION_TOKEN -value $obj.Credentials.SessionToken
    Set-item -path env:AWS_SECRET_ACCESS_KEY -value $obj.Credentials.SecretAccessKey

    Write-Host "Session credential set for profile [$AwsProfile]" -ForegroundColor Yellow

    if($null -eq (Get-DefaultAWSRegion)){
        Write-Host "No default AWS Region set. Browse valid options with Get-AWSRegion" -ForegroundColor Yellow
        $region = Read-Host "Enter your default AWS Region now if you would like"
    
    #TODO: $defaultRegion = (gc ~/.aws/config | convertfrom-something | where profile -eq $awsProfile).region

        if((Get-AWSRegion).Region -contains $region){
            $region | Set-DefaultAWSRegion
            Write-Host "Default AWS Region set to [$region]" -ForegroundColor Yellow
        }
        else {
            Write-Host "Default AWS region not set or [$region] is not a valid AWS Region" -ForegroundColor Red
            Write-Host "Use the -Region parameter or set manually as needed. Examine valid regions with Get-AWSRegion" -ForegroundColor Yellow
        }
    }
}