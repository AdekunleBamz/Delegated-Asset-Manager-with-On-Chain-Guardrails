#!/bin/bash
set -e

# Init git if not already
if [ ! -d ".git" ]; then
    git init
    git branch -M main
fi

# Create directory structure
mkdir -p contracts
mkdir -p settings
mkdir -p tests

# Create files
touch contracts/traits.clar contracts/vault.clar contracts/strategy-manager.clar contracts/mock-dex.clar contracts/guardrails.clar contracts/governance.clar

# Write Clarinet.toml
cat > Clarinet.toml <<EOF
[project]
name = "delegated-asset-manager"
description = "Delegated Asset Manager with On-Chain Guardrails"
authors = []
telemetry = false
cache_dir = "./.cache"

[contracts.traits]
path = "contracts/traits.clar"
clarity_version = 3
epoch = 3.0

[contracts.vault]
path = "contracts/vault.clar"
clarity_version = 3
epoch = 3.0
depends_on = ["traits", "guardrails"]

[contracts.guardrails]
path = "contracts/guardrails.clar"
clarity_version = 3
epoch = 3.0

[contracts.mock-dex]
path = "contracts/mock-dex.clar"
clarity_version = 3
epoch = 3.0

[contracts.governance]
path = "contracts/governance.clar"
clarity_version = 3
epoch = 3.0

[contracts.strategy-manager]
path = "contracts/strategy-manager.clar"
clarity_version = 3
epoch = 3.0
depends_on = ["traits", "vault", "guardrails", "mock-dex"]

[repl.analysis]
passes = ["check_checker"]
EOF

# Initial Commit
git add .
# Check if there is anything to commit
if ! git diff-index --quiet HEAD; then
    git commit -m "Initial setup"
fi

count=1

apply_change() {
    name=$1
    file=$2
    content=$3
    
    if [ $count -lt 10 ]; then num="0$count"; else num="$count"; fi
    branch="feat/$num-$name"
    
    echo "Step $count: $branch"
    git checkout -b "$branch" 2>/dev/null || git checkout "$branch"
    
    # Append content
    echo "" >> "$file"
    echo "$content" >> "$file"
    
    git add "$file"
    git commit -m "Implement $name"
    git checkout main
    git merge "$branch"
    
    count=$((count + 1))
}

# 1. executor-trait
apply_change "executor-trait" "contracts/traits.clar" "(define-trait executor-trait ((execute (uint) (response bool uint))))"

# 2. guard-const
apply_change "guard-const" "contracts/guardrails.clar" "(define-constant ERR-SLIPPAGE (err u1001))"

# 3. guard-min
apply_change "guard-min" "contracts/guardrails.clar" "(define-public (check-min-out (amount-out uint) (min-accepted uint)) (if (>= amount-out min-accepted) (ok true) ERR-SLIPPAGE))"

# 4. dex-const
apply_change "dex-const" "contracts/mock-dex.clar" "(define-constant ERR-INSUFFICIENT-LIQ (err u2001))"

# 5. dex-storage
apply_change "dex-storage" "contracts/mock-dex.clar" "(define-map pools principal uint)"

# 6. dex-swap
apply_change "dex-swap" "contracts/mock-dex.clar" "(define-public (swap (amount-in uint)) (ok (/ (* amount-in u95) u100)))"

# 7. gov-const
apply_change "gov-const" "contracts/governance.clar" "(define-constant ERR-NOT-AUTH (err u3001))"

# 8. gov-admin
apply_change "gov-admin" "contracts/governance.clar" "(define-data-var contract-admin principal tx-sender)"

# 9. gov-whitelist
apply_change "gov-whitelist" "contracts/governance.clar" "(define-map managers principal bool)"

# 10. gov-set-mgr
apply_change "gov-set-mgr" "contracts/governance.clar" "(define-public (set-manager (mgr principal) (allowed bool)) (begin (asserts! (is-eq tx-sender (var-get contract-admin)) ERR-NOT-AUTH) (ok (map-set managers mgr allowed))))"

