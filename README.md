# Project Cerberus: Automated Security Orchestration Framework

Project Cerberus is a modular framework designed to automate the lifecycle of vulnerability management. It bridges the gap between offensive testing and defensive remediation by providing a unified interface for **Auditing, Attacking, and Hardening** Linux environments.



## Project Overview
In modern DevOps, security is often siloed. Cerberus demonstrates a **SOAR (Security Orchestration, Automation, and Response)** approach by:
1. **Auditing:** Scanning remote targets for misconfigurations in the Kernel (sysctl), SSH, and PAM.
2. **Attacking:** Simulating a Man-in-the-Middle (MITM) via ARP Spoofing to prove the impact of found vulnerabilities.
3. **Hardening:** Automatically remediating flaws and verifying the fix with a compliance score.

## Tech Stack
- **Environment:** Docker & Docker-Compose (Multi-container network)
- **Language:** Advanced Bash Scripting
- **Auditing:** Linux System Internals (sysctl, OpenSSH, PAM modules)
- **Attacking:** dsniff (arpspoof), tcpdump
- **Target OS:** Ubuntu 20.04 (Hardened during execution)

## Key Features
- **Dynamic Scoring:** Calculates a security posture score (0-100) based on compliance checks.
- **Modular Architecture:** Offensive and Defensive logic are separated into standalone plugins.
- **Automated Remediation:** Scripted `sed` and `sysctl` injections to close security holes in real-time.

## Sample Execution
1. **Audit:** Identifies `PermitRootLogin` enabled and IP Forwarding active. (Score: 0/100)
2. **Attack:** Captures network traffic to demonstrate the risk of unencrypted routing.
3. **Harden:** Reconfigures SSH, secures PAM password length, and disables forwarding.
4. **Verify:** Final audit confirms all fixes. (Score: 100/100)