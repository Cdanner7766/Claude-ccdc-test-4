# WCC CCDC Practice Range - Network Architecture

## Network Diagram

```
                                    INTERNET
                                        │
                                        │
                    ┌───────────────────┴───────────────────┐
                    │         Management Network            │
                    │          VLAN 99 (10.X.99.0/24)      │
                    ├───────────────────────────────────────┤
                    │                                       │
                    │   ┌──────────┐    ┌──────────────┐  │
                    │   │  Router  │    │   Scoring    │  │
                    │   │ (.99.1)  │    │   Engine     │  │
                    │   │          │    │  (.99.10)    │  │
                    │   └─────┬────┘    └──────────────┘  │
                    │         │                            │
                    │    ┌────▼──────┐                    │
                    │    │   Kali    │                    │
                    │    │ (.99.50)  │                    │
                    │    │ Red Team  │                    │
                    │    └───────────┘                    │
                    └─────────┼────────────────────────────┘
                              │
                              │ NAT/Firewall
                              │
                    ┌─────────┴────────────────────────────┐
                    │      Business Network (VLAN 10)      │
                    │       10.X.10.0/24                   │
                    │                                      │
                    │  ┌─────────────────────────────┐    │
                    │  │   Windows Infrastructure    │    │
                    │  │                             │    │
                    │  │  ┌────────────────────┐    │    │
                    │  │  │  Domain Controller │    │    │
                    │  │  │      DC01          │    │    │
                    │  │  │    .10.2           │    │    │
                    │  │  │  AD / DNS / LDAP   │    │    │
                    │  │  └──────────┬─────────┘    │    │
                    │  │             │              │    │
                    │  │    ┌────────┴────────┐    │    │
                    │  │    │                 │    │    │
                    │  │ ┌──▼───┐   ┌────▼─────┐  │    │
                    │  │ │ FS01 │   │  WEB01   │  │    │
                    │  │ │.10.3 │   │  .10.4   │  │    │
                    │  │ │ SMB  │   │IIS/HTTPS │  │    │
                    │  │ └──────┘   └──────────┘  │    │
                    │  │                          │    │
                    │  │ ┌──────┐   ┌──────────┐ │    │
                    │  │ │MAIL01│   │   DB01   │ │    │
                    │  │ │.10.5 │   │  .10.6   │ │    │
                    │  │ │Exchng│   │  MSSQL   │ │    │
                    │  │ └──────┘   └──────────┘ │    │
                    │  │                          │    │
                    │  │ ┌──────────────────┐    │    │
                    │  │ │  WS01 │   WS02   │    │    │
                    │  │ │ .10.20│  .10.21  │    │    │
                    │  │ │   Workstations   │    │    │
                    │  │ └──────────────────┘    │    │
                    │  └─────────────────────────┘    │
                    │                                 │
                    │  ┌─────────────────────────────┐│
                    │  │   Linux Infrastructure      ││
                    │  │                             ││
                    │  │  ┌────────┐  ┌──────────┐  ││
                    │  │  │ DNS01  │  │  LAMP01  │  ││
                    │  │  │ .10.7  │  │  .10.8   │  ││
                    │  │  │BIND/   │  │Apache/   │  ││
                    │  │  │DHCP    │  │MySQL/PHP │  ││
                    │  │  └────────┘  └──────────┘  ││
                    │  │                            ││
                    │  │  ┌────────┐               ││
                    │  │  │ FTP01  │               ││
                    │  │  │ .10.9  │               ││
                    │  │  │vsftpd  │               ││
                    │  │  └────────┘               ││
                    │  └─────────────────────────────┘│
                    └──────────────────────────────────┘
```

## IP Address Scheme

### Management Network (VLAN 99)
| Device | IP Address | Purpose |
|--------|-----------|----------|
| Router | 10.X.99.1 | Gateway and routing |
| Scoring Engine | 10.X.99.10 | Service monitoring |
| Kali Linux | 10.X.99.50 | Red Team attacker machine |

