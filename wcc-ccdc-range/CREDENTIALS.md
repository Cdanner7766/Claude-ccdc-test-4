# WCC CCDC Range - Credentials Reference

## Default Ludus Accounts (Always Work)

### Windows Systems
- **Local Admin**: `localuser` / `password`
- **Domain User**: `LUDUS\domainuser` / `password`
- **Domain Admin**: `LUDUS\domainadmin` / `password`

### Linux Systems
- **Default User**: `debian` / `debian` (has sudo)

## CCDC Practice Accounts (Created by Custom Roles)

### Domain Accounts (on DC01)
These are **additional** accounts created for practice, alongside Ludus defaults:

- **Service Account**: `LUDUS\svc_sql` / `Summer2024!` (Kerberoastable - has SPN)
- **Test Users**:
  - `LUDUS\jdoe` / `Welcome123!`
  - `LUDUS\asmith` / `Password1!`
  - `LUDUS\bwilliams` / `Spring2024!`
- **CCDC Admin**: `LUDUS\ccdc_admin` / `ChangeMe123!` (Domain Admin)

### Scoring Engine
- **Web Access**: `http://10.{range_id}.99.10`
- **Default Login**: `admin` / `changeme`
- **⚠️ CHANGE IMMEDIATELY after first login!**

### SQL Server (DB01)
- **SA Account**: `sa` / `ChangeMe123!`
- **Windows Auth**: Use `LUDUS\domainadmin` / `password`

### MySQL (LAMP01)
- **Root**: `root` / `ChangeMe123!`

### FTP (FTP01)
- **FTP User**: `ftpuser` / `ChangeMe123!`
- **SSH/SFTP**: `debian` / `debian`

### Kali Red Team Box
- **Login**: `kali` / `kali`
- **Root**: `sudo su -`

## Network Information

**Domain**: LUDUS (ludus.domain)
**DNS**: 10.{range_id}.10.2 (DC01)
**DHCP**: 10.{range_id}.10.7 (DNS01) - Pool: .100-.150

## IP Address Scheme

| Host | IP | Purpose |
|------|-----|---------|
| Scoring Engine | 10.{range_id}.99.10 | Service monitoring |
| Kali (Red Team) | 10.{range_id}.99.50 | Attack box |
| DC01 | 10.{range_id}.10.2 | Domain Controller |
| FS01 | 10.{range_id}.10.3 | File Server |
| WEB01 | 10.{range_id}.10.4 | IIS Web Server |
| MAIL01 | 10.{range_id}.10.5 | Exchange Server |
| DB01 | 10.{range_id}.10.6 | SQL Server |
| DNS01 | 10.{range_id}.10.7 | BIND DNS + DHCP |
| LAMP01 | 10.{range_id}.10.8 | Apache/MySQL/PHP |
| FTP01 | 10.{range_id}.10.9 | FTP/SFTP Server |
| WS01 | 10.{range_id}.10.20 | Workstation 1 |
| WS02 | 10.{range_id}.10.21 | Workstation 2 |

## Blue Team Quick Start

1. **Login to any Windows VM**:
   - Use: `LUDUS\domainadmin` / `password`
   - Or: `localuser` / `password` (local admin)

2. **First Tasks**:
   - Change ALL passwords immediately!
   - Enable Windows Firewall
   - Disable SMBv1
   - Review open shares
   - Check for weak user accounts

3. **Access Scoring Engine**:
   - Browse to: `http://10.{range_id}.99.10`
   - Login: `admin` / `changeme`
   - Monitor service uptime

## Red Team Quick Start

1. **Login to Kali**: `kali` / `kali` at 10.{range_id}.99.50

2. **Initial Recon**:
   ```bash
   cd /root/ccdc
   source range-config.sh
   ./enum.sh
   ```

3. **Target Credentials**:
   - Try default Ludus creds first: `LUDUS\domainuser` / `password`
   - Try weak passwords: `Welcome123!`, `Password1!`, `Summer2024!`
   - Target service account for Kerberoasting: `LUDUS\svc_sql`

## Important Notes

⚠️ **Domain Name**: The domain is `LUDUS` (not WCC), NetBIOS name `LUDUS`, DNS name `ludus.domain`

⚠️ **Ludus Accounts Persist**: Even after running custom CCDC roles, the default Ludus accounts (`domainadmin`, `domainuser`, `localuser`) will still work

⚠️ **Password Changes**: Blue team should change ALL default passwords as their first task

⚠️ **No Internet**: VMs are intentionally isolated - this is normal for CCDC practice

## Troubleshooting

**Can't login to domain?**
- Try: `LUDUS\domainadmin` / `password` (backslash format)
- Or: `domainadmin@ludus.domain` / `password` (UPN format)
- Or: `localuser` / `password` (local admin, always works)

**Services not responding?**
- Check scoring engine dashboard for status
- Verify VMs are powered on: `ludus range status`
- Domain services need DC01 running first

**VMs not joined to domain?**
- Check if DC01 fully deployed before other VMs
- Power cycle: DC01 first, then others
- Verify domain in `ipconfig /all` shows `ludus.domain`
