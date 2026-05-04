#!/bin/bash

echo "===== Rollback Started ====="

# Rollback dev environment
echo "Rolling back Dev..."
kubectl rollout undo deployment/multi-env-dev -n dev
kubectl rollout status deployment/multi-env-dev -n dev --timeout=60s

# Rollback prod environment
echo "Rolling back Prod..."
kubectl rollout undo deployment/multi-env-prod -n prod
kubectl rollout status deployment/multi-env-prod -n prod --timeout=60s

echo "===== Rollback Complete ====="