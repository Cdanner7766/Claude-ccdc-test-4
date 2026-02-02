# Whatcom Community College CCDC Practice Range

![WCC CCDC Logo](docs/wcc-ccdc-logo.png)

## Overview

This Ludus range provides a complete CCDC (Collegiate Cyber Defense Competition) practice environment for Whatcom Community College's cybersecurity team. The range simulates a small business network that students must secure, maintain, and defend against simulated attacks while keeping services operational.

## Table of Contents

- [Network Topology](#network-topology)
- [Components](#components)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Scoring System](#scoring-system)
- [Practice Scenarios](#practice-scenarios)
- [Team Roles](#team-roles)
- [Troubleshooting](#troubleshooting)

## Network Topology

```
┌─────────────────────────────────────────────────────────────┐
│                    Management Network (VLAN 99)              │
│  10.{range_id}.99.0/24                                      │
│                                                              │
│  ┌──────────┐         ┌──────────────┐                      │
│  │  Router  │         │   Scoring    │                      │
│  │ (.99.1)  │         │   Engine     │                      │
│  └─────┬────┘         │  (.99.10)    │                      │
│        │              └──────────────┘                       │
└────────┼──────────────────────────────────────────────────────┘
         │
         │ Firewall/NAT
         │
┌────────┼──────────────────────────────────────────────────────┐
│        │            Business Network (VLAN 10)                │
│  10.{range_id}.10.0/24                                       │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │                Windows Infrastructure                 │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐           │   │
│  │  │   DC01   │  │   FS01   │  │  WEB01   │           │   │
│  │  │  (.10.2) │  │  (.10.3) │  │  (.10.4) │           │   │
│  │  │  AD/DNS  │  │   SMB    │  │   IIS    │           │   │
│  │  └──────────┘  └──────────┘  └──────────┘           │   │
│  │                                                       │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐           │   │
│  │  │  MAIL01  │  │   DB01   │  │  WS01/02 │           │   │
│  │  │  (.10.5) │  │  (.10.6) │  │ (.10.20) │           │   │
│  │  │ Exchange │  │  MSSQL   │  │ Clients  │           │   │
│  │  └──────────┘  └──────────┘  └──────────┘           │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │               Linux Infrastructure                    │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐           │   │
│  │  │  DNS01   │  │  LAMP01  │  │  FTP01   │           │   │
│  │  │ (.10.7)  │  │ (.10.8)  │  │ (.10.9)  │           │   │
│  │  │BIND/DHCP │  │Apache/PHP│  │  vsftpd  │           │   │
│  │  └──────────┘  └──────────┘  └──────────┘           │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

## Components

### Scoring Engine (Outside Business Network)
- **Purpose**: Automated service availability checking and scoreboard
- **Location**: Management network (isolated from business network)
- **Access**: `http://10.{range_id}.99.10`
- **Credentials**: admin / changeme (change after first login!)

### Domain Controller (DC01)
- **IP**: `10.{range_id}.10.2`
- **Services**: Active Directory, DNS, LDAP
- **Points**: 250
- **OS**: Windows Server 2022
- **Vulnerabilities**: Weak password policy, SMBv1 enabled, firewall disabled

### File Server (FS01)
- **IP**: `10.{range_id}.10.3`
- **Services**: SMB file shares
- **Points**: 100
- **OS**: Windows Server 2022
- **Shares**: HR, Finance, IT, Public (vulnerable)

### Web Server (WEB01)
- **IP**: `10.{range_id}.10.4`
- **Services**: IIS, HTTP/HTTPS, E-commerce site
- **Points**: 300
- **OS**: Windows Server 2022
- **Vulnerabilities**: Default IIS configuration, weak SSL settings

### Mail Server (MAIL01)
- **IP**: `10.{range_id}.10.5`
- **Services**: Microsoft Exchange, SMTP, IMAP, OWA
- **Points**: 350
- **OS**: Windows Server 2022
- **Requires**: 8GB RAM minimum

### Database Server (DB01)
- **IP**: `10.{range_id}.10.6`
- **Services**: Microsoft SQL Server
- **Points**: 150
- **OS**: Windows Server 2022
- **Vulnerabilities**: Default SA password, mixed mode auth

### DNS/DHCP Server (DNS01)
- **IP**: `10.{range_id}.10.7`
- **Services**: BIND9, ISC DHCP
- **Points**: 175
- **OS**: Debian 11

### Linux Web Server (LAMP01)
- **IP**: `10.{range_id}.10.8`
- **Services**: Apache, PHP, MySQL
- **Points**: 200
- **OS**: Debian 11
- **Vulnerabilities**: Outdated packages, weak MySQL root password

### FTP Server (FTP01)
- **IP**: `10.{range_id}.10.9`
- **Services**: vsftpd, SFTP (SSH)
- **Points**: 125
- **OS**: Debian 11

### Client Workstations (WS01, WS02)
- **IPs**: `10.{range_id}.10.20`, `.21`
- **OS**: Windows 11 Enterprise
- **Purpose**: Domain-joined workstations for testing

### Red Team Attack Box (Kali)
- **IP**: `10.{range_id}.99.50`
- **Network**: Management VLAN (simulates external attacker)
- **OS**: Kali Linux
- **Purpose**: Red team operations, penetration testing
- **Tools**: Metasploit, Impacket, CrackMapExec, Responder, BloodHound, and more

## Prerequisites

Before deploying this range, ensure you have:

1. **Ludus Server**: Properly installed and configured
   - Follow: https://docs.ludus.cloud/docs/quick-start/install-ludus

2. **Ludus User**: Created with API keys and WireGuard config
   - Follow: https://docs.ludus.cloud/docs/quick-start/create-a-user

3. **Required Templates**: All templates must be built:
   ```bash
   debian-11-x64-server-template
   debian-12-x64-server-template
   win11-22h2-x64-enterprise-template
   win2022-server-x64-template
   kali-2023-x64-template  # For red team box
   ```
   - Follow: https://docs.ludus.cloud/docs/quick-start/build-templates
   - **Note**: Kali template may need to be built manually if not in default templates

4. **Ludus CLI**: Installed and configured locally
   - Follow: https://docs.ludus.cloud/docs/quick-start/using-cli-locally

5. **Hardware Requirements**:
   - **Minimum**: 68GB RAM, 18 CPU cores, 420GB disk (with Kali)
   - **Recommended**: 96GB RAM, 24 CPU cores, 500GB disk
   - **Without Mail Server**: 52GB RAM, 14 CPU cores, 320GB disk

## Installation

### Step 1: Clone the Repository

```bash
git clone https://github.com/whatcom-cc/wcc-ccdc-range.git
cd wcc-ccdc-range
```

### Step 2: Add Ansible Roles

Navigate to the role directory and add all custom roles:

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

### Step 3: Verify Roles

```bash
ludus ansible roles list
```

You should see all WCC CCDC roles listed.

### Step 4: Set Range Configuration

```bash
ludus range config set -f ./range.yaml
```

### Step 5: Deploy the Range

```bash
ludus range deploy
```

Monitor deployment progress:

```bash
ludus range logs -f
```

Check for errors:

```bash
ludus range errors
```

### Step 6: Post-Deployment Steps

After deployment completes:

1. **Shut down all VMs**
2. **Power on in order**:
   - Router first
   - DC01 second
   - All other VMs third

3. **Access Scoring Engine**:
   - Navigate to `http://10.{range_id}.99.10`
   - Login with: admin / changeme
   - **IMPORTANT**: Change the admin password immediately!

## Usage

### Starting a Practice Session

1. **Brief the Team**: Review the scenario and objectives
2. **Distribute Credentials**: Provide initial passwords
3. **Start Scoring**: On the scoring engine, enable scoring
4. **Begin Defense**: Teams log in and start hardening systems

### Default Credentials

**Windows Systems (Domain)**:
- Username: `administrator@wcc.local` or `WCC\administrator`
- Password: `ChangeMe123!`

**Linux Systems**:
- Username: `debian`
- Password: `debian`
- Root: `sudo su -`

**Scoring Engine**:
- Username: `admin`
- Password: `changeme` (CHANGE THIS!)

**Database (SQL Server)**:
- SA Password: `ChangeMe123!`

**MySQL Root**:
- Password: `ChangeMe123!`

### Accessing the Scoring Dashboard

The scoring dashboard shows:
- Real-time service status (up/down)
- Current team score
- Service uptime percentages
- Recent scoring events
- Round timing

### Service Availability

The scoring engine checks services every 2 minutes (configurable). Services are awarded points based on:
- **Up (Green)**: Service responding correctly - full points
- **Down (Red)**: Service unavailable - 0 points
- **Degraded (Yellow)**: Service responding but incorrect - partial points

### Total Points Available

| Service Category | Points | Services |
|-----------------|--------|----------|
| Active Directory | 250 | LDAP, DNS |
| Web Services | 550 | IIS HTTP/HTTPS, Apache |
| Mail Services | 350 | SMTP, IMAP, OWA |
| Database | 250 | MSSQL, MySQL |
| File Services | 100 | SMB |
| DNS/DHCP | 175 | BIND, DHCP |
| FTP | 125 | FTP, SFTP |
| **TOTAL** | **1,800** | 15+ services |

## Scoring System

The scoring engine located at `10.{range_id}.99.10` provides:

### Automated Service Checks

Every 2 minutes, the engine tests:
- **Connection**: Can it reach the service port?
- **Authentication**: Do credentials work?
- **Functionality**: Does the service respond correctly?
- **Content**: Is expected data returned?

### Scoring Formula

```
Points Per Round = (Services Up / Total Services) × Total Points
```

Example:
- 12 of 15 services up = (12/15) × 1800 = 1,440 points this round
- Over a 4-hour competition (120 rounds): Maximum 216,000 points

### Penalties

While not implemented in the basic scoring engine, consider:
- **SLA Violations**: Major service downtime
- **Security Incidents**: Compromised systems
- **Inject Failures**: Missed business tasks

## Practice Scenarios

### Scenario 1: First Contact (Beginner)

**Duration**: 2 hours  
**Objective**: Get all services running and secured

**Tasks**:
1. Inventory all systems and services
2. Change all default passwords
3. Enable Windows Firewall on all Windows hosts
4. Create network diagram
5. Document current vulnerabilities
6. Enable basic logging

**Success Criteria**:
- All services green on scoreboard
- All default passwords changed
- Firewalls enabled
- Team network diagram created

### Scenario 2: Under Fire (Intermediate)

**Duration**: 4 hours  
**Objective**: Maintain services while defending against attacks

**Tasks**:
1. Complete Scenario 1 tasks
2. Implement host-based firewalls with strict rules
3. Disable SMBv1 on all systems
4. Configure strong password policies
5. Set up centralized logging
6. Monitor for intrusions
7. Respond to 2-3 business injects

**Red Team Actions**:
- Port scanning
- Password spraying
- SMB relay attacks
- Web application attacks
- Privilege escalation attempts

**Success Criteria**:
- 90%+ service uptime
- All business injects completed
- Detection and documentation of at least one attack
- No successful compromises

### Scenario 3: Full Competition Simulation (Advanced)

**Duration**: 8 hours  
**Objective**: Full CCDC simulation

**Tasks**:
All Scenario 2 tasks, plus:
1. Implement network segmentation
2. Deploy IDS/IPS
3. Set up SIEM with alerting
4. Create incident response procedures
5. Perform vulnerability scanning
6. Patch critical vulnerabilities
7. Complete 5-6 business injects
8. Provide executive briefing on security posture

**Red Team Actions**:
- Advanced persistent threats
- Lateral movement
- Data exfiltration attempts
- Ransomware simulation
- C2 beaconing
- Social engineering via injects

**Success Criteria**:
- 85%+ service uptime
- All business injects completed
- Comprehensive incident reports
- Executive briefing delivered
- Evidence of defense-in-depth

## Team Roles

Recommended 8-person team structure:

### 1. Team Captain
- **Responsibilities**: Overall coordination, time management, inject prioritization
- **Systems**: All (oversight)
- **Skills**: Leadership, communication, broad technical knowledge

### 2. Windows Lead
- **Responsibilities**: All Windows servers and AD
- **Systems**: DC01, FS01, WEB01, MAIL01, DB01, Workstations
- **Skills**: Active Directory, Group Policy, Windows hardening

### 3. Linux Lead
- **Responsibilities**: All Linux systems
- **Systems**: DNS01, LAMP01, FTP01
- **Skills**: Linux administration, bash scripting, service configuration

### 4. Network Lead
- **Responsibilities**: Firewalls, network segmentation, traffic monitoring
- **Systems**: Router, all systems (network configs)
- **Skills**: Networking, firewall rules, packet analysis

### 5. Database Specialist
- **Responsibilities**: Database servers and applications
- **Systems**: DB01, LAMP01 (MySQL)
- **Skills**: SQL, database hardening, backup/restore

### 6. Web Specialist
- **Responsibilities**: Web servers and applications
- **Systems**: WEB01, LAMP01
- **Skills**: IIS, Apache, web security, SSL/TLS

### 7. Logging/Monitoring Lead
- **Responsibilities**: Centralized logging, SIEM, incident detection
- **Systems**: All (log collection)
- **Skills**: Sysmon, Windows Event Log, Linux logging, SIEM

### 8. Injects/Documentation Lead
- **Responsibilities**: Business injects, documentation, reporting
- **Systems**: Varies based on inject
- **Skills**: Technical writing, time management, diverse technical skills

## Troubleshooting

### Services Won't Start

**Problem**: Services show down on scoring engine  
**Solution**:
1. Verify VM is powered on
2. Check network connectivity: `ping 10.{range_id}.10.X`
3. Verify service is running on the host
4. Check Windows Firewall isn't blocking (initially disabled, but students may enable)
5. Review service-specific logs

### Scoring Engine Not Accessible

**Problem**: Can't reach `http://10.{range_id}.99.10`  
**Solution**:
1. Verify scoring VM is running
2. Check you're connected via Ludus WireGuard VPN
3. SSH to scoring engine: `ssh debian@10.{range_id}.99.10`
4. Check services: `sudo supervisorctl status`
5. Check logs: `tail -f /var/log/scoringengine/web.log`

### Active Directory Issues

**Problem**: Can't join domain or authenticate  
**Solution**:
1. Verify DC01 is running
2. Check DNS settings on client: Should point to 10.{range_id}.10.2
3. Test DNS: `nslookup wcc.local 10.{range_id}.10.2`
4. Verify time sync (Kerberos requirement)
5. Check domain functional level

### Exchange Not Starting

**Problem**: Exchange services fail to start  
**Solution**:
1. Exchange requires 8GB RAM minimum - verify allocation
2. Check prerequisite services: AD, DNS
3. Allow 10-15 minutes for full Exchange startup
4. Check Event Viewer for Exchange errors
5. Verify enough disk space

### Performance Issues

**Problem**: VMs are slow or unresponsive  
**Solution**:
1. Check Proxmox host resources
2. Reduce concurrent VMs if needed
3. Consider disabling MAIL01 if RAM-constrained
4. Increase round time on scoring engine to reduce load
5. Ensure VMs aren't overprovisioned

### Ansible Role Failures

**Problem**: Ludus deployment fails during Ansible roles  
**Solution**:
1. Check error details: `ludus range errors`
2. Verify all templates are built correctly
3. Check role dependencies
4. Try deploying without problematic role first
5. Manually configure that system
6. Report issues to coach

## Advanced Customization

### Adjusting Scoring Intervals

Edit `/opt/scoringengine/ccdc_config.yaml` on the scoring engine:

```yaml
settings:
  round_time_sleep: 120  # Seconds between rounds (default: 2 minutes)
```

Restart scoring: `sudo supervisorctl restart scoringengine:*`

### Adding New Services to Score

Edit `/opt/scoringengine/ccdc_config.yaml`:

```yaml
services:
  - name: "New Service"
    team: "WCC Blue Team"
    host: "10.{range_id}.10.X"
    port: XXXX
    type: "service_type"
    points: XXX
    check_name: "check_type"
```

### Modifying Point Values

Adjust point values in the CCDC config file to emphasize certain services.

### Creating Custom Injects

Add business tasks to the config:

```yaml
injects:
  - name: "Task Name"
    description: "Detailed task description"
    time: 1800  # Seconds into competition
    points: 100
```

## Red Team Integration

For practice sessions with an active red team:

1. **Set up attacker system**: Deploy Kali Linux on VLAN 99
2. **Coordinate timing**: Define quiet period for initial hardening
3. **Scope rules of engagement**: What's allowed/prohibited
4. **Document attacks**: Red team should log all actions
5. **Debrief**: Post-session review of attacks and defenses

## Resources

### Documentation
- [Ludus Official Docs](https://docs.ludus.cloud)
- [NCCDC Official Site](https://www.nationalccdc.org)
- [CCDC Team Prep Guide](https://nccdc.org/files/CCDCteamprepguide.pdf)

### Training Materials
- SwiftOnSecurity Sysmon Config: https://github.com/SwiftOnSecurity/sysmon-config
- Windows Security Baseline: https://learn.microsoft.com/en-us/windows/security/threat-protection/windows-security-baselines
- Linux Hardening Guide: https://www.cisecurity.org/cis-benchmarks

### Practice Tools
- Hardening scripts
- Log analysis queries
- Common CCDC scenarios

## Support

For issues or questions:
- **Internal**: Contact WCC CCDC coach
- **Ludus Issues**: https://gitlab.com/badsectorlabs/ludus/-/issues
- **Community**: CCDC team Slack/Discord

## Credits

Created by the Whatcom Community College CCDC team, based on:
- Constructing Defense Lab by @Antonlovesdnb
- Ludus by Bad Sector Labs
- Scoring Engine by scoringengine/scoringengine

## License

This practice range configuration is provided for educational use by Whatcom Community College.

---

**Good luck, and happy defending!** 🛡️
