
(define-constant ERR-SLIPPAGE (err u1001))

(define-public (check-min-out (amount-out uint) (min-accepted uint)) (if (>= amount-out min-accepted) (ok true) ERR-SLIPPAGE))
