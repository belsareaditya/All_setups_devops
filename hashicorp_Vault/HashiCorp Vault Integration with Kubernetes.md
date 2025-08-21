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

## Step 2 To get access to the Vault UI used port forwarding method in killercoda
By Default UI is not acessible in GUI ,so port forwarding is importan.

```bash
kubectl get svc
kubectl port-forward svc/vault 8200:8200 --address=0.0.0.0

To expose the port 
killer >> expose >> Port 8200
```

## Step 3: To create Seal keys and Token first you have get into the pod.
1. Exec into the pod , to create kyes there.
   
```bash
# Exec into Vault-0 pod
kubectl exec -it pods/vault-0 -- /bin/sh
```

2. Now initialize the  Vault
   
```bash
# Initialize Vault
vault operator init
```
<img width="880" height="191" alt="image" src="https://github.com/user-attachments/assets/cdc8d896-2d7e-45f0-897a-82c6ec9b816f" />

## Step 4: After initiazing , Unseals the key with below command.

```bash
vault operator unseal <Unseal-Key-1>
vault operator unseal <Unseal-Key-2>
vault operator unseal <Unseal-Key-3>
```

## Step 4 : Unseal Vault through (GUI)

<img width="2000" height="745" alt="image" src="https://github.com/user-attachments/assets/413b0ba0-7b3c-4133-a6b3-db2a6e6c690f" />

<img width="2000" height="782" alt="image" src="https://github.com/user-attachments/assets/22f138c9-ea02-4f12-8be7-14d83a4dcc39" />

<img width="1918" height="923" alt="image" src="https://github.com/user-attachments/assets/ce9e92d5-108c-4742-9751-f6b138ba790a" />


##  Step 5: After the Un unsealing through CLI Login & Enable Secret Engine


# Access for the CLI (use your root or unseal token)

```bash
vault login <root-or-admin-token>
```
<img width="536" height="52" alt="image" src="https://github.com/user-attachments/assets/7c1d8d9f-8a50-4e25-a91d-121c309266d3" />

##  Step 6 : List and Enable Engine

```bash
# List enabled secrets engines
vault secrets list

# Enable KV v2 secrets engine
vault secrets enable kv-v2
```

## Step 8: Store and Retrieve Secret

```bash
# Creating a secret
vault kv put kv-v2/vault-demo/mysecret username=mahesh password=passwd

# Retrieve the secret
vault kv put kv-v2/my_secrets/creds
```
<img width="890" height="262" alt="image" src="https://github.com/user-attachments/assets/0b04b14b-f198-4ddd-8f63-66dedf11eac3" />

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
<img width="1636" height="531" alt="image" src="https://github.com/user-attachments/assets/fea6c6e3-ba2d-49df-8053-9f16d1deb947" />

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

### To see the variables of Kubernetes. 
```sh
printenv
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
<img width="1422" height="666" alt="image" src="https://github.com/user-attachments/assets/7880a22d-7c19-45b3-b4d3-f243d5d90e72" />

## Used Kubectl pod command to see the attachment of service account

```sh
kubectl describe pod/vault-0
```

<img width="1135" height="142" alt="image" src="https://github.com/user-attachments/assets/ac763223-7d8f-4e56-9758-9abc286e724e" />

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
