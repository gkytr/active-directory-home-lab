# Active Directory Home Lab

A practical Windows Server lab demonstrating Active Directory Domain Services (AD DS), DNS, organizational units (OUs), security groups, user provisioning, Group Policy, and domain-joined client verification.

> **Lab environment only.** Use isolated virtual machines and fictional accounts. Review every script before running it. Never use these examples in a production domain without proper testing and change control.

## Lab architecture

| Component | Hostname | Example |
|---|---|---|
| Domain controller | DC01 | Windows Server 2022/2025 Evaluation |
| Client | CLIENT01 | Windows 10/11 Pro or Enterprise |
| AD domain | corp.example.test | Private lab namespace |
| NetBIOS | CORP | CORP |
| DC IPv4 | 192.168.10.10/24 | Example; adapt to your network |
| Client DNS | 192.168.10.10 | Domain controller |

Use an **Internal** or **Host-only** virtual network. Do not expose the domain controller directly to the public internet.

## Skills demonstrated

- Installing the Active Directory Domain Services role.
- Creating a new AD forest and configuring DNS.
- Designing a basic OU hierarchy.
- Creating fictional test users and role-based security groups.
- Creating and linking a starter Group Policy Object (GPO).
- Joining a Windows client to the domain.
- Running basic AD DS and DNS health checks.

## Repository structure

```text
active-directory-home-lab/
├── scripts/
│   ├── 01-Install-ADDSForest.ps1
│   ├── 02-Create-Directory-Objects.ps1
│   ├── 03-Create-Baseline-GPO.ps1
│   └── 04-Verify-Lab.ps1
├── docs/
│   ├── TOPOLOGY.md
│   └── SCREENSHOT-CHECKLIST.md
├── .gitignore
├── LICENSE
└── README.md
```

## Build guide

1. Create two VMs and connect them to the same private virtual switch.
2. Install Windows Server on **DC01**, rename the server, and configure a static IPv4 address.
3. Open PowerShell as Administrator and run `scripts/01-Install-ADDSForest.ps1`.
4. After the server restarts, sign in as `CORP\\Administrator`.
5. Run `scripts/02-Create-Directory-Objects.ps1` to create the sample OUs, users, and groups.
6. Run `scripts/03-Create-Baseline-GPO.ps1`.
7. Configure **CLIENT01** to use `192.168.10.10` as its DNS server, then join it to `corp.example.test`.
8. Run `scripts/04-Verify-Lab.ps1` on DC01.
9. Capture your own screenshots and add them under `docs/screenshots/`. Review them for private information first.

## Scripts

| Script | Purpose |
|---|---|
| `01-Install-ADDSForest.ps1` | Installs AD DS and promotes the server into a new forest |
| `02-Create-Directory-Objects.ps1` | Creates OUs, demo users, security groups, and memberships |
| `03-Create-Baseline-GPO.ps1` | Creates and links a starter workstation GPO |
| `04-Verify-Lab.ps1` | Checks domain information, DCs, OUs, users, groups, DNS, and DCDIAG |

Run scripts one at a time. The demo user script prompts for passwords securely; no passwords are stored in this repository.

## Portfolio evidence

Add genuine screenshots from your completed lab:

- Server Manager showing AD DS installed.
- Active Directory Users and Computers showing the OU structure.
- Demo users and security group memberships.
- Group Policy Management showing the linked GPO.
- CLIENT01 successfully joined to the domain.
- Successful DNS lookup and health-check output.

See [docs/SCREENSHOT-CHECKLIST.md](docs/SCREENSHOT-CHECKLIST.md).

## Troubleshooting

- Confirm both VMs are connected to the same virtual network.
- Confirm DC01 has a static IP address.
- Confirm CLIENT01 uses the domain controller as its DNS server.
- Check time synchronization; Kerberos authentication is sensitive to clock differences.
- Run `ipconfig /all`, `nslookup corp.example.test`, and `dcdiag`.
- Avoid configuring public DNS servers as the client's preferred DNS while joining the AD domain.

## Security considerations

- This is a learning lab, not a production security baseline.
- Use fictional test identities and unique lab passwords.
- Never commit passwords, recovery keys, private keys, VM disks, or real user data.
- Keep the domain controller isolated from untrusted networks.
- Review and test scripts before execution.

## References

- [Microsoft Learn — Install Active Directory Domain Services](https://learn.microsoft.com/windows-server/identity/ad-ds/deploy/install-active-directory-domain-services--level-100-)
- [Microsoft Learn — Install-ADDSForest](https://learn.microsoft.com/en-us/powershell/module/addsdeployment/install-addsforest?view=windowsserver2025-ps)
