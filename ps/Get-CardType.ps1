Function Get-CardType {
    [cmdletbinding()]Param(
        $cc_num
    )

# https://www.regular-expressions.info/creditcard.html
    $VisaRegex     = '^4[0-9]{12}(?:[0-9]{3})?$'
    $McRegex       = '^(?:5[1-5][0-9]{2}|222[1-9]|22[3-9][0-9]|2[3-6][0-9]{2}|27[01][0-9]|2720)[0-9]{12}$'
    $AmexRegex     = '^3[47][0-9]{13}$'
    $DcRegex       = '^3(?:0[0-5]|[68][0-9])[0-9]{11}$'
    $DiscoverRegex = '^6(?:011|5[0-9]{2})[0-9]{12}$'
    $JcbRegex      = '^(?:2131|1800|35\d{3})\d{11}$'

    switch -Regex ($cc_num){
        $VisaRegex     {"Visa"}
        $McRegex       {"MasterCard"}
        $AmexRegex     {"Amex"}
        $DcRegex       {"Diners Club"}
        $DiscoverRegex {"Discover"}
        $JcbRegex      {"JCB"}
        default        {"NOT_VALID"}
    }
}