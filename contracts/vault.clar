;; Vault Contract
;; Main treasury that holds assets and delegates trading to approved strategies
;; Implements on-chain guardrails via post-conditions

(use-trait executor-trait .traits.executor-trait)

;; Error constants
(define-constant ERR-VAULT-AUTH (err u4001))
(define-constant ERR-MIN-OUT (err u4002))
(define-constant ERR-INSUFFICIENT-FUNDS (err u4003))
(define-constant ERR-PAUSED (err u4004))
(define-constant ERR-NOT-MANAGER (err u4005))

;; Data variables
(define-data-var locked-funds uint u0)
(define-data-var total-deposited uint u0)
(define-data-var total-withdrawn uint u0)
(define-data-var daily-withdrawal-limit uint u10000000) ;; 10M microSTX per day
(define-data-var last-reset-block uint u0)

;; Data maps
(define-map user-deposits principal uint)
(define-map execution-history uint {
  strategy: principal,
  amount: uint,
  result: bool,
  block: uint
})
(define-data-var execution-count uint u0)

;; Deposit STX into the vault
(define-public (deposit (amount uint))
  (let
    (
      (current-balance (default-to u0 (map-get? user-deposits tx-sender)))
    )
    (asserts! (> amount u0) ERR-INSUFFICIENT-FUNDS)
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    
    ;; Update state
    (var-set locked-funds (+ (var-get locked-funds) amount))
    (var-set total-deposited (+ (var-get total-deposited) amount))
    (map-set user-deposits tx-sender (+ current-balance amount))
    
    (ok amount)
  )
)

;; Withdraw STX from the vault
(define-public (withdraw (amount uint))
  (let
    (
      (user-balance (default-to u0 (map-get? user-deposits tx-sender)))
    )
    (asserts! (<= amount user-balance) ERR-INSUFFICIENT-FUNDS)
    (asserts! (<= amount (var-get locked-funds)) ERR-INSUFFICIENT-FUNDS)
    
    ;; Transfer and update state
    (try! (as-contract (stx-transfer? amount tx-sender tx-sender)))
    (var-set locked-funds (- (var-get locked-funds) amount))
    (var-set total-withdrawn (+ (var-get total-withdrawn) amount))
    (map-set user-deposits tx-sender (- user-balance amount))
    
    (ok amount)
  )
)

;; Execute strategy with guardrails
;; This is where post-conditions would be enforced
(define-public (execute-strategy (strategy <executor-trait>) (amount uint) (min-expected-out uint))
  (let
    (
      (balance-before (stx-get-balance (as-contract tx-sender)))
      (is-paused (contract-call? .governance get-paused))
      (current-count (var-get execution-count))
    )
    ;; Pre-checks
    (asserts! (not is-paused) ERR-PAUSED)
    (asserts! (contract-call? .governance is-manager tx-sender) ERR-NOT-MANAGER)
    (asserts! (<= amount (var-get locked-funds)) ERR-VAULT-AUTH)
    
    ;; Execute strategy
    (match (as-contract (contract-call? strategy execute amount))
      success
        (let
          (
            (balance-after (stx-get-balance (as-contract tx-sender)))
          )
          ;; Record execution
          (map-set execution-history current-count {
            strategy: (contract-of strategy),
            amount: amount,
            result: true,
            block: block-height
          })
          (var-set execution-count (+ current-count u1))
          
          ;; Post-condition: Check minimum output (guardrail)
          (asserts! (>= balance-after min-expected-out) ERR-MIN-OUT)
          (ok true)
        )
      error
        (begin
          ;; Record failed execution
          (map-set execution-history current-count {
            strategy: (contract-of strategy),
            amount: amount,
            result: false,
            block: block-height
          })
          (var-set execution-count (+ current-count u1))
          (err error)
        )
    )
  )
)

;; Read-only functions
(define-read-only (get-balance)
  (ok (var-get locked-funds))
)

(define-read-only (get-user-balance (user principal))
  (ok (default-to u0 (map-get? user-deposits user)))
)

(define-read-only (get-total-deposited)
  (ok (var-get total-deposited))
)

(define-read-only (get-total-withdrawn)
  (ok (var-get total-withdrawn))
)

(define-read-only (get-execution-history (execution-id uint))
  (map-get? execution-history execution-id)
)

(define-read-only (check-active)
  (let
    (
      (is-paused (contract-call? .governance get-paused))
    )
    (ok (not is-paused))
  )
)