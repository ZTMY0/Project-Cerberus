#  Project Cerberus: Automated Security Orchestration Framework

**Project Cerberus** is a modular framework designed to automate the lifecycle of vulnerability management. It bridges the gap between offensive testing and defensive remediation by providing a unified interface for **Auditing, Attacking, and Hardening** Linux environments.

##  Project Overview
In modern DevOps, security is often siloed. Cerberus demonstrates a **SOAR (Security Orchestration, Automation, and Response)** approach by:
1.  **Auditing:** Scanning remote targets for misconfigurations in the Kernel (sysctl), SSH, and PAM.
2.  **Attacking:** Simulating a Man-in-the-Middle (MITM) via ARP Spoofing to demonstrate the risk of unencrypted routing.
3.  **Hardening:** Automatically remediating flaws and verifying the fix with a compliance score.

##  Architecture & Tech Stack
The infrastructure runs on a **Multi-Container Docker Network** (`172.20.0.0/24`) isolating the Attacker, Victim, and Gateway.

| Role | Container | OS / Image | IP | Description |
| :--- | :--- | :--- | :--- | :--- |
| **Attacker** | `cerberus_operator` | **Kali Linux** (Rolling) | `172.20.0.10` | Red Team machine with custom audit/exploit scripts. |
| **Target** | `cerberus_target` | **Ubuntu 20.04** | `172.20.0.20` | Vulnerable victim server. |
| **Gateway** | `cerberus_gateway` | **Apache Guacamole** | `172.20.0.2` | Clientless RDP/SSH interface (Port 8080). |

* **Language:** Advanced Bash Scripting & Python (for Log Aggregation)
* **Offensive Tools:** `dsniff` (arpspoof), `tcpdump`
* **Defensive Tools:** Linux Internals (`sysctl`, `PAM`, `sshd_config`)

##  Installation & Usage

### Prerequisites
* Docker & Docker Compose

### Quick Start
1.  Clone the repository:
    ```bash
    git clone [https://github.com/ZTMY0/Project-Cerberus](https://github.com/ZTMY0/Project-Cerberus)
    cd cerberus_lab
    ```
2.  Launch the lab (Builds the environment):
    ```bash
    docker-compose up -d --build
    ```
3.  Access the Web Gateway:
    * **URL:** `http://127.0.0.1:8080`
    * **User/Pass:** `guacadmin` / `guacadmin`
4.  Connect to **"Project Cerberus"** to open the Kali terminal.

### Running the Framework
Inside the Kali terminal, launch the main controller:
```bash
/app/cerberus.sh

## Optional: Remote Access (Tailscale)

This framework supports secure remote auditing via **Tailscale**, allowing you to access the Kali terminal from **any external device** (Laptop, Tablet, or Smartphone) without exposing ports to the public internet.

### Setup Instructions
1.  **Host Machine:** Install [Tailscale](https://tailscale.com/) on the computer running the Docker lab.
2.  **Client Device:** Install Tailscale on your remote device (e.g., your phone or a second laptop) and log in to the same account.
3.  **Access:**
    * Find your Host Machine's **Tailscale IP** (e.g., `100.x.y.z`).
    * Open a browser on the remote device and navigate to:
      `http://<Tailscale-IP>:8080`
4.  **Login:** Use the standard Guacamole credentials (`guacadmin`).

**Benefit:** Simulates a "Zero-Trust" remote management scenario. You can trigger attacks or view audit logs from an iPad in a coffee shop or a laptop in another building.