# WCC CCDC Range - Quick Start Guide

## Pre-Deployment Checklist

- [ ] Ludus server installed and accessible
- [ ] Ludus user created with API key
- [ ] WireGuard VPN configured and connected
- [ ] Ludus CLI installed locally
- [ ] All required templates built:
  - [ ] debian-11-x64-server-template
  - [ ] debian-12-x64-server-template  
  - [ ] win11-22h2-x64-enterprise-template
  - [ ] win2022-server-x64-template
- [ ] Minimum hardware: 64GB RAM, 16 CPU cores, 400GB disk

## Deployment Steps

### 1. Clone Repository
```bash
git clone https://github.com/whatcom-cc/wcc-ccdc-range.git
cd wcc-ccdc-range
```

### 2. Add Roles (Run all commands)
```bash
ludus ansible role add -d ./roles/wcc_scoring_engine/
ludus ansible role add -d ./roles/wcc_sysmon_install/
ludus ansible role add -d ./roles/wcc_ad_vulnerable_setup/
ludus ansible role add -d ./roles/wcc_fileserver_setup/
ludus ansible role add -d ./roles/wcc_iis_ecommerce_setup/
ludus ansible role add -d ./roles/wcc_exchange_setup/
ludus ansible role add -d ./roles/wcc_sqlserver_setup/
ludus ansible role add -d ./roles/wcc_bind_dhcp_setup/
ludus ansible role add -d ./roles/wcc_linux_logging/
ludus ansible role add -d ./roles/wcc_lamp_setup/
ludus ansible role add -d ./roles/wcc_vsftpd_setup/
```

### 3. Verify Roles
```bash
ludus ansible roles list
```

Expected output should show all `wcc_*` roles.

### 4. Set Range Configuration
```bash
ludus range config set -f ./range.yaml
```

### 5. Deploy Range
```bash
ludus range deploy
```

### 6. Monitor Deployment
In a separate terminal:
```bash
ludus range logs -f
```

**Expected deployment time**: 45-90 minutes depending on hardware

### 7. Check for Errors
```bash
ludus range errors
```

If errors occur, see Troubleshooting section in README.md

### 8. Post-Deployment Power Cycle

**Important**: After deployment, power cycle VMs in order:

```bash
# Power off all VMs
ludus range power off

# Wait 30 seconds
sleep 30

# Power on DC first (it's critical for domain services)
ludus range power on --vm-name "*-dc01"

# Wait 120 seconds (let AD fully start)
sleep 120

# Power on everything else
ludus range power on
```

### 9. Verify Scoring Engine

1. Connect to Ludus via WireGuard VPN
2. Open browser to `http://10.{range_id}.99.10`
3. Login with: `admin` / `changeme`
4. **Immediately change password!**

### 10. Start Scoring

1. In scoring dashboard, navigate to Configuration
2. Set "Running" to "1"
3. Click "Save Configuration"
4. Watch scoreboard populate with service checks

## Quick Reference

### Access Information

| Component | IP Address | Credentials |
|-----------|-----------|-------------|
| Scoring Engine | 10.{range_id}.99.10 | admin / changeme |
| DC01 (AD) | 10.{range_id}.10.2 | LUDUS\domainadmin / password |
| FS01 (File) | 10.{range_id}.10.3 | LUDUS\domainadmin / password |
| WEB01 (IIS) | 10.{range_id}.10.4 | LUDUS\domainadmin / password |
| MAIL01 (Exchange) | 10.{range_id}.10.5 | LUDUS\domainadmin / password |
| DB01 (SQL) | 10.{range_id}.10.6 | LUDUS\domainadmin / password |
| DNS01 (BIND) | 10.{range_id}.10.7 | debian / debian |
| LAMP01 (Apache) | 10.{range_id}.10.8 | debian / debian |
| FTP01 (vsftpd) | 10.{range_id}.10.9 | debian / debian |
| WS01/WS02 | 10.{range_id}.10.20-21 | LUDUS\domainadmin / password |
| Kali (Red Team) | 10.{range_id}.99.50 | kali / kali |

