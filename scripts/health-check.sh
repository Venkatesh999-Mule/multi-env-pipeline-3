#!/bin/bash

NAMESPACE=$1
PORT=$2
MINIKUBE_IP=$(minikube ip)
APP_URL="http://${MINIKUBE_IP}:${PORT}/health"
MAX_RETRIES=5
RETRY=0
STATUS=000

echo "===== Health Check - $NAMESPACE environment ====="
echo "Checking: $APP_URL"

while [ $RETRY -lt $MAX_RETRIES ]; do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
        --connect-timeout 5 $APP_URL)

    if [ "$STATUS" == "200" ]; then
        echo "Health check PASSED - HTTP $STATUS"
        break
    else
        echo "Attempt $((RETRY+1))/$MAX_RETRIES - status: $STATUS"
        RETRY=$((RETRY+1))
        sleep 10
    fi
done

PODS=$(kubectl get pods -n $NAMESPACE \
    --field-selector=status.phase=Running \
    --no-headers | wc -l)
echo "Running pods in $NAMESPACE: $PODS"

if [ "$STATUS" == "200" ] && [ "$PODS" -ge 1 ]; then
    echo "===== $NAMESPACE is HEALTHY ====="
    exit 0
else
    echo "===== $NAMESPACE FAILED - triggering rollback ====="
    exit 1
fi