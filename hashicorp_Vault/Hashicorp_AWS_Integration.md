# 🔐 Vault on Kubernetes using Helm - Complete Integration Guide (with ESO Integration + AWS Secrets Manager)

This guide walks through installing, initializing, and integrating HashiCorp Vault with Kubernetes using Helm, extends it with **ESO (External Secrets Operator)** integration for Vault, and also shows how to integrate **AWS Secrets Manager**.

---

## 🚀 Step 1: Install Helm & Deploy Vault

```bash
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update
helm install vault hashicorp/vault
```

---

## Step 2: Port Forward Vault UI

```bash
kubectl port-forward svc/vault 8200:8200 --address=0.0.0.0
```

---

## Step 3: Initialize & Unseal Vault

```bash
kubectl exec -it pods/vault-0 -- /bin/sh
vault operator init
vault operator unseal <Unseal-Key-1>
vault operator unseal <Unseal-Key-2>
vault operator unseal <Unseal-Key-3>
vault login <root-token>
```

---

## Step 4: Enable KV Secrets Engine

```bash
vault secrets enable -path=kv-v2 kv-v2
vault kv put kv-v2/vault-demo/mysecret username=mahesh password=passwd
```

---

## Step 5: Enable Kubernetes Auth + Role

```bash
vault auth enable kubernetes

vault write auth/kubernetes/config     token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)"     kubernetes_host="https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT"     kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt

vault write auth/kubernetes/role/demo-role     bound_service_account_names=vault-auth     bound_service_account_namespaces=default     policies=mysecret     ttl=1h     audiences="https://kubernetes.default.svc.cluster.local"
```

---

# 🌐 Step 6: Install External Secrets Operator (ESO)

```bash
helm repo add external-secrets https://charts.external-secrets.io
helm repo update
helm install external-secrets external-secrets/external-secrets
```

Verify:
```bash
kubectl get pods -l app.kubernetes.io/instance=external-secrets
```

---

# 🔑 Step 7: Configure ESO with Vault

Create `secret-store-vault.yaml`:
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

```bash
kubectl apply -f secret-store-vault.yaml
```

Create `external-secret-vault.yaml`:
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

```bash
kubectl apply -f external-secret-vault.yaml
```

Check synced secret:
```bash
kubectl get secret synced-secret -o yaml
```

---

# 🌍 Step 8: ESO with AWS Secrets Manager

You can also fetch secrets directly from **AWS Secrets Manager** using ESO.

### 1. Create IAM User/Role with permissions
Attach policy with at least:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      "Resource": "*"
    }
  ]
}
```

### 2. Store AWS credentials in Kubernetes Secret
```bash
kubectl create secret generic aws-credentials   --from-literal=access-key=<AWS_ACCESS_KEY_ID>   --from-literal=secret-access-key=<AWS_SECRET_ACCESS_KEY>
```

### 3. Create ESO SecretStore for AWS
```yaml
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: aws-backend
spec:
  provider:
    aws:
      service: SecretsManager
      region: ap-south-1
      auth:
        secretRef:
          accessKeyIDSecretRef:
            name: aws-credentials
            key: access-key
          secretAccessKeySecretRef:
            name: aws-credentials
            key: secret-access-key
```

Apply it:
```bash
kubectl apply -f secret-store-aws.yaml
```

### 4. Create ExternalSecret for AWS
```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: aws-secret-sync
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: aws-backend
    kind: SecretStore
  target:
    name: aws-synced-secret
    creationPolicy: Owner
  data:
  - secretKey: db_username
    remoteRef:
      key: myapp/database
      property: username
  - secretKey: db_password
    remoteRef:
      key: myapp/database
      property: password
```

Apply:
```bash
kubectl apply -f external-secret-aws.yaml
```

Check:
```bash
kubectl get secret aws-synced-secret -o yaml
```

---

# ✅ Summary

- Vault deployed with Helm ✅  
- Secrets stored in Vault KV ✅  
- Kubernetes auth + ESO integration ✅  
- ESO also integrated with **AWS Secrets Manager** ✅  
- Kubernetes pods can consume secrets from both Vault and AWS transparently ✅  
