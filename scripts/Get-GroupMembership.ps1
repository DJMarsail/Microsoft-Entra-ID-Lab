param([Parameter(Mandatory)][string]$TenantId)
$ErrorActionPreference = 'Stop'
Connect-MgGraph -TenantId $TenantId -Scopes 'User.Read.All','Group.Read.All' -NoWelcome
try {
    Get-MgGroup -All -Filter "securityEnabled eq true" | ForEach-Object {
        $group = $_
        Get-MgGroupMember -GroupId $group.Id -All | ForEach-Object {
            [PSCustomObject]@{
                Group = $group.DisplayName
                Member = $_.AdditionalProperties['displayName']
            }
        }
    } | Format-Table -AutoSize
} finally { Disconnect-MgGraph | Out-Null }
