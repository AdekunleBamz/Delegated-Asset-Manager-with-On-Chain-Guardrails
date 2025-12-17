
(define-constant ERR-VAULT-AUTH (err u4001))

(define-data-var locked-funds uint u0)

(use-trait executor-trait .traits.executor-trait)

(define-public (deposit (amount uint)) (begin (try! (stx-transfer? amount tx-sender (as-contract tx-sender))) (var-set locked-funds (+ (var-get locked-funds) amount)) (ok amount)))
