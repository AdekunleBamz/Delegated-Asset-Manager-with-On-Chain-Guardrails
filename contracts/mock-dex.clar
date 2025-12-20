;; Mock DEX Contract
;; Simulates a decentralized exchange for testing the asset manager

;; Error constants
(define-constant ERR-INSUFFICIENT-LIQ (err u2001))
(define-constant ERR-ZERO-AMOUNT (err u2002))
(define-constant ERR-POOL-NOT-FOUND (err u2003))

;; Data maps
(define-map pools principal uint)
(define-map swap-history uint {from: principal, amount-in: uint, amount-out: uint, block: uint})

;; Data variables
(define-data-var swap-count uint u0)
(define-data-var fee-rate uint u5) ;; 5% fee

;; Initialize a pool
(define-public (init-pool (token principal) (liquidity uint))
  (ok (map-set pools token liquidity))
)

;; Get pool liquidity
(define-read-only (get-pool-liquidity (token principal))
  (ok (default-to u0 (map-get? pools token)))
)

;; Swap function with fee
(define-public (swap (amount-in uint))
  (let
    (
      (fee (/ (* amount-in (var-get fee-rate)) u100))
      (amount-after-fee (- amount-in fee))
      (amount-out (/ (* amount-after-fee u95) u100))
      (current-count (var-get swap-count))
    )
    (asserts! (> amount-in u0) ERR-ZERO-AMOUNT)
    
    ;; Record swap history
    (map-set swap-history current-count {
      from: tx-sender,
      amount-in: amount-in,
      amount-out: amount-out,
      block: block-height
    })
    (var-set swap-count (+ current-count u1))
    
    (ok amount-out)
  )
)

;; Get swap history
(define-read-only (get-swap-history (swap-id uint))
  (map-get? swap-history swap-id)
)

;; Update fee rate (for testing)
(define-public (set-fee-rate (new-rate uint))
  (ok (var-set fee-rate new-rate))
)
