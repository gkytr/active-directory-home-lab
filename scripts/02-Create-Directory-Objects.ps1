#requires -RunAsAdministrator
<#
.SYNOPSIS
Örnek OU yapısını, test kullanıcılarını ve güvenlik gruplarını oluşturur.

.NOTES
DC01 kurulup yeniden başladıktan sonra çalıştır.
Etki alanı bilgilerini sunucudan otomatik alır. Böylece farklı bir
domain adı kullandıysan betiğin başını elle değiştirmen gerekmez.
#>
[CmdletBinding()]
param(
    [string]$DomainDN,
    [string]$DomainDnsName
)

$ErrorActionPreference = "Stop"
Import-Module ActiveDirectory

$domain = Get-ADDomain
if (-not $DomainDN) { $DomainDN = $domain.DistinguishedName }
if (-not $DomainDnsName) { $DomainDnsName = $domain.DNSRoot }

Write-Host "Etki alanı: $DomainDnsName" -ForegroundColor Cyan

# Önce ana OU'ları, sonra bunların altındaki OU'ları oluşturuyoruz.
$ouDefinitions = @(
    @{ Name = "Sirket"; Path = $DomainDN },
    @{ Name = "Kullanicilar"; Path = "OU=Sirket,$DomainDN" },
    @{ Name = "Gruplar"; Path = "OU=Sirket,$DomainDN" },
    @{ Name = "Bilgisayarlar"; Path = "OU=Sirket,$DomainDN" },
    @{ Name = "Servis Hesaplari"; Path = "OU=Sirket,$DomainDN" },
    @{ Name = "BT"; Path = "OU=Kullanicilar,OU=Sirket,$DomainDN" },
    @{ Name = "Insan Kaynaklari"; Path = "OU=Kullanicilar,OU=Sirket,$DomainDN" },
    @{ Name = "Satis"; Path = "OU=Kullanicilar,OU=Sirket,$DomainDN" },
    @{ Name = "Istemciler"; Path = "OU=Bilgisayarlar,OU=Sirket,$DomainDN" },
    @{ Name = "Sunucular"; Path = "OU=Bilgisayarlar,OU=Sirket,$DomainDN" }
)

foreach ($ou in $ouDefinitions) {
    $dn = "OU=$($ou.Name),$($ou.Path)"
    $existingOU = Get-ADOrganizationalUnit -Identity $dn -ErrorAction SilentlyContinue

    if (-not $existingOU) {
        New-ADOrganizationalUnit -Name $ou.Name -Path $ou.Path -ProtectedFromAccidentalDeletion $true
        Write-Host "OU oluşturuldu: $dn" -ForegroundColor Green
    }
    else {
        Write-Host "Zaten var, geçiyorum: $dn" -ForegroundColor DarkGray
    }
}

# Departmanlara göre global güvenlik grupları.
$groupsPath = "OU=Gruplar,OU=Sirket,$DomainDN"
$groupNames = @("GG_BT_Destek", "GG_InsanKaynaklari", "GG_Satis")

foreach ($groupName in $groupNames) {
    $group = Get-ADGroup -Filter "SamAccountName -eq '$groupName'" -ErrorAction SilentlyContinue

    if (-not $group) {
        New-ADGroup -Name $groupName -SamAccountName $groupName -GroupScope Global -GroupCategory Security -Path $groupsPath
        Write-Host "Grup oluşturuldu: $groupName" -ForegroundColor Green
    }
    else {
        Write-Host "Grup zaten var: $groupName" -ForegroundColor DarkGray
    }
}

# Tamamen örnek hesaplar. Parolaları çalıştırırken kendin belirleyeceksin.
$demoUsers = @(
    @{ Name = "Demo BT Kullanıcısı"; GivenName = "Demo"; Surname = "BT"; Sam = "demo.bt"; OU = "BT"; Group = "GG_BT_Destek" },
    @{ Name = "Demo IK Kullanıcısı"; GivenName = "Demo"; Surname = "IK"; Sam = "demo.ik"; OU = "Insan Kaynaklari"; Group = "GG_InsanKaynaklari" },
    @{ Name = "Demo Satis Kullanıcısı"; GivenName = "Demo"; Surname = "Satis"; Sam = "demo.satis"; OU = "Satis"; Group = "GG_Satis" }
)

foreach ($user in $demoUsers) {
    $userPath = "OU=$($user.OU),OU=Kullanicilar,OU=Sirket,$DomainDN"
    $existingUser = Get-ADUser -Filter "SamAccountName -eq '$($user.Sam)'" -ErrorAction SilentlyContinue

    if (-not $existingUser) {
        $securePassword = Read-Host "$($user.Sam) için geçici parola belirle" -AsSecureString

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

        Write-Host "Kullanıcı oluşturuldu: $($user.Sam)" -ForegroundColor Green
    }
    else {
        Write-Host "Kullanıcı zaten var: $($user.Sam)" -ForegroundColor DarkGray
    }

    # Betik tekrar çalıştırılırsa aynı üyeliği yeniden eklemeye çalışmasın.
    $members = Get-ADGroupMember -Identity $user.Group -ErrorAction SilentlyContinue
    if ($members.SamAccountName -notcontains $user.Sam) {
        Add-ADGroupMember -Identity $user.Group -Members $user.Sam
        Write-Host "$($user.Sam), $($user.Group) grubuna eklendi." -ForegroundColor Green
    }
}

Write-Host "OU, kullanıcı ve grup işlemleri tamamlandı." -ForegroundColor Green