**Alternative**: Use `localuser` / `password` for local admin on any Windows machine

**Complete list**: See [CREDENTIALS.md](CREDENTIALS.md) for all CCDC practice accounts

### Common Commands

```bash
# View range status
ludus range status

# View all VMs
ludus range list

# Power operations
ludus range power on
ludus range power off
ludus range power restart

# Remove range completely
ludus range rm

# Check Ansible logs
ludus range logs

# Test single service
ludus range test
```

## Verification Checklist

After deployment, verify each service:

### Windows Services
- [ ] DC01: Can ping, RDP connects, AD Users & Computers works
- [ ] FS01: Can access \\fs01\Public share
- [ ] WEB01: Browser to http://10.{range_id}.10.4 shows IIS page
- [ ] MAIL01: OWA accessible at https://10.{range_id}.10.5/owa
- [ ] DB01: SQL Server Management Studio connects
- [ ] WS01/WS02: Can RDP and login with domain account

### Linux Services  
- [ ] DNS01: `nslookup ludus.domain 10.{range_id}.10.7` resolves
- [ ] LAMP01: Browser to http://10.{range_id}.10.8 shows webpage
- [ ] FTP01: FTP client can connect to 10.{range_id}.10.9

### Scoring Engine
- [ ] Web interface accessible
- [ ] All services showing on scoreboard
- [ ] Checks running every 2 minutes
- [ ] Services turning green as they come online

## Troubleshooting Quick Fixes

### Issue: Can't access any VMs
**Fix**: Verify WireGuard VPN is connected
```bash
# Check WireGuard status
sudo wg show
```

### Issue: Scoring engine shows all services down
**Fix**: VMs may still be booting. Wait 5-10 minutes after power on.

### Issue: DC01 won't start or AD not working
**Fix**: 
```bash
# SSH to DC01 via Proxmox console
# Check disk space
Get-PSDrive C

# Restart AD services
Restart-Service NTDS -Force
Restart-Service DNS -Force
```

### Issue: Exchange won't start
**Fix**: Exchange needs time and resources
1. Verify MAIL01 has 8GB RAM allocated
2. Wait 15 minutes after power on
3. Check Event Viewer > Applications and Services > Microsoft > Exchange

### Issue: Ansible role failed during deploy
**Fix**: 
```bash
# View specific error
ludus range errors

# Often can manually complete setup
# SSH to affected VM
# Run role tasks manually
```

## Limited Resource Deployment

If you have less than 64GB RAM:

### Option 1: Skip Exchange
Comment out MAIL01 in `range.yaml`:
```yaml
# - vm_name: "{{ range_id }}-mail01"
#   hostname: "{{ range_id }}-mail01"
#   ...
```

This saves 8GB RAM.

### Option 2: Reduce RAM Allocations
Edit `range.yaml` and reduce RAM:
- DC01: 4GB → 3GB
- FS01, WEB01: 4GB → 2GB  
- DB01: 6GB → 4GB
- LAMP01: 4GB → 2GB
- WS01/WS02: 4GB → 2GB

**Minimum configuration**: ~48GB RAM

### Option 3: Deploy Subset
Deploy core services only:
- DC01 (AD)
- WEB01 (IIS)
- DNS01 (BIND)
- LAMP01 (Apache)

Comment out others in range.yaml.

## Next Steps

1. Read full README.md for detailed information
2. Review practice scenarios
3. Assign team roles
4. Schedule first practice session
5. Customize scoring point values if desired
6. Set up Red Team access if applicable

## Support

Questions? Contact:
- WCC CCDC Coach
- Team Slack: #ccdc-practice
- Ludus Docs: https://docs.ludus.cloud

---

**Ready to defend? Power up the range and start practicing!** 🚀
