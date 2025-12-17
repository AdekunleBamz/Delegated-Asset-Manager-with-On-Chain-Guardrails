
(define-constant ERR-VAULT-AUTH (err u4001))

(define-data-var locked-funds uint u0)

(use-trait executor-trait .traits.executor-trait)

(define-public (deposit (amount uint)) (begin (try! (stx-transfer? amount tx-sender (as-contract tx-sender))) (var-set locked-funds (+ (var-get locked-funds) amount)) (ok amount)))

(define-public (execute-param (strategy <executor-trait>) (amount uint)) (let ((balance-before (stx-get-balance (as-contract tx-sender)))) (asserts! (<= amount (var-get locked-funds)) ERR-VAULT-AUTH) (try! (as-contract (contract-call? strategy execute amount))) (ok true)))

(define-read-only (check-active) (let ((is-paused (contract-call? .governance get-paused))) (ok true)))

;; System Fully Initialized