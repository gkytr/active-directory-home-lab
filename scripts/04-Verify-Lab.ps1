#requires -RunAsAdministrator
<#
.SYNOPSIS
Runs basic domain, directory, DNS, and domain-controller checks.
Run on the domain controller.
#>
$ErrorActionPreference = "Continue"
Import-Module ActiveDirectory

Write-Host "`n=== Domain information ===" -ForegroundColor Cyan
Get-ADDomain | Select-Object DNSRoot, NetBIOSName, DomainMode

Write-Host "`n=== Domain controllers ===" -ForegroundColor Cyan
Get-ADDomainController -Filter * | Select-Object HostName, IPv4Address, Site, IsGlobalCatalog

Write-Host "`n=== Organizational Units ===" -ForegroundColor Cyan
Get-ADOrganizationalUnit -Filter * |
    Select-Object Name, DistinguishedName |
    Format-Table -AutoSize

Write-Host "`n=== Demo users ===" -ForegroundColor Cyan
Get-ADUser -Filter "SamAccountName -like 'demo.*'" -Properties Enabled |
    Select-Object Name, SamAccountName, Enabled |
    Format-Table -AutoSize

Write-Host "`n=== Portfolio security groups ===" -ForegroundColor Cyan
Get-ADGroup -Filter "Name -like 'GG_*'" |
    Select-Object Name, GroupScope, GroupCategory |
    Format-Table -AutoSize

Write-Host "`n=== DNS lookup ===" -ForegroundColor Cyan
$domainName = (Get-ADDomain).DNSRoot
Resolve-DnsName -Name $domainName -ErrorAction Continue

Write-Host "`n=== Domain controller diagnostics ===" -ForegroundColor Cyan
dcdiag /q

Write-Host "`nVerification commands completed. Review any warnings or errors above." -ForegroundColor Green
