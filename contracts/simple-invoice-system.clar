;; Simple Invoice System
;; Stores basic invoice data and allows payment status update

(define-map invoices uint
  {
    sender: principal,
    recipient: principal,
    amount: uint,
    description: (string-ascii 64),
    is-paid: bool
  }
)

(define-data-var invoice-counter uint u0)

;; Function 1: Create a new invoice
(define-public (create-invoice (recipient principal) (amount uint) (description (string-ascii 64)))
  (begin
    (asserts! (> amount u0) (err u100)) ;; amount must be greater than 0
    (var-set invoice-counter (+ (var-get invoice-counter) u1))
    (map-set invoices (var-get invoice-counter)
      {
        sender: tx-sender,
        recipient: recipient,
        amount: amount,
        description: description,
        is-paid: false
      })
    (ok (var-get invoice-counter))
  )
)

;; Function 2: Mark invoice as paid
(define-public (mark-paid (invoice-id uint))
  (let ((invoice (map-get? invoices invoice-id)))
    (match invoice
      inv
        (begin
          (asserts! (is-eq (get recipient inv) tx-sender) (err u101)) ;; Only recipient can mark paid
          (map-set invoices invoice-id
            {
              sender: (get sender inv),
              recipient: (get recipient inv),
              amount: (get amount inv),
              description: (get description inv),
              is-paid: true
            })
          (ok true)
        )
      (err u102) ;; Invoice not found
    )
  )
)
