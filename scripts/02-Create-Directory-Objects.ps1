#requires -RunAsAdministrator
<#
.SYNOPSIS
Creates a sample OU structure, fictional users, security groups, and memberships.

.NOTES
Run after DC01 has been promoted and restarted.
The script is intended for a fresh demonstration domain.
#>
[CmdletBinding()]
param(
    [string]$DomainDN = "DC=corp,DC=example,DC=test",
    [string]$DomainDnsName = "corp.example.test"
)

$ErrorActionPreference = "Stop"
Import-Module ActiveDirectory

# Create parent OUs first, then their child OUs.
$ouDefinitions = @(
    @{ Name = "Company"; Path = $DomainDN },
    @{ Name = "Users"; Path = "OU=Company,$DomainDN" },
    @{ Name = "Groups"; Path = "OU=Company,$DomainDN" },
    @{ Name = "Computers"; Path = "OU=Company,$DomainDN" },
    @{ Name = "Service Accounts"; Path = "OU=Company,$DomainDN" },
    @{ Name = "IT"; Path = "OU=Users,OU=Company,$DomainDN" },
    @{ Name = "HR"; Path = "OU=Users,OU=Company,$DomainDN" },
    @{ Name = "Sales"; Path = "OU=Users,OU=Company,$DomainDN" },
    @{ Name = "Workstations"; Path = "OU=Computers,OU=Company,$DomainDN" },
    @{ Name = "Servers"; Path = "OU=Computers,OU=Company,$DomainDN" }
)

foreach ($ou in $ouDefinitions) {
    $dn = "OU=$($ou.Name),$($ou.Path)"
    $existingOU = Get-ADOrganizationalUnit -LDAPFilter "(distinguishedName=$dn)" -ErrorAction SilentlyContinue

    if (-not $existingOU) {
        New-ADOrganizationalUnit -Name $ou.Name -Path $ou.Path -ProtectedFromAccidentalDeletion $true
        Write-Host "Created OU: $dn" -ForegroundColor Green
    }
    else {
        Write-Host "OU already exists: $dn"
    }
}

# Create role-based global security groups.
$groupsPath = "OU=Groups,OU=Company,$DomainDN"
$groupNames = @("GG_IT_Support", "GG_HR_Users", "GG_Sales_Users")

foreach ($groupName in $groupNames) {
    if (-not (Get-ADGroup -Filter "SamAccountName -eq '$groupName'" -ErrorAction SilentlyContinue)) {
        New-ADGroup -Name $groupName -SamAccountName $groupName -GroupScope Global -GroupCategory Security -Path $groupsPath
        Write-Host "Created group: $groupName" -ForegroundColor Green
    }
}

# Fictional test accounts. Passwords are prompted securely and are never stored in source control.
$demoUsers = @(
    @{ Name = "Demo IT User"; GivenName = "Demo"; Surname = "IT"; Sam = "demo.it"; OU = "IT"; Group = "GG_IT_Support" },
    @{ Name = "Demo HR User"; GivenName = "Demo"; Surname = "HR"; Sam = "demo.hr"; OU = "HR"; Group = "GG_HR_Users" },
    @{ Name = "Demo Sales User"; GivenName = "Demo"; Surname = "Sales"; Sam = "demo.sales"; OU = "Sales"; Group = "GG_Sales_Users" }
)

foreach ($user in $demoUsers) {
    $userPath = "OU=$($user.OU),OU=Users,OU=Company,$DomainDN"
    $existingUser = Get-ADUser -Filter "SamAccountName -eq '$($user.Sam)'" -ErrorAction SilentlyContinue

    if (-not $existingUser) {
        $securePassword = Read-Host "Set a temporary password for $($user.Sam)" -AsSecureString

        New-ADUser `
            -Name $user.Name `
            -GivenName $user.GivenName `
            -Surname $user.Surname `
            -SamAccountName $user.Sam `
            -UserPrincipalName "$($user.Sam)@$DomainDnsName" `
            -Path $userPath `
            -AccountPassword $securePassword `
            -Enabled $true `
            -ChangePasswordAtLogon $true

        Write-Host "Created user: $($user.Sam)" -ForegroundColor Green
    }
    else {
        Write-Host "User already exists: $($user.Sam)"
    }

    Add-ADGroupMember -Identity $user.Group -Members $user.Sam -ErrorAction SilentlyContinue
}

Write-Host "Directory object setup complete." -ForegroundColor Green
