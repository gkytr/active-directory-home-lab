# Ağ yapısı

Lab ortamında iki sanal makine olacak. DC01 hem Active Directory hem de DNS hizmetini sağlayacak. CLIENT01 ise bu etki alanına katılan normal bir Windows bilgisayarı olacak.

```text
                 VMware Host-only Ağ
                         |
              +----------+----------+
              |                     |
         +----+-----+          +----+------+
         |   DC01   |          | CLIENT01  |
         | Windows  |          | Windows 11|
         | Server   |          | Pro        |
         +----+-----+          +----+------+
              |                     |
        Active Directory  <------> Domaine bağlı
        DNS: 192.168.10.10
        corp.example.test
```

## IP planı

| Makine | IP / DNS |
|---|---|
| DC01 | 192.168.10.10 (sabit IP) |
| CLIENT01 | Aynı ağdan bir IP |
| CLIENT01 DNS | 192.168.10.10 |

Bu adresler örnek. Kullandığın VMware sanal ağının alt ağıyla çakışmadığından emin ol.

## Dikkat edilecekler

- İki sanal makine de aynı Host-only ağa bağlı olmalı.
- DC01'e sabit IP verilmeli.
- CLIENT01'in DNS adresi DC01 olmalı. Domaine katılırken genel DNS adresi kullanma.
- Lab ağını ev ağından ve güvenmediğin ağlardan ayrı tut.
