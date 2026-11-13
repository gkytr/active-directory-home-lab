#requires -RunAsAdministrator
<#
.SYNOPSIS
Yeni bir test etki alanı (forest) oluşturur.

.NOTES
Bu dosyayı yalnızca yeni kurduğun DC01 sunucusunda çalıştır.
Sunucu adı ve IP ayarlarını önceden yap. İşlem tamamlandığında
sunucu yeniden başlatılır.
#>
[CmdletBinding()]
param(
    [string]$DomainName = "corp.example.test",
    [string]$NetBIOSName = "CORP"
)

$ErrorActionPreference = "Stop"

Write-Host "Active Directory Domain Services rolü kuruluyor..." -ForegroundColor Cyan
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

Write-Host "$DomainName etki alanı oluşturulacak." -ForegroundColor Cyan
Write-Warning "Kurulum tamamlandığında sunucu yeniden başlayacak."

$dsrmPassword = Read-Host "DSRM için bir parola belirle" -AsSecureString

Install-ADDSForest `
    -DomainName $DomainName `
    -DomainNetBIOSName $NetBIOSName `
    -InstallDNS `
    -SafeModeAdministratorPassword $dsrmPassword `
    -Force
