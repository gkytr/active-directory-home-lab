#requires -RunAsAdministrator
<#
.SYNOPSIS
Etki alanı, OU, kullanıcı, grup ve DNS tarafında temel kontroller yapar.

.NOTES
DC01 üzerinde, yönetici olarak çalıştır.
#>
$ErrorActionPreference = "Continue"
Import-Module ActiveDirectory

Write-Host "`n--- Etki alanı bilgisi ---" -ForegroundColor Cyan
Get-ADDomain | Select-Object DNSRoot, NetBIOSName, DomainMode | Format-List

Write-Host "`n--- Etki alanı denetleyicileri ---" -ForegroundColor Cyan
Get-ADDomainController -Filter * |
    Select-Object HostName, IPv4Address, Site, IsGlobalCatalog |
    Format-Table -AutoSize

Write-Host "`n--- OU listesi ---" -ForegroundColor Cyan
Get-ADOrganizationalUnit -Filter * |
    Select-Object Name, DistinguishedName |
    Format-Table -AutoSize

Write-Host "`n--- Demo kullanıcılar ---" -ForegroundColor Cyan
Get-ADUser -Filter "SamAccountName -like 'demo.*'" -Properties Enabled |
    Select-Object Name, SamAccountName, Enabled |
    Format-Table -AutoSize

Write-Host "`n--- Güvenlik grupları ---" -ForegroundColor Cyan
Get-ADGroup -Filter "Name -like 'GG_*'" |
    Select-Object Name, GroupScope, GroupCategory |
    Format-Table -AutoSize

Write-Host "`n--- DNS kontrolü ---" -ForegroundColor Cyan
$domainName = (Get-ADDomain).DNSRoot
Resolve-DnsName -Name $domainName -ErrorAction Continue

Write-Host "`n--- Domain Controller tanılama ---" -ForegroundColor Cyan
dcdiag /q

Write-Host "`nKontroller tamamlandı. Hata veya uyarı varsa yukarıdaki çıktıyı incele." -ForegroundColor Green
