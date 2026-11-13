#requires -RunAsAdministrator
<#
.SYNOPSIS
Installs AD DS and creates a new forest on a fresh lab server.

.NOTES
Run on DC01 only. Review the domain name and network configuration first.
The server restarts after successful promotion.
#>
[CmdletBinding()]
param(
    [string]$DomainName = "corp.example.test",
    [string]$NetBIOSName = "CORP"
)

$ErrorActionPreference = "Stop"

Write-Host "Installing Active Directory Domain Services..." -ForegroundColor Cyan
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

Write-Host "Promoting this server to the first domain controller for $DomainName..." -ForegroundColor Cyan
Write-Warning "The server will restart after the forest is created."

$dsrmPassword = Read-Host "Enter a Directory Services Restore Mode (DSRM) password" -AsSecureString

Install-ADDSForest `
    -DomainName $DomainName `
    -DomainNetBIOSName $NetBIOSName `
    -InstallDNS `
    -SafeModeAdministratorPassword $dsrmPassword `
    -Force
