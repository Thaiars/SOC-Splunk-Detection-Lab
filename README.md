#  Splunk SOC Detection Lab

A personal SOC analyst lab project simulating real-world attack scenarios on Windows 10,
ingesting Security Event Logs into Splunk Enterprise, and writing SPL detection queries mapped to MITRE ATT&CK.
---
##  Project Overview
```
Windows 10 VM                    Host Machine
─────────────────                ─────────────────
Simulation Scripts   ──────→    Splunk Enterprise
Generate Event Logs              localhost:8000
Universal Forwarder  ──────→    index=main
```

**Tools Used:**
- Splunk Enterprise 9.4.1
- Splunk Universal Forwarder
- Windows Security Event Log
- PowerShell (simulation scripts)

---

##  Attack Scenarios Detected

| Case | Attack Type | Event IDs | MITRE |
|------|------------|-----------|-------|
| 1 | Brute Force Attempt | 4625, 4740, 4624 | T1110, T1078 |
| 2 | Suspicious PowerShell | 4688 | T1059.001, T1027 |
| 3 | Post-Exploitation | 4720, 4732, 4698 | T1136.001, T1053.005 |
| 4 | Account Manipulation | 4723, 4724, 4725, 4726 | T1531, T1098 |

---

##  SPL Detection Queries

### Case 1 — Brute Force Detection
Detects 5 or more failed login attempts from the same source.

```spl
index=main source="WinEventLog:Security" EventCode=4625
| stats count by Account_Name, Source_Network_Address
| where count >= 5
| sort -count
```

 Groups failed logins by account and source IP — a count of 5+ in a short window is consistent with automated brute-force tooling.

---

### Case 2 — Encoded PowerShell Detection
Detects PowerShell executed with Base64-encoded commands.

```spl
index=main source="WinEventLog:Security" EventCode=4688
| search Process_Command_Line="*EncodedCommand*" OR Process_Command_Line="*-enc*"
| table _time, Account_Name, New_Process_Name, Process_Command_Line
```

Legitimate scripts rarely use `-EncodedCommand` — this flag is a common AV evasion technique used by malware.

---

### Case 3 — Persistence & Privilege Escalation Detection
Detects backdoor account creation, privilege escalation, and scheduled task persistence.

```spl
index=main source="WinEventLog:Security" EventCode IN (4720,4732,4698)
| stats count by EventCode, Account_Name
| sort EventCode
```

Three high-severity events in rapid succession (new account → admin group → scheduled task) is a textbook post-exploitation pattern.

---

### Case 4 — Account Access Removal Detection
Detects deliberate disabling and deletion of user accounts.

```spl
index=main source="WinEventLog:Security" EventCode IN (4723,4724,4725,4726)
| stats count by EventCode, Account_Name
| sort EventCode
```

Sequential account manipulation events (password reset → disable → delete) within seconds has no legitimate operational justification.

---

## Splunk Dashboard

Built a detection dashboard with 4 panels — one per attack scenario.

### Panel 1 — Brute Force
<img width="1827" height="627" alt="panel1_bruteforce" src="https://github.com/user-attachments/assets/5f352013-1b5a-47c7-b1fd-e09a3d662abd" />


### Panel 2 — Encoded PowerShell
![PowerShell Panel](screenshots/panel2_powershell.png)

### Panel 3 — Persistence Activity
![Persistence Panel](screenshots/panel3_persistence.png)

### Panel 4 — Account Manipulation
![Account Removal Panel](screenshots/panel4_account_removal.png)

---

## 🗂 Repository Structure

```
splunk-soc-detection-lab/
│
├── README.md
├── dashboard_export.pdf
│
├── result/
│   ├── dashboard_overview.png
│   ├── panel1_bruteforce.png
│   ├── panel2_powershell.png
│   ├── panel3_persistence.png
│   └── panel4_account_removal.png
│
└── scripts/
    ├── case1_bruteforce.ps1
    ├── case2_powershell.ps1
    ├── case3_postexploit.ps1
    └── case4_accountmanip.ps1
```

---

## MITRE ATT&CK Mapping

```
Initial Access      TA0001  →  T1078  Valid Accounts (Case 1)
Execution           TA0002  →  T1059.001  PowerShell (Case 2)
Persistence         TA0003  →  T1053.005  Scheduled Task (Case 3)
Privilege Escalation TA0004 →  T1136.001  Create Local Account (Case 3)
Defense Evasion     TA0005  →  T1027  Obfuscated Files (Case 2)
Credential Access   TA0006  →  T1110  Brute Force (Case 1)
Impact              TA0040  →  T1531  Account Access Removal (Case 4)
```

---

## Setup

### Prerequisites
- Splunk Enterprise (Free or Trial)
- Splunk Universal Forwarder on Windows VM
- Windows 10 VM with PowerShell

### Configure Forwarder
```powershell
# On Windows VM — inputs.conf
[WinEventLog://Security]
disabled = 0
start_from = oldest
current_only = 0
```

### Run Simulations
```powershell
# Run as Administrator on Windows VM
PowerShell -ExecutionPolicy Bypass -File "case1_bruteforce.ps1"
PowerShell -ExecutionPolicy Bypass -File "case2_powershell.ps1"
PowerShell -ExecutionPolicy Bypass -File "case3_postexploit.ps1"
PowerShell -ExecutionPolicy Bypass -File "case4_accountmanip.ps1"
```

