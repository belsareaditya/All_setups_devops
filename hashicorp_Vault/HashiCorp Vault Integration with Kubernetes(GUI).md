# 🔐 Vault on Kubernetes using Helm - Complete Integration Guide (with ESO Integration)

This guide walks through installing, initializing, and integrating HashiCorp Vault with Kubernetes using Helm, and extends it with **ESO (External Secrets Operator)** integration.

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

---

## Step 2: Port Forward Vault UI

```bash
kubectl port-forward svc/vault 8200:8200 --address=0.0.0.0
```
Then expose port 8200 in Killercoda or your environment to access the Vault UI.

---

## Step 3: Initialize Vault

```bash
kubectl exec -it pods/vault-0 -- /bin/sh
vault operator init
vault operator unseal <Unseal-Key-1>
vault operator unseal <Unseal-Key-2>
vault operator unseal <Unseal-Key-3>
```

Login:
```bash
vault login <root-token>
```

---

## Step 4: Enable KV Secrets Engine

```bash
vault secrets enable -path=kv-v2 kv-v2
vault kv put kv-v2/vault-demo/mysecret username=mahesh password=passwd
```

---

## Step 5: Create Policy

```hcl
vault policy write mysecret - << EOF
path "kv-v2/data/vault-demo/mysecret" {
  capabilities = ["read"]
}
EOF
```

---

## Step 6: Enable & Configure Kubernetes Auth

```bash
vault auth enable kubernetes
vault write auth/kubernetes/config     token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)"     kubernetes_host="https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT"     kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
```

Create ServiceAccount:
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

Create Role:
```bash
vault write auth/kubernetes/role/demo-role     bound_service_account_names=vault-auth     bound_service_account_namespaces=default     policies=mysecret     ttl=1h     audiences="https://kubernetes.default.svc.cluster.local"
```

---

# 🌐 Step 7: Install External Secrets Operator (ESO)

1. **Add Helm repo & install ESO**
```bash
helm repo add external-secrets https://charts.external-secrets.io
helm repo update

# Install ESO in default namespace
helm install external-secrets external-secrets/external-secrets
```

2. **Verify ESO pods**
```bash
kubectl get pods -l app.kubernetes.io/instance=external-secrets
```

---

# 🔑 Step 8: Configure SecretStore with Vault

Create `secret-store.yaml`:

```yaml
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: vault-backend
spec:
  provider:
    vault:
      server: "http://vault.default.svc:8200"
      path: "kv-v2"
      version: "v2"
      auth:
        kubernetes:
          mountPath: "kubernetes"
          role: "demo-role"
          serviceAccountRef:
            name: vault-auth
```

Apply it:
```bash
kubectl apply -f secret-store.yaml
```

Check:
```bash
kubectl describe secretstore vault-backend
```

---

# 📜 Step 9: Create ExternalSecret

Create `external-secret.yaml`:

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: my-secret-sync
spec:
  refreshInterval: 30s
  secretStoreRef:
    name: vault-backend
    kind: SecretStore
  target:
    name: synced-secret
    creationPolicy: Owner
  data:
  - secretKey: username
    remoteRef:
      key: vault-demo/mysecret
      property: username
  - secretKey: password
    remoteRef:
      key: vault-demo/mysecret
      property: password
```

Apply it:
```bash
kubectl apply -f external-secret.yaml
```

Check synced secret:
```bash
kubectl get secret synced-secret -o yaml
```

👉 Example output:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: synced-secret
data:
  username: bWFoZXNo   # base64 encoded
  password: cGFzc3dk   # base64 encoded
```

---

# ✅ Simplified Vault Logs (Important Events)

1. Vault started and unsealed ✅  
2. KV engine enabled ✅  
3. Kubernetes auth enabled ✅  
4. ESO installed and connected to Vault ✅  
5. Secrets synced from Vault into Kubernetes ✅  

---

🎯 **Final Result:**  
- Vault stores your secrets in `kv-v2/vault-demo/mysecret`  
- ESO automatically syncs them into a Kubernetes Secret (`synced-secret`)  
- Your pods can mount/use `synced-secret` just like any other Kubernetes Secret.  
