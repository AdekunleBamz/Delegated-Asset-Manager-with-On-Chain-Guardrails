
(use-trait vault-trait .traits.executor-trait)

(impl-trait .traits.executor-trait)

(define-constant ERR-STRATEGY-FAIL (err u5001))

(define-public (execute (amount uint)) (begin (ok true)))
