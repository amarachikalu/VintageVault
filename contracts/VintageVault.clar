;; VintageVault: Decentralized marketplace for vintage clothing
;; Allows listing, buying, and transferring ownership of vintage items with provenance

(define-data-var admin principal tx-sender)
(define-map listings
  { item-id: uint }
  {
    owner: principal,
    price: uint,
    name: (string-ascii 50),
    description: (string-ascii 500),
    year: uint,
    authenticated: bool
  }
)

(define-map item-history
  { item-id: uint, index: uint }
  {
    owner: principal,
    timestamp: uint,
    action: (string-ascii 20)
  }
)

(define-data-var next-item-id uint u1)
(define-map history-index-map 
  { item-id: uint }
  { index: uint }
)

;; Create a new listing
(define-public (list-item (name-input (string-ascii 50)) (description-input (string-ascii 500)) (year-input uint) (price-input uint))
  (let
    (
      (item-id (var-get next-item-id))
      (history-index u0)
      (name name-input)
      (description description-input)
      (year year-input)
      (price price-input)
    )
    ;; Input validation
    (asserts! (> price u0) (err u1))
    (asserts! (> (len name) u0) (err u5))
    (asserts! (> (len description) u0) (err u6))
    (asserts! (> year u0) (err u7))
    
    (map-set listings
      { item-id: item-id }
      {
        owner: tx-sender,
        price: price,
        name: name,
        description: description,
        year: year,
        authenticated: false
      }
    )
    (map-set item-history
      { item-id: item-id, index: history-index }
      {
        owner: tx-sender,
        timestamp: item-id,
        action: "listed"
      }
    )
    (map-set history-index-map 
      { item-id: item-id }
      { index: u1 }
    )
    (var-set next-item-id (+ item-id u1))
    (ok item-id)
  )
)

;; Purchase an item
(define-public (purchase-item (item-id-input uint))
  (let
    (
      (item-id item-id-input)
      (listing (unwrap! (map-get? listings { item-id: item-id }) (err u2)))
      (price (get price listing))
      (seller (get owner listing))
      (history-index-data (default-to { index: u0 } (map-get? history-index-map { item-id: item-id })))
      (history-index (get index history-index-data))
      (new-history-index (+ history-index u1))
    )
    ;; Input validation
    (asserts! (> item-id u0) (err u8))
    (asserts! (not (is-eq tx-sender seller)) (err u3))
    
    (try! (stx-transfer? price tx-sender seller))
    (map-set listings
      { item-id: item-id }
      (merge listing { owner: tx-sender })
    )
    (map-set item-history
      { item-id: item-id, index: history-index }
      {
        owner: tx-sender,
        timestamp: (var-get next-item-id),
        action: "purchased"
      }
    )
    (map-set history-index-map 
      { item-id: item-id }
      { index: new-history-index }
    )
    (ok true)
  )
)

;; Authenticate an item (admin only)
(define-public (authenticate-item (item-id-input uint))
  (let
    (
      (item-id item-id-input)
      (listing (unwrap! (map-get? listings { item-id: item-id }) (err u2)))
      (history-index-data (default-to { index: u0 } (map-get? history-index-map { item-id: item-id })))
      (history-index (get index history-index-data))
      (new-history-index (+ history-index u1))
    )
    ;; Input validation
    (asserts! (> item-id u0) (err u8))
    (asserts! (is-eq tx-sender (var-get admin)) (err u4))
    
    (map-set listings
      { item-id: item-id }
      (merge listing { authenticated: true })
    )
    (map-set item-history
      { item-id: item-id, index: history-index }
      {
        owner: (get owner listing),
        timestamp: (var-get next-item-id),
        action: "authenticated"
      }
    )
    (map-set history-index-map 
      { item-id: item-id }
      { index: new-history-index }
    )
    (ok true)
  )
)

;; Get item details
(define-read-only (get-item (item-id uint))
  (map-get? listings { item-id: item-id })
)

;; Get item history
(define-read-only (get-item-history (item-id uint) (index uint))
  (map-get? item-history { item-id: item-id, index: index })
)

;; Get history length for an item
(define-read-only (get-history-length (item-id uint))
  (let
    (
      (history-index-data (default-to { index: u0 } (map-get? history-index-map { item-id: item-id })))
    )
    (get index history-index-data)
  )
)