### Business Network (VLAN 10)
| Device | IP Address | Services | Points |
|--------|-----------|----------|---------|
| DC01 | 10.X.10.2 | AD, DNS, LDAP, Kerberos | 250 |
| FS01 | 10.X.10.3 | SMB File Shares | 100 |
| WEB01 | 10.X.10.4 | IIS, HTTP/HTTPS | 300 |
| MAIL01 | 10.X.10.5 | Exchange, SMTP, IMAP, OWA | 350 |
| DB01 | 10.X.10.6 | Microsoft SQL Server | 150 |
| DNS01 | 10.X.10.7 | BIND DNS, ISC DHCP | 175 |
| LAMP01 | 10.X.10.8 | Apache, PHP, MySQL | 200 |
| FTP01 | 10.X.10.9 | FTP, SFTP | 125 |
| WS01 | 10.X.10.20 | Windows Workstation | - |
| WS02 | 10.X.10.21 | Windows Workstation | - |
| DHCP Pool | 10.X.10.100-150 | Dynamic assignment | - |

## Service Dependencies

```
                    ┌──────────────┐
                    │    DC01      │
                    │ (AD / DNS)   │
                    └──────┬───────┘
                           │
           ┌───────────────┼───────────────┐
           │               │               │
      ┌────▼────┐     ┌───▼────┐     ┌───▼────┐
      │  FS01   │     │ WEB01  │     │ MAIL01 │
      │  (SMB)  │     │ (IIS)  │     │(Exchng)│
      └─────────┘     └────┬───┘     └────┬───┘
                           │              │
                      ┌────▼────┐    ┌────▼────┐
                      │  DB01   │    │  WS01   │
                      │ (MSSQL) │    │  WS02   │
                      └─────────┘    └─────────┘
```

All Windows systems depend on DC01 for:
- Authentication (Active Directory)
- Name resolution (DNS)
- Time synchronization (NTP)
- Group Policy

## Scored Services

### Critical Services (High Points)
1. **Active Directory** (DC01) - 150 points
   - Service: LDAP (389/tcp)
   - Check: Authentication test
   - Impact: All domain services fail without this

2. **Web Server HTTPS** (WEB01) - 150 points
   - Service: IIS HTTPS (443/tcp)
   - Check: HTTPS GET request with content validation
   - Business Value: Customer-facing e-commerce

3. **Mail Server** (MAIL01) - 350 points total
   - SMTP (25/tcp) - 150 points
   - IMAP (143/tcp) - 100 points
   - OWA (443/tcp) - 100 points
   - Business Value: Critical communication

4. **Database** (DB01) - 150 points
   - Service: SQL Server (1433/tcp)
   - Check: Connection and query test
   - Business Value: Backend for web and apps

### Important Services (Medium Points)
5. **Web Server HTTP** (WEB01) - 150 points
   - Service: IIS HTTP (80/tcp)
   - Check: HTTP GET request

6. **Linux Web** (LAMP01) - 200 points total
   - Apache (80/tcp) - 100 points
   - MySQL (3306/tcp) - 100 points

7. **DNS Services** - 200 points total
   - DC01 DNS (53/tcp) - 100 points
   - DNS01 BIND (53/tcp) - 100 points

### Secondary Services (Lower Points)
8. **File Server** (FS01) - 100 points
   - Service: SMB (445/tcp)
   - Check: Share accessibility

9. **FTP** (FTP01) - 125 points total
   - FTP (21/tcp) - 75 points
   - SFTP/SSH (22/tcp) - 50 points

10. **DHCP** (DNS01) - 75 points
    - Service: DHCP (67/udp)
    - Check: DHCP offer response

## Network Security Zones

### Zone 1: Management (Untrusted)
- VLAN 99
- Contains scoring engine and potential attacker
- Should be firewalled from business network
- Scoring engine needs read-only access to services

### Zone 2: Business Network (Trusted Internal)
- VLAN 10
- Contains all production services
- Inter-service communication allowed
- Should have host-based firewalls

### Recommended Firewall Rules

**From Management → Business**:
- Allow: Scoring engine health checks (all service ports)
- Deny: All other traffic

**Within Business Network**:
- Allow: All domain traffic to/from DC01
- Allow: Application-specific traffic (web→db, etc.)
- Allow: Administrative access (RDP, SSH) from admin workstations
- Deny: Unnecessary lateral movement

