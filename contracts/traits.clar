;; Traits for Delegated Asset Manager
;; Defines the core interfaces for the system

;; Executor trait - for strategies that can execute trades
(define-trait executor-trait
  (
    (execute (uint) (response bool uint))
  )
)

;; Vault trait - for vault operations
(define-trait vault-trait
  (
    (deposit (uint) (response uint uint))
    (get-balance () (response uint uint))
  )
)
