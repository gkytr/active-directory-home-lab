#requires -RunAsAdministrator
<#
.SYNOPSIS
Creates a starter GPO and links it to the Workstations OU.

.NOTES
This creates the GPO and its link; configure and document policy settings
through Group Policy Management. This is not a complete security baseline.
#>
[CmdletBinding()]
param(
    [string]$DomainDN = "DC=corp,DC=example,DC=test",
    [string]$GpoName = "LAB - Workstation Baseline"
)

$ErrorActionPreference = "Stop"
Import-Module GroupPolicy

$workstationsOU = "OU=Workstations,OU=Computers,OU=Company,$DomainDN"

$gpo = Get-GPO -Name $GpoName -ErrorAction SilentlyContinue
if (-not $gpo) {
    New-GPO -Name $GpoName -Comment "Starter GPO created for the Active Directory portfolio lab." | Out-Null
    Write-Host "Created GPO: $GpoName" -ForegroundColor Green
}
else {
    Write-Host "GPO already exists: $GpoName"
}

$existingLinks = (Get-GPInheritance -Target $workstationsOU).GpoLinks
if (-not ($existingLinks | Where-Object { $_.DisplayName -eq $GpoName })) {
    New-GPLink -Name $GpoName -Target $workstationsOU -LinkEnabled Yes | Out-Null
    Write-Host "Linked GPO to $workstationsOU" -ForegroundColor Green
}
else {
    Write-Host "GPO is already linked to the Workstations OU."
}

Write-Host "Next: configure selected policy settings in Group Policy Management and document them." -ForegroundColor Cyan
