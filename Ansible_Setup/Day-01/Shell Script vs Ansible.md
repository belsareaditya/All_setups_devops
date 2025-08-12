#Shell Scripts vs. Ansible – When to Use What

## Shell Scripting – Overview & Limitations

- **Simple & Fast** – Often the first automation tool engineers reach for.  
- **Platform Dependent** – Works only for Linux.  
- **Complexity Increases** – Becomes hard to read for non-experts as script size grows.  
- **Poor Error Handling** – Failures can go unnoticed.  
- **Not Scalable** – Difficult to run on many servers without custom SSH logic.  
- **Hard to Maintain** – Long scripts become messy.  
- **Weak Secret Management** – Passwords often stored in plaintext.

---

## 🔄 Idempotence and Predictability

**Shell scripts are usually _not idempotent_** – running them multiple times can cause errors or conflicts.

### ⚠️ Shell Script Example – Not Idempotent
```bash
#!/bin/bash
# Create a user
sudo useradd deployer
```
First run: ✅ User is created.

Second run: ❌ Script fails – user already exists.


# Ansible is idempotent – if the desired state already exists, it won’t make changes.

```bash
- name: Ensure deployer user exists
  hosts: all
  become: yes
  tasks:
    - name: Create deployer user
      user:
        name: deployer
        state: present
```
