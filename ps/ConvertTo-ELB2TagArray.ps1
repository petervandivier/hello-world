
function ConvertTo-ELB2TagArray {
<#
.DESCRIPTION
    Takes an input hashtable of and converts it to an array of AWS ELB2 tags 

.LINK
    https://docs.aws.amazon.com/sdkfornet/v3/apidocs/items/ElasticLoadBalancingV2/NELBV2Model.html
#>
    [cmdletbinding()]Param(
    # https://docs.aws.amazon.com/sdkfornet/v3/apidocs/items/ElasticLoadBalancingV2/TTag.html
        [Parameter(Mandatory)]
        [object]$tags
    )

    $TagArray = @()

    $tags.PSObject.Properties | ForEach-Object {
        $tag = [Amazon.ElasticLoadBalancingV2.Model.Tag]@{
            Key   = $_.Name
            Value = $_.Value
        }
        $TagArray += $tag
    } 

    return $TagArray
}
