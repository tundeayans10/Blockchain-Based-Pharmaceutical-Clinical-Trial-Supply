;; Temperature Monitoring Contract
;; Ensures proper storage conditions for trial medications

(define-data-var contract-owner principal tx-sender)

;; Map to store temperature logs
(define-map temperature-logs
  {
    batch-id: (string-utf8 50),
    timestamp: uint
  }
  {
    temperature: int,
    humidity: uint,
    recorder: principal,
    is-compliant: bool
  }
)

;; Map to store batch temperature thresholds
(define-map batch-thresholds
  (string-utf8 50)  ;; batch-id
  {
    min-temp: int,
    max-temp: int,
    min-humidity: uint,
    max-humidity: uint,
    created-at: uint
  }
)

;; Map to track temperature violations
(define-map temperature-violations
  (string-utf8 50)  ;; batch-id
  {
    violation-count: uint,
    last-violation-at: uint
  }
)

;; Set temperature thresholds for a batch
(define-public (set-batch-thresholds
    (batch-id (string-utf8 50))
    (min-temp int)
    (max-temp int)
    (min-humidity uint)
    (max-humidity uint))
  (begin
    (asserts! (is-contract-owner tx-sender) (err u403))
    (ok (map-set batch-thresholds
      batch-id
      {
        min-temp: min-temp,
        max-temp: max-temp,
        min-humidity: min-humidity,
        max-humidity: max-humidity,
        created-at: block-height
      }
    ))
  )
)

;; Record temperature reading
(define-public (record-temperature
    (batch-id (string-utf8 50))
    (temperature int)
    (humidity uint))
  (let
    (
      (thresholds (unwrap! (map-get? batch-thresholds batch-id) (err u404)))
      (is-temp-compliant (and
        (>= temperature (get min-temp thresholds))
        (<= temperature (get max-temp thresholds))
      ))
      (is-humidity-compliant (and
        (>= humidity (get min-humidity thresholds))
        (<= humidity (get max-humidity thresholds))
      ))
      (is-compliant (and is-temp-compliant is-humidity-compliant))
      (current-violations (default-to
        { violation-count: u0, last-violation-at: u0 }
        (map-get? temperature-violations batch-id)
      ))
      (new-violation-count (if is-compliant
        (get violation-count current-violations)
        (+ (get violation-count current-violations) u1)
      ))
    )
    (begin
      ;; Record the temperature log
      (map-set temperature-logs
        { batch-id: batch-id, timestamp: block-height }
        {
          temperature: temperature,
          humidity: humidity,
          recorder: tx-sender,
          is-compliant: is-compliant
        }
      )

      ;; Update violations if non-compliant
      (if (not is-compliant)
        (map-set temperature-violations
          batch-id
          {
            violation-count: new-violation-count,
            last-violation-at: block-height
          }
        )
        true
      )

      (ok is-compliant)
    )
  )
)

;; Get temperature compliance status
(define-read-only (get-compliance-status (batch-id (string-utf8 50)))
  (map-get? temperature-violations batch-id)
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
