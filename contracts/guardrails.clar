
(define-constant ERR-SLIPPAGE (err u1001))

(define-public (check-min-out (amount-out uint) (min-accepted uint)) (if (>= amount-out min-accepted) (ok true) ERR-SLIPPAGE))

(define-constant MAX-TX-AMOUNT u1000000000) (define-read-only (check-max-tx (amount uint) ) (if (< amount MAX-TX-AMOUNT) (ok true) (err u1002)))

(define-map whitelisted-tokens principal bool) (define-public (set-token-status (token principal) (status bool)) (ok (map-set whitelisted-tokens token status)))
