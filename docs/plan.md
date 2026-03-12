# Cilium + mTLS on Kind - Implementation Plan

## Overview
PoC demonstrating service mesh with mutual TLS using Cilium on local Kind cluster.

## Phase 1: Foundation
**Goal:** Working Kind cluster with Cilium CNI

- [x] Create `kind-config.yaml` with multi-node setup (1 control, 2 workers)
- [x] Disable default CNI in Kind config
- [x] Install Cilium CLI (`cilium install`)
- [x] Verify: `cilium status`, `cilium connectivity test`

**Deliverables:**
- `kind-config.yaml` - Multi-node Kind cluster config
- `Makefile` - Automation for setup/teardown
- Cluster validation: 3 nodes ready, Cilium 3/3

## Phase 2: mTLS Setup
**Goal:** Enable encrypted service-to-service communication

- [ ] Configure Cilium with encryption enabled
- [ ] Choose backend: WireGuard (preferred) or IPsec
- [ ] Install cert-manager for certificate lifecycle
- [ ] Configure mutual authentication policies
- [ ] Enable Hubble for observability

**Deliverables:**
- `cilium-values.yaml` with encryption config
- Cert-manager manifests

## Phase 3: Demo Applications
**Goal:** Multi-tier app with mTLS enforcement

- [ ] Deploy 3 services: frontend → middleware → backend
- [ ] Apply basic NetworkPolicies (L3/L4)
- [ ] Create CiliumNetworkPolicy for L7 filtering
- [ ] Configure mTLS between all pods
- [ ] Add service-specific identity labels

**Deliverables:**
- `manifests/demo-apps/` directory
- `manifests/network-policies/` directory

## Phase 4: Validation
**Goal:** Prove mTLS is working

- [ ] Access Hubble UI - visualize encrypted flows
- [ ] Capture traffic with tcpdump (should be encrypted)
- [ ] Verify certificate rotation
- [ ] Break mTLS intentionally (wrong cert, no cert)
- [ ] Document expected vs actual behavior

**Deliverables:**
- Validation scripts
- Screenshots/logs proving encryption

## Phase 5: Automation
**Goal:** One-command setup/teardown

- [ ] Create Makefile with targets:
  - `make setup` - create cluster + install Cilium
  - `make deploy` - deploy demo apps
  - `make verify` - run validation tests
  - `make clean` - teardown everything
- [ ] Write comprehensive README
- [ ] Add architecture diagram
- [ ] (Optional) GitHub Actions for CI

**Deliverables:**
- `Makefile`
- `README.md`
- Architecture diagram

## Project Structure
```
cilium-mtls-poc/
├── plan.md
├── README.md
├── Makefile
├── kind-config.yaml
├── cilium-values.yaml
├── manifests/
│   ├── demo-apps/
│   │   ├── frontend.yaml
│   │   ├── middleware.yaml
│   │   └── backend.yaml
│   └── network-policies/
│       ├── frontend-policy.yaml
│       ├── middleware-policy.yaml
│       └── backend-policy.yaml
└── scripts/
    ├── validate-mtls.sh
    └── test-encryption.sh
```

## Technical Decisions

**Why Cilium?**
- eBPF-based (kernel-level efficiency)
- Native encryption support (WireGuard/IPsec)
- L7-aware network policies
- Strong observability with Hubble
- Good for DevSecOps interviews

**Why WireGuard over IPsec?**
- Simpler configuration
- Better performance
- Modern crypto
- Easier debugging

**Success Criteria:**
1. All pod-to-pod traffic encrypted
2. Certificates auto-rotate
3. Failed auth attempts blocked
4. Hubble shows encrypted flows
5. One-command setup works

## Timeline
- Phase 1: 30 min
- Phase 2: 1 hour
- Phase 3: 1 hour
- Phase 4: 45 min
- Phase 5: 1 hour

**Total: ~4 hours**

## Next Steps
1. Start with Phase 1 - create kind-config.yaml
2. Test cluster creation
3. Move to Cilium installation