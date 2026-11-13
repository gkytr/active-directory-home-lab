# Active Directory Ev Laboratuvarı

Bu repoda VMware üzerinde küçük bir Windows Server ağı kuruyorum. Amacım, IT destek ve sistem yönetimi tarafında sık karşılaşılan işleri yalnızca teoride bırakmadan kendi bilgisayarımda denemek.

İlk aşamada bir etki alanı denetleyicisi (DC01) kuracağım. Ardından Active Directory, DNS, kullanıcılar, gruplar ve Group Policy ayarlarını yapılandırıp ikinci bir Windows bilgisayarı etki alanına dahil edeceğim.

> **Not:** Bu repo kurulum sırasında kullandığım dosyaları ve notları içeriyor. Henüz kurulumu tamamlamadığım bölümleri tamamlanmış gibi göstermiyorum; ekran görüntülerini ve test sonuçlarını lab çalıştıkça ekleyeceğim.

## Kuracağım ortam

| Makine / Ayar | Değer |
|---|---|
| Sanallaştırma | VMware Workstation |
| Sunucu | DC01 – Windows Server 2025 |
| İstemci | CLIENT01 – Windows 11 Pro |
| Etki alanı | corp.example.test |
| NetBIOS adı | CORP |
| DC01 IP adresi | 192.168.10.10 |
| İstemcinin DNS adresi | 192.168.10.10 |
| Sanal ağ | Host-only |

IP adresleri örnek olarak seçildi. Kendi bilgisayarındaki diğer ağlarla çakışmaması için kurulumdan önce kontrol edeceğim.

## Bu çalışmada neler var?

- Windows Server üzerine AD DS rolünü kurmak ve yeni bir forest oluşturmak
- DNS'in etki alanıyla birlikte nasıl çalıştığını görmek
- Departmanlara göre OU yapısı hazırlamak
- Örnek kullanıcılar ve güvenlik grupları oluşturmak
- Bir Group Policy hazırlayıp istemci OU'suna bağlamak
- Windows istemciyi domaine dahil etmek
- DNS ve domain controller kontrollerini çalıştırmak

## Klasörler

```text
active-directory-home-lab/
├── scripts/                 # Kurulum ve kontrol PowerShell dosyaları
├── docs/                    # Ağ şeması ve kurulum notları
├── .gitignore
├── LICENSE
└── README.md
```

## Kurulum sırası

1. VMware'de DC01 adında bir sanal makine oluştur.
2. Windows Server 2025'i kur, bilgisayar adını DC01 yap ve sabit IP adresini ayarla.
3. PowerShell'i yönetici olarak açıp `scripts/01-Install-ADDSForest.ps1` dosyasını çalıştır.
4. Sunucu yeniden başladıktan sonra `scripts/02-Create-Directory-Objects.ps1` dosyasıyla OU, kullanıcı ve grupları oluştur.
5. `scripts/03-Create-Baseline-GPO.ps1` dosyasını çalıştır.
6. CLIENT01 sanal makinesini oluştur. DNS adresini DC01'in IP adresi yap ve bilgisayarı `corp.example.test` etki alanına kat.
7. Son kontrolleri DC01 üzerinde `scripts/04-Verify-Lab.ps1` ile yap.

VMware ayarları ve Windows Server kurulum adımları için [kurulum notlarına](docs/VMWARE-KURULUM.md) bakabilirsin.

## PowerShell dosyaları

| Dosya | Ne yapıyor? |
|---|---|
| `01-Install-ADDSForest.ps1` | AD DS rolünü kurup yeni etki alanını oluşturuyor. |
| `02-Create-Directory-Objects.ps1` | OU'ları, örnek kullanıcıları ve güvenlik gruplarını hazırlıyor. |
| `03-Create-Baseline-GPO.ps1` | İstemciler için GPO oluşturup ilgili OU'ya bağlıyor. |
| `04-Verify-Lab.ps1` | Domain, DNS, kullanıcı ve domain controller kontrollerini yapıyor. |

Scriptleri sırayla ve yönetici yetkisiyle çalıştır. Kullanıcı oluşturma sırasında parolaları ekrandan güvenli şekilde gireceksin; parolalar dosyalara yazılmıyor.

## Ekran görüntüleri

Kurulum tamamlandıkça kendi ortamımdan ekran görüntüleri ekleyeceğim. Özellikle şu bölümleri göstermek istiyorum:

- Server Manager'da AD DS rolünün kurulu olması
- Active Directory Users and Computers içinde OU yapısı
- Örnek kullanıcılar ve grup üyelikleri
- Group Policy Management ekranı
- CLIENT01'in domaine katılmış olması
- DNS sorgusu ve `dcdiag` kontrol sonucu

Ekran görüntüsü eklemeden önce parola, lisans anahtarı, kişisel kullanıcı adı ve benzeri bilgileri kapatacağım. Liste için [ekran görüntüsü kontrol dosyasına](docs/SCREENSHOT-CHECKLIST.md) bak.

## Küçük notlar

Bu çalışma bir ev laboratuvarı. Gerçek şirket ağına doğrudan uygulanacak hazır bir güvenlik standardı değil. Denemeleri yalnızca sanal makinelerde ve gerçek kullanıcı verisi kullanmadan yapıyorum.

Bir sorun çıkarsa ilk bakacağım yerler ağ bağlantısı, DC01'in sabit IP adresi, istemcinin DNS ayarı ve saat eşitlemesi olacak. Gerekli olduğunda `ipconfig /all`, `nslookup corp.example.test` ve `dcdiag` komutlarıyla kontrol edeceğim.

## Yararlanılan kaynak

- [Microsoft Learn – Active Directory Etki Alanı Hizmetleri'ni yükleme](https://learn.microsoft.com/tr-tr/windows-server/identity/ad-ds/deploy/install-active-directory-domain-services--level-100-)
- [Microsoft Learn – Install-ADDSForest komutu](https://learn.microsoft.com/tr-tr/powershell/module/addsdeployment/install-addsforest?view=windowsserver2025-ps)
