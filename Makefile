.PHONY: help setup cluster cilium status test clean

help:
	@echo "Cilium mTLS PoC - Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  setup     - Full Phase 1 setup: start colima + create cluster + install Cilium"
	@echo "  cluster   - Create Kind cluster only"
	@echo "  cilium   - Install Cilium on existing cluster"
	@echo "  status   - Check Cilium status"
	@echo "  test     - Run Cilium connectivity test"
	@echo "  clean    - Delete Kind cluster"

setup: cluster cilium status

cluster:
	@echo "Creating Kind cluster..."
	@kind create cluster --config kind-config.yaml
	@echo "Cluster created successfully"

cilium:
	@echo "Installing Cilium..."
	@cilium install --version 1.14.6
	@echo "Waiting for Cilium to be ready..."
	@sleep 30
	@kubectl wait --for=condition=ready pod -l k8s-app=cilium -n kube-system --timeout=120s || true

status:
	@echo "Checking Cilium status..."
	@cilium status

test:
	@echo "Running Cilium connectivity test..."
	@cilium connectivity test --timeout=5m

clean:
	@echo "Deleting Kind cluster..."
	@kind delete cluster --name cilium-mtls-poc

start-colima:
	@echo "Starting colima..."
	@colima start
