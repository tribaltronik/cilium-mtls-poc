#!/bin/bash
# Validation script for Cilium mTLS PoC

set -e

echo "=== Cilium mTLS PoC Validation ==="
echo ""

# Check nodes
echo "1. Checking cluster nodes..."
kubectl get nodes
echo ""

# Check Cilium status
echo "2. Checking Cilium status..."
cilium status
echo ""

# Check WireGuard encryption
echo "3. Checking WireGuard encryption..."
CILIUM_POD=$(kubectl get pods -n kube-system -l k8s-app=cilium -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n kube-system $CILIUM_POD -- cilium encrypt status
echo ""

# Check Hubble
echo "4. Checking Hubble..."
kubectl get pods -n kube-system | grep hubble
echo ""

# Check demo apps
echo "5. Checking demo apps..."
kubectl get pods -l app=frontend,app=middleware,app=backend
echo ""

# Test connectivity
echo "6. Testing connectivity..."
kubectl run test-validate --image=curlimages/curl --restart=Never -- sh -c "curl -s http://frontend.default.svc.cluster.local:8080" 2>/dev/null || true
sleep 3
kubectl delete pod test-validate --ignore-not-found=true
echo ""

# Check network policies
echo "7. Checking network policies..."
kubectl get cnp -A
echo ""

echo "=== Validation Complete ==="
