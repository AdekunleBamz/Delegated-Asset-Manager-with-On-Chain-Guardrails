;; Governance Contract
;; Manages admin controls, manager whitelist, and emergency pause functionality

;; Error constants
(define-constant ERR-NOT-AUTH (err u3001))
(define-constant ERR-ALREADY-PAUSED (err u3002))
(define-constant ERR-NOT-PAUSED (err u3003))

;; Data variables
(define-data-var contract-admin principal tx-sender)
(define-data-var paused bool false)

;; Data maps
(define-map managers principal bool)

;; Admin functions
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-admin)) ERR-NOT-AUTH)
    (ok (var-set contract-admin new-admin))
  )
)

(define-read-only (get-admin)
  (var-get contract-admin)
)

;; Manager whitelist functions
(define-public (set-manager (mgr principal) (allowed bool))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-admin)) ERR-NOT-AUTH)
    (ok (map-set managers mgr allowed))
  )
)

(define-read-only (is-manager (mgr principal))
  (default-to false (map-get? managers mgr))
)

;; Emergency pause functions
(define-public (set-paused (state bool))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-admin)) ERR-NOT-AUTH)
    (if state
      (asserts! (not (var-get paused)) ERR-ALREADY-PAUSED)
      (asserts! (var-get paused) ERR-NOT-PAUSED)
    )
    (ok (var-set paused state))
  )
)

(define-read-only (get-paused)
  (var-get paused)
)
