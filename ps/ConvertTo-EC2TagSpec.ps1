function ConvertTo-EC2TagSpec {
<#
.DESCRIPTION
    Takes an input hashtable of and converts it to an AWS EC2 Tag Specification object

.LINK
    https://serverfault.com/questions/946190/how-to-tag-an-ec2-instance-on-creation
#>
    [cmdletbinding()]Param(
    # https://docs.aws.amazon.com/sdkfornet/v3/apidocs/items/EC2/TTag.html
        [Parameter(Mandatory)]
        [object]$tags,
    # https://docs.aws.amazon.com/sdkfornet/v3/apidocs/items/EC2/TTagSpecification.html
        [Parameter(Mandatory)]
        [ValidateSet(
            'capacity-reservation',
            'client-vpn-endpoint',
            'dedicated-host',
            'fleet',
            'instance',
            'launch-template',
            'snapshot',
            'transit-gateway',
            'transit-gateway-attachment',
            'transit-gateway-route-table',
            'volume'
        )]
        [string]$ResourceType
    )

    $TagSpecification = [Amazon.EC2.Model.TagSpecification]::new()
    $TagSpecification.ResourceType = $ResourceType

    $tags.PSObject.Properties | ForEach-Object {
        $tag = [Amazon.EC2.Model.Tag]@{
            Key   = $_.Name
            Value = $_.Value
        }
        $TagSpecification.Tags.Add($tag)
    } 

    return $TagSpecification
}
