# HashiCorp Vault – Introduction & CLI Cheatsheet

## Introduction
HashiCorp Vault is a platform to **secure, store, and tightly control access** to tokens, passwords, certificates, encryption keys, and other sensitive data. In short, Vault manages secrets and protects sensitive data.

Vault works across both **On-Premise** and **Cloud** environments (AWS, Azure, GCP, etc.), providing a **single source of truth** for secrets.

---

## 🔑 Key Benefits
- Unified secret management across on-prem and cloud.
- Centralized source of truth for credentials.
- Reduces risk of secret sprawl.
- Can serve as an **internal Certificate Authority (CA)**.

**Use cases include:**
- Storing AWS Root credentials.
- Storing LDAP server password.
- Storing MySQL root credentials (on-prem or RDS).
- Acting as a CA for certificate signing.

---

## 🧩 Core Components
- **Storage Backends** – store encrypted data (e.g., Consul, Integrated Storage).
- **Secret Engines** – provide different secret types (KV, PKI, SSH, AD, etc.).
- **Authentication Methods** – how users/apps log in (userpass, GitHub, LDAP, Okta, Kubernetes, etc.).
- **Audit Devices** – log requests (File, Syslog, Socket).

---

## 📘 Cheatsheet – Common CLI Commands

### Setup
```bash
# Set Vault server address (HTTP or HTTPS)
export VAULT_ADDR="http://127.0.0.1:8200"

# If using TLS
export VAULT_ADDR="https://<IP>:8200"
```

### Status
```bash
vault status
vault status -tls-skip-verify   # If TLS is enabled with self-signed certs
```

Example output:
```
Seal Type       shamir
Initialized     true
Sealed          false
Total Shares    5
Threshold       3
Version         1.20.2
Cluster Name    vault-cluster-XXXXXXX
Cluster ID      XXXXX-XXXX-XXXX
HA Enabled      true
HA Mode         active
```

---

### Initialization & Unseal
```bash
# Initialize Vault (default Shamir, 5 shares, 3 threshold)
vault operator init

# Custom shares & threshold
vault operator init -key-shares=3 -key-threshold=2

# Unseal Vault
vault operator unseal <unseal_key>
```

---

### Authentication
```bash
# Login with root token
vault login <root_token>

# Login with username/passwordault login -method=userpass username=myuser

# Login with GitHub token
vault login -method=github -path=github-prod
```

---

### Authentication Methods
```bash
# List enabled auth methods
vault auth list

# Enable userpass auth
vault auth enable userpass

# Enable Kubernetes auth
vault auth enable kubernetes

# Login with K8s service account token
vault write auth/kubernetes/login role=demo jwt=<jwt_token>
```

---

### Policies
```bash
# List policies
vault policy list

# Read a policy
vault policy read my-policy

# Write a new policy
vault policy write my-policy policy.hcl
```

Example `policy.hcl`:
```hcl
path "secret/data/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
```

---

### Tokens
```bash
# Create a new token with policy
vault token create -policy=my-policy

# Renew token
vault token renew <token>
```

---

### KV Secrets Engine
```bash
# Enable KV v2 secrets engine at `secret/`
vault secrets enable -path=secret kv-v2

# Write a secret
vault kv put secret/myapp username=admin password=pass123

# Read a secret
vault kv get secret/myapp

# Read only a field
vault kv get -field=username secret/myapp

# Enable versioning
vault kv metadata put -max-versions=5 secret/myapp

# Get a specific version
vault kv get -version=2 secret/myapp

# Delete latest version
vault kv delete secret/myapp

# Delete a specific version
vault kv delete -versions=2 secret/myapp
```

---

### Secrets Engines
```bash
# List enabled secret engines
vault secrets list

# Enable AWS secrets engine
vault secrets enable aws

# Enable Database secrets engine
vault secrets enable database
```

---

### Auditing
```bash
# List audit devices
vault audit list

# Enable file audit device
vault audit enable file file_path=/tmp/vault_audit.log
```

---

## 📌 Example Workflow
```bash
# 1. Enable KV engine
vault secrets enable -path=secret kv-v2

# 2. Store secretault kv put secret/db username=root password=mysecret

# 3. Retrieve secret
vault kv get secret/db

# 4. Create a policy to allow read access
cat > readonly.hcl <<EOF
path "secret/data/db" {
  capabilities = ["read"]
}
EOF

vault policy write readonly readonly.hcl

# 5. Create a token with readonly policy
vault token create -policy=readonly
```

---

## 🚀 Summary
- Vault is a **powerful tool for secrets management**.
- Supports multiple **auth methods**, **secret engines**, and **audit devices**.
- Can be used across **on-prem & cloud**.
- Best practices: versioned secrets, least-privilege policies, audit logging.
