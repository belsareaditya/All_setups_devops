# Running an Ansible Playbook on Multiple VMs (with Handlers)

Yes ✅ — Instead of running commands or scripts manually on each VM, you can use **Ansible** to run them **on multiple servers at the same time**.  

---

## 1️⃣ Create an Inventory File (hosts)
Example: `hosts`
```ini
[myservers]
vm1 ansible_host=192.168.1.10 ansible_user=ubuntu
vm2 ansible_host=192.168.1.11 ansible_user=ubuntu
vm3 ansible_host=192.168.1.12 ansible_user=ubuntu
vm4 ansible_host=192.168.1.13 ansible_user=ubuntu
vm5 ansible_host=192.168.1.14 ansible_user=ubuntu
vm6 ansible_host=192.168.1.15 ansible_user=ubuntu
vm7 ansible_host=192.168.1.16 ansible_user=ubuntu
vm8 ansible_host=192.168.1.17 ansible_user=ubuntu
vm9 ansible_host=192.168.1.18 ansible_user=ubuntu
vm10 ansible_host=192.168.1.19 ansible_user=ubuntu
```

---

## 2️⃣ Example Playbook with Handlers
`ansible-handlers-playbook.yml`
```yaml
- name: Example Ansible playbook for Handlers
  hosts: myservers
  become: yes
  remote_user: ubuntu
  roles:
    - handlers

handlers:
  - name: Restart Nginx
    service:
      name: nginx
      state: restarted
```

---

## 3️⃣ Example Role Structure (`handlers` role)

**Directory Layout:**
```
roles/
  handlers/
    tasks/
      main.yml
    files/
      index.html
      updated.html
```

**Example `main.yml` inside `roles/handlers/tasks`:**
```yaml
- name: Install Nginx
  apt:
    name: nginx
    state: latest
    update_cache: yes

- name: Copy index.html
  copy:
    src: index.html
    dest: /usr/share/nginx/html/index.html
  notify: Restart Nginx

- name: Copy updated.html
  copy:
    src: updated.html
    dest: /usr/share/nginx/html/index.html
  notify: Restart Nginx
```

---

## 4️⃣ Run the Playbook on All 10 VMs at the Same Time
```bash
ansible-playbook -i hosts ansible-handlers-playbook.yml -f 10
```
- `-f 10` → runs tasks on all 10 VMs in parallel.  
- Without it, Ansible defaults to `-f 5` (5 at a time).  

---

✅ **Conclusion:**  
By defining your hosts once and using Ansible with handlers, you can install software, update files, and restart services **across multiple VMs simultaneously**, with minimal effort.
