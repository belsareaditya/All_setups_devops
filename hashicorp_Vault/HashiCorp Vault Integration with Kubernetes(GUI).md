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
## 🚀  Step 2 : To get access to the Vault UI used port forwarding method in killercoda

```bash
kubectl get svc
kubectl port-forward svc/vault 8200:8200 --address=0.0.0.0

killer >> expose >> Port 8200
```

## 🚀  Step 3: Unseal Vault through (GUI)
<img width="1716" height="745" alt="image" src="https://github.com/user-attachments/assets/413b0ba0-7b3c-4133-a6b3-db2a6e6c690f" />

<img width="1788" height="782" alt="image" src="https://github.com/user-attachments/assets/22f138c9-ea02-4f12-8be7-14d83a4dcc39" />

<img width="1918" height="923" alt="image" src="https://github.com/user-attachments/assets/ce9e92d5-108c-4742-9751-f6b138ba790a" />

## 🚀 Step 4: Login & Enable Secret Engine in GUI

```bash
🔐 Enable KV Engine (max version = 3)

1. Secrets Engines → Enable new engine
2. Select Generic → KV
3. Path = kv (use lowercase for consistency)
4. Maximum Versions = 3
5. Click → Enable Engine
```
```bash
📂 Create a Secret (one secret with 2 key-value pairs)

1. Secrets → kv → Create secret
2. Path for this secret = my_secrets
3. Secret Data → Add
4. Key = admin01 | Value = Aditya , Secret Data → Add
5. Key = admin03 | Value = Anushree Secret Data → Add
6. Click → Save
```

vault login
```
# Check Vault status
vault status

# List enabled secrets engines
vault secrets list

# Enable KV v2 secrets engine
vault secrets enable kv-v2
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
vault policy list
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
vault write auth/kubernetes/config \
    kubernetes_host=https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT
```
1. You manually specify the Kubernetes API server host/port.
2. Useful if you’re outside the cluster (like running Vault locally).
3. Limited — doesn’t automatically verify Kubernetes API via service account credentials

### ✅ Option 2 (Recommended - In-cluster config):

```sh
vault write auth/kubernetes/config \
    token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
    kubernetes_host="https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT" \
    kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt

```
1. This is the recommended way when Vault runs inside Kubernetes.
Key differences:
1. token_reviewer_jwt = Uses the service account token (/var/run/secrets/kubernetes.io/serviceaccount/token) so Vault can call the Kubernetes TokenReview API.
2. kubernetes_ca_cert = Adds the cluster CA certificate to validate the API server TLS.
3. Still sets kubernetes_host, but with proper auth + TLS validation.

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

