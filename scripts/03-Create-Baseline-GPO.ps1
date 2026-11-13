#requires -RunAsAdministrator
<#
.SYNOPSIS
İstemciler için bir GPO oluşturur ve İstemciler OU'suna bağlar.

.NOTES
Bu örnekte güvensiz SMB misafir oturumları kapatılır.
Bu ayar kapsamlı bir güvenlik standardı değildir; lab çalışması için
başlangıç seviyesinde bir örnektir.
#>
[CmdletBinding()]
param(
    [string]$DomainDN,
    [string]$GpoName = "LAB - Istemci Temel Ayarlari"
)

$ErrorActionPreference = "Stop"
Import-Module ActiveDirectory
Import-Module GroupPolicy

if (-not $DomainDN) {
    $DomainDN = (Get-ADDomain).DistinguishedName
}

$workstationsOU = "OU=Istemciler,OU=Bilgisayarlar,OU=Sirket,$DomainDN"

# Önce GPO var mı diye bak; varsa yeniden oluşturma.
$gpo = Get-GPO -Name $GpoName -ErrorAction SilentlyContinue
if (-not $gpo) {
    $gpo = New-GPO -Name $GpoName -Comment "Lab istemcileri için temel ayarlar."
    Write-Host "GPO oluşturuldu: $GpoName" -ForegroundColor Green
}
else {
    Write-Host "GPO zaten mevcut, mevcut ayarlar korunacak." -ForegroundColor DarkGray
}

# İstemcilerde güvensiz SMB misafir oturumlarına izin verme.
Set-GPRegistryValue `
    -Name $GpoName `
    -Key "HKLM\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation" `
    -ValueName "AllowInsecureGuestAuth" `
    -Type DWord `
    -Value 0 | Out-Null

# GPO bağlantısı daha önce kurulmadıysa ekle.
$existingLinks = (Get-GPInheritance -Target $workstationsOU).GpoLinks
if (-not ($existingLinks | Where-Object { $_.DisplayName -eq $GpoName })) {
    New-GPLink -Name $GpoName -Target $workstationsOU -LinkEnabled Yes | Out-Null
    Write-Host "GPO, İstemciler OU'suna bağlandı." -ForegroundColor Green
}
else {
    Write-Host "GPO bağlantısı zaten var." -ForegroundColor DarkGray
}

Write-Host "İşlem bitti. İstemcide gpupdate /force komutuyla ilkeyi yenileyebilirsin." -ForegroundColor Cyan
