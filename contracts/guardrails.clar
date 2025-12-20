;; Guardrails Contract
;; Enforces on-chain safety checks for trades and transactions

;; Error constants
(define-constant ERR-SLIPPAGE (err u1001))
(define-constant ERR-MAX-TX-EXCEEDED (err u1002))
(define-constant ERR-TOKEN-NOT-WHITELISTED (err u1003))

;; Constants
(define-constant MAX-TX-AMOUNT u1000000000) ;; 1 billion microSTX

;; Data maps
(define-map whitelisted-tokens principal bool)

;; Check minimum output for slippage protection
(define-public (check-min-out (amount-out uint) (min-accepted uint))
  (if (>= amount-out min-accepted)
    (ok true)
    ERR-SLIPPAGE
  )
)

;; Check maximum transaction amount
(define-read-only (check-max-tx (amount uint))
  (if (< amount MAX-TX-AMOUNT)
    (ok true)
    ERR-MAX-TX-EXCEEDED
  )
)

;; Set token whitelist status
(define-public (set-token-status (token principal) (status bool))
  (ok (map-set whitelisted-tokens token status))
)

;; Check if token is whitelisted
(define-read-only (is-token-whitelisted (token principal))
  (default-to false (map-get? whitelisted-tokens token))
)
