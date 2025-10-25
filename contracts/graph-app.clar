;; graph-app
;; Short & error-free Clarity contract for a decentralized calculation tracker

(define-data-var calc-counter uint u0)

(define-map calculations {id: uint}
  {creator: principal,
   expression: (string-ascii 50),
   result: uint,
   status: (string-ascii 10)})

;; Submit a simple calculation (e.g., addition or multiplication)
(define-public (submit-calculation (expression (string-ascii 50)) (result uint))
  (let
    (
      (id (var-get calc-counter))
    )
    (map-set calculations {id: id}
      {creator: tx-sender,
       expression: expression,
       result: result,
       status: "pending"})
    (var-set calc-counter (+ id u1))
    (ok id)
  )
)

;; Verify a calculation
(define-public (verify-calculation (id uint))
  (match (map-get? calculations {id: id})
    calc
    (if (is-eq (get status calc) "pending")
      (begin
        (map-set calculations {id: id}
          {creator: (get creator calc),
           expression: (get expression calc),
           result: (get result calc),
           status: "verified"})
        (ok "Calculation verified")
      )
      (err u1)) ;; not pending
    (err u2) ;; not found
  )
)

;; Reject a calculation
(define-public (reject-calculation (id uint))
  (match (map-get? calculations {id: id})
    calc
    (if (and (is-eq (get status calc) "pending") (is-eq tx-sender (get creator calc)))
      (begin
        (map-set calculations {id: id}
          {creator: (get creator calc),
           expression: (get expression calc),
           result: (get result calc),
           status: "rejected"})
        (ok "Calculation rejected")
      )
      (err u3)) ;; not pending or not creator
    (err u4) ;; not found
  )
)