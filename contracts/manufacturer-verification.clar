;; Manufacturer Verification Contract
;; Validates legitimate drug producers for clinical trials

(define-data-var contract-owner principal tx-sender)

;; Map to store verified manufacturers
(define-map verified-manufacturers principal {
  name: (string-utf8 100),
  license-id: (string-utf8 50),
  verified-at: uint,
  is-active: bool
})

;; Public function to verify if a manufacturer is legitimate
(define-read-only (is-verified-manufacturer (manufacturer principal))
  (match (map-get? verified-manufacturers manufacturer)
    manufacturer-data (get is-active manufacturer-data)
    false
  )
)

;; Add a new manufacturer (only contract owner can do this)
(define-public (add-manufacturer
    (manufacturer principal)
    (name (string-utf8 100))
    (license-id (string-utf8 50)))
  (begin
    (asserts! (is-contract-owner tx-sender) (err u403))
    (asserts! (is-none (map-get? verified-manufacturers manufacturer)) (err u100))
    (ok (map-set verified-manufacturers
      manufacturer
      {
        name: name,
        license-id: license-id,
        verified-at: block-height,
        is-active: true
      }
    ))
  )
)

;; Deactivate a manufacturer
(define-public (deactivate-manufacturer (manufacturer principal))
  (begin
    (asserts! (is-contract-owner tx-sender) (err u403))
    (asserts! (is-some (map-get? verified-manufacturers manufacturer)) (err u404))
    (match (map-get? verified-manufacturers manufacturer)
      manufacturer-data
        (ok (map-set verified-manufacturers
          manufacturer
          (merge manufacturer-data { is-active: false })))
      (err u404)
    )
  )
)

;; Check if caller is contract owner
(define-private (is-contract-owner (caller principal))
  (is-eq caller (var-get contract-owner))
)

;; Transfer ownership
(define-public (transfer-ownership (new-owner principal))
  (begin
    (asserts! (is-contract-owner tx-sender) (err u403))
    (ok (var-set contract-owner new-owner))
  )
)
