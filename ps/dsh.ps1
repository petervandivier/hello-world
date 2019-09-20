function dsh { 
<#
.DESCRIPTION
    Danger SHell - "just go there". saves typing when you don't care 
      and sure as shit don't want to trust this host
    HT @chrisident in pwsh community slack for the assist
#>
    ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no @args 
}