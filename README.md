#  Project Cerberus: Automated Security Orchestration Framework

**Project Cerberus** is a modular framework designed to automate the lifecycle of vulnerability management. It bridges the gap between offensive testing and defensive remediation by providing a unified interface for **Auditing, Attacking, and Hardening** Linux environments.

##  Project Overview
In modern DevOps, security is often siloed. Cerberus demonstrates a **SOAR (Security Orchestration, Automation, and Response)** approach by:
1.  **Auditing:** dynamically scanning live Kernel parameters (`/proc/sys/...`) and PAM configurations.
2.  **Attacking:** Simulating an internal Man-in-the-Middle (MITM) attack via ARP Spoofing.
3.  **Hardening:** Automatically remediating flaws using enterprise-standard tools (`sysctl`, `sed`) and verifying the fix.

##  Architecture
The infrastructure runs on a **Multi-Container Docker Network** (`172.20.0.0/24`) isolating the Attacker, Victim, and Gateway.

| Role | Container | IP | Description |
| :--- | :--- | :--- | :--- |
| **Attacker** | `cerberus_operator` | `172.20.0.10` | Kali Linux (Rolling). Runs the main controller and attack modules. |
| **Target** | `cerberus_target` | `172.20.0.20` | Ubuntu 20.04. The victim server with vulnerable configurations. |
| **Gateway** | `cerberus_gateway` | `172.20.0.2` | Apache Guacamole. Provides clientless Web RDP/SSH access. |

##  The Core Logic: "Spying vs. Blocking"
This project demonstrates the critical concept of **Fail-Open vs. Fail-Closed** security.

| Scenario | Kernel State | Attack Result | Outcome |
| :--- | :--- | :--- | :--- |
| **Vulnerable** | `ip_forward=1` | **Spying** | The attacker transparently routes traffic. The victim has internet, but **Confidentiality is lost**. |
| **Hardened** | `ip_forward=0` | **Blocking** | The attacker refuses to route traffic. The victim loses connection (DoS), but **Confidentiality is preserved**. |

##  Installation & Usage

### Prerequisites
* Docker & Docker Compose

### Quick Start
1.  Clone the repository:
    ```bash
    git clone https://github.com/ZTMY0/Project-Cerberus
    ```
2.  Launch (Builds the environment):
    ```bash
    docker-compose up -d --build
    ```
3.  Access the Web Gateway:
    * **URL:** `http://127.0.0.1:8080`
    * **Credentials:** `guacadmin` / `guacadmin`

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