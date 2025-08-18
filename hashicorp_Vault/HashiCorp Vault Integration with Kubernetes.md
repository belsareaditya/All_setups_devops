# 🔐 Vault on Kubernetes using Helm - Complete Integration Guide

This guide walks through installing, initializing, and integrating HashiCorp Vault with Kubernetes using Helm, with practical examples for better understanding.

<img width="1920" height="1080" alt="HashiCorp Vault Integration with Kubernetes _ Helm + Secrets + ServiceAccount _ Step-by-Step Demo 0-4 screenshot" src="https://github.com/user-attachments/assets/e692fc5b-f607-4a58-8545-a6801f2b5c7b" />

---

## 🚀 Step 1: Install Helm & Deploy Vault

```bash
# Download Helm installation script
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3

# Make it executable
chmod +x get_helm.sh

# Run installer
./get_helm.sh

# Add HashiCorp Helm repo
helm repo add hashicorp https://helm.releases.hashicorp.com

# Update repo
helm repo update

# Install Vault using Helm
helm install vault hashicorp/vault
```

👉 **Example output (truncated):**
```text
NAME: vault
LAST DEPLOYED: Mon Aug 14 12:34:56 2025
NAMESPACE: default
STATUS: deployed
REVISION: 1
```
## Note:  Vault server in -dev mode
```bash
vault server -dev
```
1. It’s meant for local development/testing, not production.
2. Key differences in -dev mode:
3. Vault runs entirely in-memory (no data persisted to disk).
4. It is already initialized (you don’t need to run vault operator init).
5. Vault is already unsealed (you don’t need unseal keys).
6. It gives you a root token printed to the console when it starts.
7. When you stop the process, all data is lost.

---
## 2. Vault server in normal mode (with unseal keys)
In production (normal mode), you start with: 

```bash
vault server -config=/path/to/config.hcl
```
Differences:

1. Vault starts in a sealed state.

2. You must initialize Vault first with:

## Step 2: Initialize Vault

```bash
# Exec into Vault pod
kubectl exec -it pods/vault-0 -- /bin/sh

# Initialize Vault
vault operator init
```
This generates:

1. Multiple Unseal Keys (usually 5, can configure).
2. One Initial Root Token.
3. Vault uses Shamir’s Secret Sharing to split the master key into those unseal keys.
4. To unseal, you must provide a threshold (e.g., 3 out of 5 keys):


👉 **Example output:**
```text
Unseal Key 1: K1d3d8hZ0SxjQ2...
Unseal Key 2: H92jd9sd02kLm2...
Unseal Key 3: Vdj29skq0WnN7...
Unseal Key 4: 0Nsl2kdj3Opl9...
Unseal Key 5: HSkd93nd9Wms0...

Initial Root Token: s.jsk82nd92ksL0...
```

---

## Step 3: Unseal Vault

```bash
vault operator unseal <Unseal-Key-1>
vault operator unseal <Unseal-Key-2>
vault operator unseal <Unseal-Key-3>
```

👉 **Example output:**
```text
Seal Type: shamir
Initialized: true
Sealed: false
Total Shares: 5
Threshold: 3
```
Once threshold is met, Vault becomes unsealed and operational.

Data is stored persistently (e.g., in file system, Consul, etc.).
---

## 🔑 Step 4: Login & Enable Secret Engine

```bash
# Login to Vault (use your root or unseal token)
vault login

# Check Vault status
vault status

# List enabled secrets engines
vault secrets list

# Enable KV v2 secrets engine
vault secrets enable -path=kv-v2 kv-v2
```

👉 **Example secrets list:**
```text
Path      Type     Accessor
----      ----     --------
cubbyhole cubbyhole cubbyhole_d1f9...
sys/      system   system_1234...
```

---

## Step 5: Store and Retrieve Secret

```bash
# Store a secret
vault kv put kv-v2/vault-demo/mysecret username=mahesh password=passwd

# Retrieve the secret
vault kv get kv-v2/vault-demo/mysecret
```

