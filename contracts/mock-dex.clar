
(define-constant ERR-INSUFFICIENT-LIQ (err u2001))

(define-map pools principal uint)

(define-public (swap (amount-in uint)) (ok (/ (* amount-in u95) u100)))
