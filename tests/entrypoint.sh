#!/usr/bin/env bash
set -euo pipefail

PLAYBOOK_ARGS=(-e ci_test=true -e ansible_become=false --connection=local)
SERVER_ARGS=(-e ci_test=true -e ansible_become=false --connection=local -e openclaw_user=server)

# --- Step 1: Convergence ---
echo "===> Step 1: Convergence test"
ansible-playbook playbook.yml "${PLAYBOOK_ARGS[@]}"
echo "===> Convergence: PASSED"

# --- Step 2: Verification ---
echo "===> Step 2: Verification"
ansible-playbook tests/verify.yml "${PLAYBOOK_ARGS[@]}"
echo "===> Verification: PASSED"

# --- Step 3: Custom user convergence + verification ---
echo "===> Step 3: Custom user convergence test"
ansible-playbook playbook.yml "${SERVER_ARGS[@]}"
echo "===> Custom user convergence: PASSED"

echo "===> Step 4: Custom user verification"
ansible-playbook tests/verify.yml "${SERVER_ARGS[@]}"
echo "===> Custom user verification: PASSED"

# --- Step 5: Idempotency ---
echo "===> Step 5: Idempotency test"
IDEMPOTENCY_OUT=$(ansible-playbook playbook.yml "${PLAYBOOK_ARGS[@]}" 2>&1)
echo "$IDEMPOTENCY_OUT"

CHANGED=$(echo "$IDEMPOTENCY_OUT" | tail -n 5 | grep -oP 'changed=\K[0-9]+' | head -1)
if [ "${CHANGED:-1}" -eq 0 ]; then
  echo "===> Idempotency: PASSED (0 changed)"
else
  echo "===> Idempotency: FAILED (changed=$CHANGED)"
  exit 1
fi

echo ""
echo "===> All tests passed"
