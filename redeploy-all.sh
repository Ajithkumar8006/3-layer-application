#!/bin/sh

# Kubernetes manifest files
BACKEND_MANIFEST=backend.yaml
FRONTEND_MANIFEST=frontend.yaml

# Deployment names
BACKEND_DEPLOYMENT=backend
FRONTEND_DEPLOYMENT=frontend

# Function to start a port-forward, killing any process already using the same port
start_port_forward() {
    local cmd="$1"
    local port="$2"

    # Check if the port is already in use and kill it
    pid=$(lsof -ti tcp:$port)
    if [ -n "$pid" ]; then
        echo "🛑 Port $port already in use, killing process $pid..."
        kill -9 $pid
        sleep 1
    fi

    echo "🚀 Starting port-forward: $cmd"
    $cmd >/dev/null 2>&1 &
    echo "✅ Port-forward started"
}

echo "🛑 Deleting backend and frontend deployments..."
kubectl delete deployment $BACKEND_DEPLOYMENT
kubectl delete deployment $FRONTEND_DEPLOYMENT

echo "⏳ Waiting 5 seconds for resources to terminate..."
sleep 5

echo "📥 Re-applying manifests..."
kubectl apply -f $BACKEND_MANIFEST
kubectl apply -f $FRONTEND_MANIFEST

echo "⏳ Waiting for pods to become ready (up to 60s each)..."
kubectl wait --for=condition=ready pod -l app=$BACKEND_DEPLOYMENT --timeout=60s
kubectl wait --for=condition=ready pod -l app=$FRONTEND_DEPLOYMENT --timeout=60s

echo "✅ All resources re-applied and pods are ready."
kubectl get pods

echo "🌐 Starting port-forwards (kill if in use)..."
start_port_forward "kubectl port-forward --address 0.0.0.0 svc/frontend-service 30080:80" 30080
start_port_forward "kubectl port-forward --address 0.0.0.0 svc/backend-service 3002:3002" 3002

echo "✅ Port-forwarding complete. Access services via:"
echo "Frontend: http://localhost:30080"
echo "Backend API: http://localhost:3002/api/persons"