# Cilium mTLS PoC

PoC demonstrating service mesh with mutual TLS using Cilium on local Kind cluster.

## Prerequisites

- Docker or Colima
- Kind
- Cilium CLI (`brew install cilium-cli`)
- Helm

## Quick Start

### Phase 1: Setup Cluster & Cilium

```bash
# Start colima (if using macOS)
make start-colima

# Create cluster + install Cilium
make setup

# Verify
make status
```

### Phase 2: Enable Encryption & Observability

```bash
# WireGuard encryption + Hubble + cert-manager + network policies
make setup2

# Or individually:
make cilium-encrypt   # Enable WireGuard
make hubble          # Enable Hubble UI
make cert-manager    # Install cert-manager
make network-policies
```

## Verification

### Check Cluster Status

```bash
# All nodes ready
kubectl get nodes

# Cilium status
cilium status

# WireGuard encryption (use kubectl exec - CLI has parsing bug)
kubectl exec -n kube-system cilium-xxx -- cilium encrypt status
```

> **Note:** `cilium encrypt status` CLI command has a parsing bug. Use `kubectl exec` as shown above.

Expected output:
```
Encryption: Wireguard                 
Interface: cilium_wg0
    Public key: ...
    Number of peers: 2
```

### Test Connectivity

```bash
# Deploy test pods
kubectl create deployment nginx --image=nginx --replicas=2
kubectl scale deployment nginx --replicas=0

# Wait for pods
kubectl get pods -l app=nginx -o wide

# Test pod-to-pod connectivity
kubectl run test --image=curlimages/curl --rm -it --restart=Never -- curl -s http://<nginx-pod-ip>
```

### Check Hubble Flows

```bash
# Port-forward Hubble Relay (run in background)
cilium hubble port-forward &

# Observe flows from a pod (use hubble CLI, not cilium)
hubble observe --from-pod default/nginx-xxx --last 10

# Or open Hubble UI
cilium hubble ui
```

### Verify Encryption

Traffic between pods on different nodes is encrypted via WireGuard:

```bash
# Check encryption is enabled
cilium encrypt status

# Verify WireGuard interface exists on each node
kubectl exec -n kube-system cilium-xxx -- ip addr show cilium_wg0
```

## Project Structure

```
├── Makefile              # Automation targets
├── kind-config.yaml      # Kind cluster config
├── cilium-values.yaml    # Cilium Helm values
├── manifests/
│   └── network-policies/ # CiliumNetworkPolicies
├── docs/
│   └── plan.md          # Implementation plan
└── README.md
```

## Available Make Targets

| Target | Description |
|--------|-------------|
| `make setup` | Phase 1: cluster + Cilium |
| `make setup2` | Phase 2: encryption + Hubble + cert-manager |
| `make cluster` | Create Kind cluster |
| `make cilium` | Install Cilium |
| `make cilium-encrypt` | Enable WireGuard |
| `make hubble` | Enable Hubble |
| `make cert-manager` | Install cert-manager |
| `make network-policies` | Apply network policies |
| `make status` | Check Cilium status |
| `make test` | Run connectivity test |
| `make clean` | Delete cluster |

## Components

- **Cilium v1.14.6** - eBPF-based networking
- **WireGuard** - Node-to-node encryption
- **Hubble** - Observability
- **cert-manager** - Certificate management

## Cleanup

```bash
make clean
```
