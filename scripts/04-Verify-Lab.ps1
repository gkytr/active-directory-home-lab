#requires -RunAsAdministrator
<#
.SYNOPSIS
Etki alanı, OU, kullanıcı, grup ve DNS tarafında temel kontroller yapar.
.NOTES
DC01 üzerinde, yönetici olarak çalıştır. Her kontrol ayrı raporlanır;
başarısız bir kontrol genel sonucu başarısız yapar.
#>
[CmdletBinding()]
$ErrorActionPreference = "Stop"
$failures = [System.Collections.Generic.List[string]]::new()

function Invoke-LabCheck {
    param([Parameter(Mandatory)][string]$Name,[Parameter(Mandatory)][scriptblock]$Action)
    Write-Host "`n--- $Name ---" -ForegroundColor Cyan
    try {
        & $Action
        Write-Host "[OK] $Name" -ForegroundColor Green
    } catch {
        $failures.Add($Name)
        Write-Host "[HATA] $Name : $($_.Exception.Message)" -ForegroundColor Red
    }
}

Invoke-LabCheck -Name "Active Directory modülü" -Action { Import-Module ActiveDirectory -ErrorAction Stop }
if (Get-Module -Name ActiveDirectory) {
    Invoke-LabCheck -Name "Etki alanı bilgisi" -Action {
        Get-ADDomain -ErrorAction Stop | Select-Object DNSRoot,NetBIOSName,DomainMode | Format-List
    }
    Invoke-LabCheck -Name "Etki alanı denetleyicileri" -Action {
        Get-ADDomainController -Filter * -ErrorAction Stop | Select-Object HostName,IPv4Address,Site,IsGlobalCatalog | Format-Table -AutoSize
    }
    Invoke-LabCheck -Name "OU listesi" -Action {
        Get-ADOrganizationalUnit -Filter * -ErrorAction Stop | Select-Object Name,DistinguishedName | Format-Table -AutoSize
    }
    Invoke-LabCheck -Name "Demo kullanıcılar" -Action {
        Get-ADUser -Filter "SamAccountName -like 'demo.*'" -Properties Enabled -ErrorAction Stop | Select-Object Name,SamAccountName,Enabled | Format-Table -AutoSize
    }
    Invoke-LabCheck -Name "Güvenlik grupları" -Action {
        Get-ADGroup -Filter "Name -like 'GG_*'" -ErrorAction Stop | Select-Object Name,GroupScope,GroupCategory | Format-Table -AutoSize
    }
    Invoke-LabCheck -Name "DNS çözümlemesi" -Action {
        $domainName = (Get-ADDomain -ErrorAction Stop).DNSRoot
        Resolve-DnsName -Name $domainName -ErrorAction Stop | Format-Table -AutoSize
    }
} else { $failures.Add("Active Directory modülü") }

Invoke-LabCheck -Name "Domain Controller tanılama (dcdiag)" -Action {
    $output = & dcdiag /q 2>&1
    if ($LASTEXITCODE -ne 0) {
        $output | Write-Host
        throw "dcdiag çıkış kodu: $LASTEXITCODE"
    }
    if ($output) { $output | Write-Host }
}

Write-Host "`n--- Genel sonuç ---" -ForegroundColor Cyan
if ($failures.Count -gt 0) {
    Write-Host "Başarısız kontrol sayısı: $($failures.Count)" -ForegroundColor Red
    $failures | ForEach-Object { Write-Host " - $_" -ForegroundColor Red }
    exit 1
}
Write-Host "Tüm kontroller başarılı." -ForegroundColor Green
exit 0