**From Business → Internet**:
- Allow: Required updates and legitimate traffic
- Monitor: All outbound connections
- Alert: C2 beacons, data exfiltration patterns

## Common Attack Vectors in CCDC

### Network Attacks
1. **ARP Spoofing/Poisoning**
   - Mitigation: Dynamic ARP Inspection (if supported)
   - Detection: Monitor ARP tables

2. **SMB Relay**
   - Vulnerability: SMB signing not enforced
   - Mitigation: Enable SMB signing on all hosts

3. **Pass-the-Hash**
   - Vulnerability: NTLM authentication
   - Mitigation: Kerberos-only where possible

### Service-Specific Attacks
4. **Web Application**
   - SQL Injection
   - XSS
   - Directory traversal
   - Mitigation: Input validation, WAF

5. **Email**
   - Phishing via injects
   - SMTP relay abuse
   - Mitigation: SPF, DKIM, restricted relay

6. **Database**
   - SQL injection
   - Weak passwords
   - Excessive permissions
   - Mitigation: Parameterized queries, strong auth

### Windows-Specific
7. **Kerberoasting**
   - Vulnerability: Service accounts with SPNs
   - Mitigation: Strong passwords, monitoring

8. **Golden Ticket**
   - Vulnerability: Compromised KRBTGT
   - Mitigation: Secure DC, monitor ticket creation

## Monitoring Strategy

### Critical Logs to Watch
1. **Domain Controller**
   - Event ID 4768: Kerberos TGT requests
   - Event ID 4769: Kerberos service tickets
   - Event ID 4625: Failed logins
   - Event ID 4672: Special privileges assigned

2. **All Windows Hosts**
   - Sysmon Event ID 1: Process creation
   - Sysmon Event ID 3: Network connections
   - Sysmon Event ID 10: Process access
   - Sysmon Event ID 11: File creation

3. **Linux Systems**
   - /var/log/auth.log: Authentication attempts
   - /var/log/audit/audit.log: Auditd events
   - Laurel JSON: Structured audit logs

4. **Network**
   - Failed connection attempts
   - Unusual port scanning
   - Large data transfers
   - C2 beacon patterns

## Resource Requirements

### Minimum Configuration
- **Total RAM**: 64GB
- **Total CPU**: 16 cores
- **Total Disk**: 400GB

### Per-VM Allocation
| VM | RAM | CPU | Disk | Priority |
|----|-----|-----|------|----------|
| DC01 | 4GB | 2 | 60GB | Critical |
| FS01 | 4GB | 2 | 100GB | High |
| WEB01 | 4GB | 2 | 60GB | Critical |
| MAIL01 | 8GB | 4 | 100GB | High (optional) |
| DB01 | 6GB | 2 | 60GB | High |
| DNS01 | 2GB | 1 | 20GB | Medium |
| LAMP01 | 4GB | 2 | 40GB | High |
| FTP01 | 2GB | 1 | 40GB | Low |
| WS01 | 4GB | 2 | 60GB | Low |
| WS02 | 4GB | 2 | 60GB | Low |
| Scoring | 4GB | 2 | 20GB | Critical |
| Router | 1GB | 1 | 10GB | Critical |

### Resource Optimization
To run on limited hardware:
1. **Skip MAIL01** (-8GB RAM) - Use simpler mail solution
2. **Reduce workstations** to 1 (-4GB RAM)
3. **Lower RAM allocations** by 1GB each for non-critical (-6-8GB)
4. **Minimum viable**: ~48GB RAM with core services only

## Backup Strategy

### Pre-Competition Snapshots
Before each practice session:
1. Take snapshots of all VMs in clean state
2. Document initial configuration
3. Save snapshot IDs for quick restore

### During Competition
- No snapshots (not realistic)
- Rely on service restarts and fixes
- Document all changes made

### Post-Competition
1. Snapshot final state for review
2. Compare with baseline
3. Document lessons learned
4. Restore to clean state for next session

---

*This architecture supports both practice and competition scenarios, balancing realism with resource constraints.*
