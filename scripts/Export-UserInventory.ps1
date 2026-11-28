param(
    [Parameter(Mandatory)][string]$TenantId,
    [string]$Path = "$HOME/Entra-User-Inventory.csv"
)
$ErrorActionPreference = 'Stop'
Connect-MgGraph -TenantId $TenantId -Scopes 'User.Read.All' -NoWelcome
try {
    Get-MgUser -All -Property DisplayName,UserPrincipalName,Department,JobTitle,AccountEnabled |
        Select-Object DisplayName,UserPrincipalName,Department,JobTitle,AccountEnabled |
        Export-Csv -Path $Path -NoTypeInformation
    Write-Host "Inventory exported to $Path"
} finally { Disconnect-MgGraph | Out-Null }
