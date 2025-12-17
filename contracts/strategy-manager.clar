
(use-trait vault-trait .traits.executor-trait)

(impl-trait .traits.executor-trait)

(define-constant ERR-STRATEGY-FAIL (err u5001))

(define-public (execute (amount uint)) (begin (ok true)))

(define-private (do-swap (amount uint)) (contract-call? .mock-dex swap amount))