👉 **Example output:**
```text
====== Data ======
Key         Value
---         -----
username    mahesh
password    passwd
```

---

## 🔒 Step 6: Create Read-Only Policy

```sh
vault policy write mysecret - << EOF
path "kv-v2/data/vault-demo/mysecret" {
  capabilities = ["read"]
}
EOF
```

👉 **Example check policy:**
```bash
vault policy read mysecret
```
```text
path "kv-v2/data/vault-demo/mysecret" {
  capabilities = ["read"]
}
```

---

## Step 7: Enable Kubernetes Auth Method

```sh
vault auth enable kubernetes
vault auth list
```

👉 **Example output:**
```text
Path         Type         Accessor              Description
----         ----         --------              -----------
kubernetes/  kubernetes   auth_kubernetes_abc   n/a
```

---

## ⚙️ Step 8: Configure Kubernetes Auth Backend

### ✅ Option 1 (Manual host):

```sh
vault write auth/kubernetes/config    kubernetes_host=https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT
```

### ✅ Option 2 (Recommended - In-cluster config):

```sh
vault write auth/kubernetes/config    token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)"    kubernetes_host="https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT"    kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
```

👉 **Example verification:**
```sh
vault read auth/kubernetes/config
```
```text
Key                  Value
---                  -----
kubernetes_host      https://10.96.0.1:443
```

---

## Step 9: Create Kubernetes Service Account

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: vault-auth
  namespace: default
```

```bash
kubectl apply -f service-account.yaml
```

👉 **Example check:**
```bash
kubectl get sa vault-auth
```
```text
NAME         SECRETS   AGE
vault-auth   1         5s
```

---

## 🎯 Step 10: Create Vault Role for Kubernetes

```sh
vault write auth/kubernetes/role/demo-role    bound_service_account_names=vault-auth    bound_service_account_namespaces=default    policies=mysecret    ttl=1h
```

👉 **Example check:**
```bash
vault read auth/kubernetes/role/demo-role
```
```text
Key     Value
---     -----
name    demo-role
policies [mysecret]
```

---

## 📦 Pod Manifest Example

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vault-demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: vault-check
  template:
    metadata:
      labels:
        app: vault-check
    spec:
      containers:
        - name: vault-check
          image: hashicorp/vault:1.15.0
          command: ["/bin/sh"]
          args: ["-c", "sleep 3600"]
          env:
            - name: VAULT_ADDR
              value: "http://vault.default.svc.cluster.local:8200"
            - name: VAULT_SKIP_VERIFY
              value: "true"
```

👉 **Example check:**
```bash
kubectl get pods -l app=vault-check
```
```text
NAME                          READY   STATUS    RESTARTS   AGE
vault-demo-5f6f8c8c8d-abcde   1/1     Running   0          15s
```

---

## Option 2: Pod Authenticates and Fetches Secrets

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: vault-demo
spec:
  serviceAccountName: vault-auth
  containers:
    - name: vault-demo
      image: badouralix/curl-jq
      command: ["sh", "-c"]
      args:
        - |
          VAULT_ADDR="http://vault.default.svc.cluster.local:8200"

          echo "Reading service account token..."
          SA_TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)

          echo "Authenticating to Vault..."
          LOGIN_RESPONSE=$(curl -s --request POST --data "{\"jwt\": \"${SA_TOKEN}\", \"role\": \"demo-role\"}"             "${VAULT_ADDR}/v1/auth/kubernetes/login")

          VAULT_TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.auth.client_token')

          echo "Fetching secret from Vault..."
          SECRET=$(curl -s -H "X-Vault-Token: ${VAULT_TOKEN}"             "${VAULT_ADDR}/v1/kv-v2/data/vault-demo/mysecret" | jq -r '.data.data')

          echo "🔑 Secret retrieved:"
          echo "$SECRET"

          sleep 3600
```

👉 **Example pod logs:**
```text
Reading service account token...
Authenticating to Vault...
Fetching secret from Vault...
🔑 Secret retrieved:
{
  "username": "mahesh",
  "password": "passwd"
}
```
