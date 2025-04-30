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
(define-data-var history-index-map (map uint uint) {})

;; Create a new listing
(define-public (list-item (name (string-ascii 50)) (description (string-ascii 500)) (year uint) (price uint))
  (let
    (
      (item-id (var-get next-item-id))
      (history-index u0)
    )
    (asserts! (> price u0) (err u1))
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
        timestamp: block-height,
        action: "listed"
      }
    )
    (map-set history-index-map item-id u1)
    (var-set next-item-id (+ item-id u1))
    (ok item-id)
  )
)

;; Purchase an item
(define-public (purchase-item (item-id uint))
  (let
    (
      (listing (unwrap! (map-get? listings { item-id: item-id }) (err u2)))
      (price (get price listing))
      (seller (get owner listing))
      (history-index (default-to u0 (map-get? history-index-map item-id)))
      (new-history-index (+ history-index u1))
    )
    (asserts! (not (is-eq tx-sender seller)) (err u3))
    (try! (stx-transfer? price tx-sender seller))
    (map-set listings
      { item-id: item-id }
      (merge listing { owner: tx-sender })
    )
    (map-set item-history
      { item-id: item-id, index: new-history-index }
      {
        owner: tx-sender,
        timestamp: block-height,
        action: "purchased"
      }
    )
    (map-set history-index-map item-id new-history-index)
    (ok true)
  )
)

;; Authenticate an item (admin only)
(define-public (authenticate-item (item-id uint))
  (let
    (
      (listing (unwrap! (map-get? listings { item-id: item-id }) (err u2)))
      (history-index (default-to u0 (map-get? history-index-map item-id)))
      (new-history-index (+ history-index u1))
    )
    (asserts! (is-eq tx-sender (var-get admin)) (err u4))
    (map-set listings
      { item-id: item-id }
      (merge listing { authenticated: true })
    )
    (map-set item-history
      { item-id: item-id, index: new-history-index }
      {
        owner: (get owner listing),
        timestamp: block-height,
        action: "authenticated"
      }
    )
    (map-set history-index-map item-id new-history-index)
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
  (default-to u0 (map-get? history-index-map item-id))
)