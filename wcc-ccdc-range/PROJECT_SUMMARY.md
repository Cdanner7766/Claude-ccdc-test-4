# WCC CCDC Practice Range - Project Summary

## Overview
This is a complete CCDC (Collegiate Cyber Defense Competition) practice range designed for Whatcom Community College, built using the Ludus platform. The range simulates a realistic small business environment with 11+ virtual machines representing common enterprise services.

## What's Included

### Core Components
1. **Range Configuration** (`range.yaml`)
   - 11 virtual machines across 2 VLANs
   - Windows and Linux infrastructure
   - Pre-configured with intentional vulnerabilities

2. **Scoring Engine** (isolated on management network)
   - Automated service availability checking
   - Real-time scoreboard
   - 1,800+ points available across 15 services

3. **Complete Documentation**
   - README.md - Comprehensive guide
   - QUICKSTART.md - Fast deployment guide
   - docs/ARCHITECTURE.md - Network architecture details

4. **Ansible Roles** (11 custom roles)
   - `wcc_scoring_engine` - Automated scoring system
   - `wcc_sysmon_install` - Windows logging
   - `wcc_ad_vulnerable_setup` - Intentionally vulnerable AD
   - `wcc_fileserver_setup` - SMB file shares
   - `wcc_iis_ecommerce_setup` - Web server
   - `wcc_exchange_setup` - Mail server (placeholder)
   - `wcc_sqlserver_setup` - Database server
   - `wcc_bind_dhcp_setup` - DNS/DHCP
   - `wcc_linux_logging` - Enhanced Linux logging
   - `wcc_lamp_setup` - Apache/PHP/MySQL
   - `wcc_vsftpd_setup` - FTP server

5. **Automation**
   - `deploy.sh` - Automated deployment script

## Network Topology

**Management Network (VLAN 99):**
- Scoring Engine (10.X.99.10) - Isolated from business network
- Router (10.X.99.1)

**Business Network (VLAN 10) - What students defend:**
- DC01 (.10.2) - Active Directory, DNS, LDAP
- FS01 (.10.3) - File Server (SMB shares)
- WEB01 (.10.4) - IIS Web Server
- MAIL01 (.10.5) - Microsoft Exchange
- DB01 (.10.6) - SQL Server
- DNS01 (.10.7) - BIND DNS + ISC DHCP (Linux)
- LAMP01 (.10.8) - Apache + PHP + MySQL (Linux)
- FTP01 (.10.9) - FTP/SFTP server (Linux)
- WS01/WS02 (.10.20-21) - Windows workstations

## Key Features

### Realistic CCDC Simulation
- **Intentional Vulnerabilities**: Weak passwords, disabled firewalls, SMBv1 enabled
- **Mixed Environment**: Windows and Linux systems
- **Business Services**: Mail, web, database, file sharing, DNS
- **Scoring System**: Automated checks every 2 minutes

### Educational Design
- **Progressive Difficulty**: Three practice scenarios (beginner, intermediate, advanced)
- **Team Roles**: Defined structure for 8-person team
- **Documentation**: Comprehensive guides and troubleshooting
- **Resource Optimization**: Can run on 48GB+ RAM

### Based on Real CCDC
- Service types match actual competitions
- Point values reflect service criticality
- Inject system for business tasks
- Separation of scoring from business network

## Technical Specifications

### Requirements
- **Minimum**: 64GB RAM, 16 CPU cores, 400GB disk
- **Recommended**: 96GB RAM, 24 CPU cores, 500GB disk
- **Limited**: 48GB RAM possible without Exchange

### Templates Needed
- debian-11-x64-server-template
- debian-12-x64-server-template
- win11-22h2-x64-enterprise-template
- win2022-server-x64-template

### Services Scored (15+ services)
Total available points: 1,800 per round

**High Value (150+ points each):**
- Active Directory LDAP
- Web HTTPS
- Mail (SMTP/IMAP/OWA)
- SQL Server

**Medium Value (100-150 points):**
- File Server SMB
- Web HTTP
- Linux Web/MySQL
- DNS services

**Lower Value (50-100 points):**
- FTP/SFTP
- DHCP

## Quick Start

```bash
# 1. Clone repository
git clone <repository-url>
cd wcc-ccdc-range

# 2. Run automated deployment
./deploy.sh

# 3. Access scoring engine
# Browse to http://10.{range_id}.99.10
# Login: admin / changeme

# 4. Start your first practice!
```

