
(define-constant ERR-NOT-AUTH (err u3001))

(define-data-var contract-admin principal tx-sender)

(define-map managers principal bool)

(define-public (set-manager (mgr principal) (allowed bool)) (begin (asserts! (is-eq tx-sender (var-get contract-admin)) ERR-NOT-AUTH) (ok (map-set managers mgr allowed))))
