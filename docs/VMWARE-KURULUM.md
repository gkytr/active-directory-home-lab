# VMware'de sanal makineleri hazırlama

Bu notları kendi lab ortamımı kurarken takip edeceğim. Menü isimleri VMware sürümüne göre ufak farklılık gösterebilir.

## 1. DC01 makinesini oluştur

VMware Workstation'da **Create a New Virtual Machine** seçeneğiyle yeni makine oluştur.

Önerilen başlangıç ayarları:

| Ayar | Değer |
|---|---|
| Makine adı | DC01 |
| İşletim sistemi | Windows Server 2025 |
| İşlemci | 2 çekirdek |
| Bellek | 4 GB (bilgisayarın uygunsa) |
| Disk | 60 GB |
| Ağ | Host-only |
| ISO | Windows Server 2025 değerlendirme ISO'su |

Bilgisayarın belleği 8 GB ise aynı anda iki sanal makineyi çalıştırmak zor olabilir. Önce yalnızca DC01 ile başlamak daha mantıklı.

## 2. Windows Server kurulumu

1. Sanal makineyi başlat ve ISO dosyasından aç.
2. Dil, saat ve klavye seçeneklerinde Türkçe ayarları seç.
3. **Windows Server 2025 Standard Evaluation (Desktop Experience)** sürümünü seç. Desktop Experience grafik arayüzlü sürümdür.
4. Kurulumu tamamla ve güçlü bir yerel Administrator parolası belirle.
5. Sunucu açılınca bilgisayar adını `DC01` olarak değiştir ve yeniden başlat.

## 3. DC01 için ağ ayarı

Ağ bağdaştırıcısının Host-only olduğundan emin ol. Windows ağ ayarlarından IPv4 bilgilerini, kullandığın VMware Host-only ağının alt ağına uygun şekilde düzenle.

Örnek IP planı:

- IP adresi: `192.168.10.10`
- Alt ağ maskesi: `255.255.255.0`
- DNS: Kurulumdan sonra DC01'in kendi adresi (`192.168.10.10`)

Bu adresleri doğrudan kullanmadan önce VMware'in Host-only ağının gerçekten `192.168.10.0/24` aralığında olduğunu kontrol et. Farklıysa bu projedeki IP planını da aynı ağa göre değiştir.

## 4. Active Directory kurulumuna geç

Sunucu yeniden başladıktan sonra PowerShell'i yönetici olarak aç. Repodaki `scripts/01-Install-ADDSForest.ps1` dosyasını sunucuya kopyalayıp çalıştır.

İlk kurulumda etki alanı adı olarak `corp.example.test` kullanacağız. Betik DSRM parolasını soracak. Bu parola normal Administrator parolasından ayrı olabilir; güvenli bir yerde sakla.

Kurulum bitince sunucu yeniden başlar. Sonrasında sıradaki betiklerle OU, kullanıcı ve grup yapısını hazırlayacağız.

## 5. İstemci makinesi

DC01 çalışır hale geldikten sonra ikinci bir sanal makine oluştur:

- Makine adı: `CLIENT01`
- İşletim sistemi: Windows 11 Pro veya Enterprise
- Bellek: 4 GB veya bilgisayarının kaldırabileceği kadar
- Ağ: DC01 ile aynı Host-only ağ
- DNS: DC01'in IP adresi

Windows Home sürümü etki alanına katılamaz; Pro veya Enterprise kullan.

Domaine katılmadan önce istemcide `nslookup corp.example.test` komutuyla DNS çözümlemesini kontrol et. Sonra Windows'un etki alanına katılma ekranından `corp.example.test` bilgisini gir.

## Küçük hatırlatma

Bu ağ bir eğitim laboratuvarı. Domain Controller'ı internete açık hale getirme ve gerçek kullanıcı hesapları ya da parolaları kullanma.
