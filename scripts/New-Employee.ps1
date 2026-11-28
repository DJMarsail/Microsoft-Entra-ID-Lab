param(
    [Parameter(Mandatory)][string]$TenantId,
    [Parameter(Mandatory)][string]$Domain,
    [Parameter(Mandatory)][string]$DisplayName,
    [Parameter(Mandatory)][string]$Username,
    [Parameter(Mandatory)][ValidateSet('Human Resources','IT Support','Sales')][string]$Department,
    [Parameter(Mandatory)][string]$JobTitle,
    [Parameter(Mandatory)][string]$EmployeeId
)
$ErrorActionPreference = 'Stop'
Connect-MgGraph -TenantId $TenantId -Scopes 'User.ReadWrite.All','GroupMember.ReadWrite.All','Group.Read.All' -NoWelcome
$groupName = @{'Human Resources'='SG-HR';'IT Support'='SG-IT-Support';'Sales'='SG-Sales'}[$Department]
$groups = @(Get-MgGroup -Filter "displayName eq '$groupName' and securityEnabled eq true")
if ($groups.Count -ne 1) { throw 'Expected exactly one matching security group.' }
$password = Read-Host 'Temporary password' -AsSecureString
if ($password.Length -eq 0) { throw 'Password cannot be empty.' }
try {
    $user = New-MgUser -BodyParameter @{
        AccountEnabled = $true
        DisplayName = $DisplayName
        MailNickname = $Username
        UserPrincipalName = "$Username@$Domain"
        Department = $Department
        JobTitle = $JobTitle
        EmployeeId = $EmployeeId
        CompanyName = 'Contoso Labs'
        UsageLocation = 'US'
        PasswordProfile = @{
            Password = [System.Net.NetworkCredential]::new('', $password).Password
            ForceChangePasswordNextSignIn = $true
        }
    }
    try {
        New-MgGroupMember -GroupId $groups[0].Id -DirectoryObjectId $user.Id
    } catch {
        throw "User created, but group assignment failed. Review account $($user.Id): $_"
    }
    Write-Host "Employee onboarded: $DisplayName -> $groupName"
} finally {
    $password.Dispose()
    Disconnect-MgGraph | Out-Null
}