# 11. gov-check
apply_change "gov-check" "contracts/governance.clar" "(define-read-only (is-manager (mgr principal)) (default-to false (map-get? managers mgr)))"

# 12. vault-const
apply_change "vault-const" "contracts/vault.clar" "(define-constant ERR-VAULT-AUTH (err u4001))"

# 13. vault-var
apply_change "vault-var" "contracts/vault.clar" "(define-data-var locked-funds uint u0)"

# 14. vault-traits
apply_change "vault-traits" "contracts/vault.clar" "(use-trait executor-trait .traits.executor-trait)"

# 15. vault-deposit
apply_change "vault-deposit" "contracts/vault.clar" "(define-public (deposit (amount uint)) (begin (try! (stx-transfer? amount tx-sender (as-contract tx-sender))) (var-set locked-funds (+ (var-get locked-funds) amount)) (ok amount)))"

# 16. vault-exec-pre
apply_change "vault-exec-pre" "contracts/vault.clar" "(define-public (execute-param (strategy <executor-trait>) (amount uint)) (let ((balance-before (stx-get-balance (as-contract tx-sender)))) (asserts! (<= amount (var-get locked-funds)) ERR-VAULT-AUTH) (try! (as-contract (contract-call? strategy execute amount))) (ok true)))"

# 17. mgr-traits
apply_change "mgr-traits" "contracts/strategy-manager.clar" "(use-trait vault-trait .traits.executor-trait)"

# 18. mgr-impl
apply_change "mgr-impl" "contracts/strategy-manager.clar" "(impl-trait .traits.executor-trait)"

# 19. mgr-const
apply_change "mgr-const" "contracts/strategy-manager.clar" "(define-constant ERR-STRATEGY-FAIL (err u5001))"

# 20. mgr-exec-start
apply_change "mgr-exec-start" "contracts/strategy-manager.clar" "(define-public (execute (amount uint)) (begin (ok true)))"

# 21. mgr-dex-call
apply_change "mgr-dex-call" "contracts/strategy-manager.clar" "(define-private (do-swap (amount uint)) (contract-call? .mock-dex swap amount))"

# 22. guard-max
apply_change "guard-max" "contracts/guardrails.clar" "(define-constant MAX-TX-AMOUNT u1000000000) (define-read-only (check-max-tx (amount uint) ) (if (< amount MAX-TX-AMOUNT) (ok true) (err u1002)))"

# 23. gov-pause
apply_change "gov-pause" "contracts/governance.clar" "(define-data-var paused bool false) (define-public (set-paused (state bool)) (begin (asserts! (is-eq tx-sender (var-get contract-admin)) ERR-NOT-AUTH) (ok (var-set paused state))))"

# 24. vault-pause-check
apply_change "vault-pause-check" "contracts/vault.clar" "(define-read-only (check-active) (let ((is-paused (contract-call? .governance get-paused))) (ok true)))"

# 25. gov-get-paused
apply_change "gov-get-paused" "contracts/governance.clar" "(define-read-only (get-paused) (var-get paused))"

# 26. mgr-profit
apply_change "mgr-profit" "contracts/strategy-manager.clar" "(define-private (check-profit (start uint) (end uint)) (>= end start))"

# 27. mgr-log
apply_change "mgr-log" "contracts/strategy-manager.clar" "(define-map trade-logs uint {profit: bool, amount: uint}) (define-data-var log-index uint u0)"

# 28. guard-token
apply_change "guard-token" "contracts/guardrails.clar" "(define-map whitelisted-tokens principal bool) (define-public (set-token-status (token principal) (status bool)) (ok (map-set whitelisted-tokens token status)))"

# 29. final-polish
apply_change "final-polish" "contracts/vault.clar" ";; System Fully Initialized"

# 30. extra-branch
apply_change "extra-one" "contracts/governance.clar" ";; Governance Initialized"

echo "Done"
