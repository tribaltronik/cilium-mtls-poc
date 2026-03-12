.PHONY: help setup setup2 setup3 cluster cilium cilium-encrypt hubble hubble-port-forward cert-manager network-policies demo-apps status encrypt-status test clean

help:
	@echo "Cilium mTLS PoC - Makefile"
	@echo ""
	@echo "Phase 1 - Foundation:"
	@echo "  make setup       - Full Phase 1: cluster + Cilium"
	@echo "  make cluster     - Create Kind cluster"
	@echo "  make cilium      - Install Cilium"
	@echo ""
	@echo "Phase 2 - mTLS Setup:"
	@echo "  make setup2      - Full Phase 2: encryption + Hubble + cert-manager"
	@echo "  make cilium-encrypt - Enable WireGuard encryption"
	@echo "  make hubble      - Enable Hubble observability"
	@echo "  make hubble-port-forward - Port-forward Hubble Relay"
	@echo "  make cert-manager - Install cert-manager"
	@echo "  make network-policies - Apply network policies"
	@echo ""
	@echo "Phase 3 - Demo Apps:"
	@echo "  make setup3      - Full Phase 3: demo apps + policies"
	@echo "  make demo-apps   - Deploy demo applications"
	@echo ""
	@echo "Utilities:"
	@echo "  make status       - Check Cilium status"
	@echo "  make encrypt-status - Check WireGuard encryption"
	@echo "  make test        - Run connectivity test"
	@echo "  make clean       - Delete cluster"

setup: cluster cilium status
	@echo "Phase 1 complete!"

setup2: cilium-encrypt hubble cert-manager network-policies
	@echo "Phase 2 complete!"

setup3: demo-apps
	@echo "Phase 3 complete!"

cluster:
	@echo "Creating Kind cluster..."
	@kind create cluster --config kind-config.yaml
	@echo "Cluster created successfully"

cilium:
	@echo "Installing Cilium..."
	@cilium install --version 1.14.6
	@echo "Waiting for Cilium..."
	@sleep 30
	@kubectl wait --for=condition=ready pod -l k8s-app=cilium -n kube-system --timeout=120s || true

cilium-encrypt:
	@echo "Upgrading Cilium with encryption..."
	@helm upgrade cilium cilium/cilium --version 1.14.6 -n kube-system -f cilium-values.yaml
	@echo "Enabling WireGuard..."
	@cilium config set enable-wireguard true
	@echo "WireGuard encryption enabled"

hubble:
	@echo "Enabling Hubble..."
	@cilium hubble enable --relay=true --ui=true
	@echo "Hubble enabled"

cert-manager:
	@echo "Installing cert-manager..."
	@kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.0/cert-manager.yaml
	@kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=cert-manager -n cert-manager --timeout=120s
	@echo "cert-manager installed"

network-policies:
	@echo "Applying network policies..."
	@mkdir -p manifests/network-policies
	@kubectl apply -f manifests/network-policies/
	@echo "Network policies applied"

demo-apps:
	@echo "Deploying demo applications..."
	@mkdir -p manifests/demo-apps
	@kubectl apply -f manifests/demo-apps/
	@echo "Demo applications deployed"
	@echo "Testing connectivity..."
	@kubectl run test-demo --image=curlimages/curl --rm -it --restart=Never -- sh -c "curl -s http://frontend.default.svc.cluster.local:8080" || true

status:
	@echo "Checking Cilium status..."
	@cilium status

encrypt-status:
	@echo "Checking WireGuard encryption..."
	@kubectl exec -n kube-system $$(kubectl get pods -n kube-system -l k8s-app=cilium -o jsonpath='{.items[0].metadata.name}') -- cilium encrypt status

hubble-port-forward:
	@echo "Port-forwarding Hubble Relay..."
	@cilium hubble port-forward

test:
	@echo "Running Cilium connectivity test..."
	@cilium connectivity test --timeout=5m

clean:
	@echo "Deleting Kind cluster..."
	@kind delete cluster --name cilium-mtls-poc

start-colima:
	@echo "Starting colima..."
	@colima start