Or see QUICKSTART.md for detailed step-by-step instructions.

## Practice Scenarios Included

### Scenario 1: First Contact (2 hours, Beginner)
- Get all services running
- Change default passwords
- Enable firewalls
- Create network documentation

### Scenario 2: Under Fire (4 hours, Intermediate)
- Complete Scenario 1
- Implement security hardening
- Respond to business injects
- Defend against simulated attacks

### Scenario 3: Full Competition (8 hours, Advanced)
- Full CCDC simulation
- Network segmentation
- IDS/SIEM deployment
- Multiple complex injects
- Executive briefing

## Known Limitations

### Complex Services
- **Exchange Server**: Requires manual setup (placeholder role provided)
- **SQL Server**: May need manual installation depending on version

### Simplifications from Real CCDC
- No physical hardware constraints
- Simplified inject system
- Basic scoring engine (vs. professional CCDC engines)
- No real red team framework (but can add attackers)

### Resource Intensive
- Full deployment requires substantial hardware
- Recommend dedicated physical server or cloud instance
- Not suitable for laptops or desktop computers

## Customization Options

### Easy Modifications
1. **Point values**: Edit scoring config to emphasize different services
2. **Scoring intervals**: Adjust time between checks (default 2 min)
3. **VM resources**: Increase/decrease RAM and CPU as needed
4. **Services**: Comment out services you don't want to score

### Advanced Modifications
1. **Add new services**: Create additional VMs in range.yaml
2. **Custom injects**: Define business tasks in scoring config
3. **Red team integration**: Add Kali Linux VM for live attacks
4. **Logging/SIEM**: Centralize logs to dedicated SIEM

## Support and Resources

### Documentation
- README.md - Primary documentation
- QUICKSTART.md - Fast deployment
- docs/ARCHITECTURE.md - Technical details

### External Resources
- Ludus Documentation: https://docs.ludus.cloud
- NCCDC Official: https://www.nationalccdc.org
- CCDC Prep Guide: https://nccdc.org/files/CCDCteamprepguide.pdf

### Troubleshooting
All common issues and solutions documented in README.md under "Troubleshooting" section.

## Credits and Attribution

**Created by**: Whatcom Community College CCDC Team

**Based on**:
- Constructing Defense Lab by @Antonlovesdnb
- Ludus by Bad Sector Labs
- Scoring Engine by scoringengine/scoringengine
- SwiftOnSecurity Sysmon config

**Purpose**: Educational use for CCDC competition preparation

## License
Provided for educational use.

## File Structure

```
wcc-ccdc-range/
├── README.md                  # Primary documentation
├── QUICKSTART.md              # Quick start guide
├── range.yaml                 # Main Ludus configuration
├── deploy.sh                  # Automated deployment script
├── docs/
│   └── ARCHITECTURE.md        # Network architecture details
└── roles/                     # Ansible roles
    ├── wcc_scoring_engine/    # Scoring system
    ├── wcc_sysmon_install/    # Windows logging
    ├── wcc_ad_vulnerable_setup/  # Vulnerable AD
    ├── wcc_fileserver_setup/  # File server
    ├── wcc_iis_ecommerce_setup/  # Web server
    ├── wcc_exchange_setup/    # Mail server
    ├── wcc_sqlserver_setup/   # Database
    ├── wcc_bind_dhcp_setup/   # DNS/DHCP
    ├── wcc_linux_logging/     # Linux logging
    ├── wcc_lamp_setup/        # LAMP stack
    └── wcc_vsftpd_setup/      # FTP server
```

## Next Steps

1. **Review Documentation**: Read README.md thoroughly
2. **Check Prerequisites**: Ensure Ludus server and templates ready
3. **Deploy Range**: Use deploy.sh or manual deployment
4. **Test Services**: Verify all services on scoreboard
5. **Organize Team**: Assign roles (see README.md)
6. **Start Practicing**: Run Scenario 1

## Success Metrics

A successful practice session includes:
- ✓ All services showing green on scoreboard
- ✓ 90%+ uptime maintained under pressure
- ✓ All default passwords changed
- ✓ Host firewalls enabled with proper rules
- ✓ Incident detection and documentation
- ✓ Business injects completed on time
- ✓ Team communication and coordination
- ✓ Post-session debrief and lessons learned

---

**Ready to start defending? Good luck to the WCC CCDC team!** 🛡️

For questions or issues, consult the README.md troubleshooting section or contact your team coach.
