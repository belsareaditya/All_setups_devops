# 🛠 Shell Scripts vs. Ansible – When to Use What

## 📜 When to Use **Shell Scripts**
**Shell Scripting works only for Linux** (platform-dependent).  
- Becomes **complex and less readable** (especially for non-experts) as script size grows. 
Shell scripts are quick, lightweight, and available on almost every system.  

- **Idempotence and predictability**:  
  - In Ansible, if the system is already in the state described in your playbook, it does **nothing** (safe to run multiple times).  
  - Shell scripts often **fail** or cause issues if run multiple times without proper checks.

## ⚠️ Shell Script Example – Not Idempotent
```bash
#!/bin/bash
# Create a user
sudo useradd deployer

First run: ✅ User is created.
Second run: ❌ Script fails – user already exists.

**🚫 Limitations:**
1. **Not Idempotent** – Running twice might break things  
2. **Poor Error Handling** – Failures can go unnoticed  
3. **Not Scalable** – Hard to run on many servers without extra SSH logic  
4. **Platform Dependent** – May work on Ubuntu but fail on CentOS  
5. **Hard to Maintain** – Long scripts become messy  
6. **Weak Secret Management** – Passwords often in plaintext  

**💡 Example:**  
```bash
#!/bin/bash
# Install Nginx on a single server
sudo apt update
sudo apt install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx
