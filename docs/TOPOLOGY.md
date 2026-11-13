# Lab network topology

```text
                 Private virtual switch
                         |
              +----------+----------+
              |                     |
         +----+-----+          +----+------+
         |   DC01   |          | CLIENT01  |
         | Windows  |          | Windows   |
         | Server   |          | Pro/Ent   |
         +----+-----+          +----+------+
              |                     |
        AD DS + DNS  <------------> Domain joined
        corp.example.test
        192.168.10.10
```

The IPv4 address is an example. Select a subnet that does not conflict with your home LAN, VPN, or other virtual networks.

## Network requirements

- DC01 should use a static IPv4 address.
- DC01 should use its own address for DNS after DNS is installed and configured.
- CLIENT01 must use the domain controller as its DNS server before joining the domain.
- Both VMs must be connected to the same private virtual network.
- Keep the lab isolated from untrusted networks.
