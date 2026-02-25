# Backend API Updates Required

This document lists the backend APIs that need to be updated so the Provider app shows payment and cash data correctly. All changes are done **on the backend** (API server); the app only calls these endpoints and displays the response.

---

## 1. GET `/api/provider-dashboard`

| Field | Current / Issue | Backend Change |
|-------|-----------------|----------------|
| `remaining_payout` | Missing or 0 | Compute "amount not yet paid out" for this provider and return it (e.g. `"remaining_payout": "222"` or number). |
| `total_cash_in_hand` | Already returned (e.g. "222") | No change if correct. |
| `total_revenue` | Already returned (e.g. "222") | No change if correct. |

---

## 2. GET `/api/payment-history?booking_id={id}`

| Field | Current / Issue | Backend Change |
|-------|-----------------|----------------|
| `data` | Always `[]` | When a booking is completed/paid, **insert rows** into the payment-history table and return them here. Each item should include: `id`, `payment_id`, `booking_id`, `total_amount`, `type`, `status`, `datetime`, `sender_id`, `receiver_id`. |

---

## 3. GET `/api/cash-detail?page=1&from=YYYY-MM-DD&to=YYYY-MM-DD&per_page=25&status=...`

| Field | Current / Issue | Backend Change |
|-------|-----------------|----------------|
| `today_cash` | Always 0 | Set to the **sum of cash** for this provider in the requested **from–to** date range. |
| `cash_detail` | Always `[]` | Return the **list of payment/transaction rows** for this provider, filtered by **from**, **to**, and optional **status**. Same shape as payment-history items (e.g. `id`, `payment_id`, `booking_id`, `total_amount`, `type`, `status`, `datetime`). |
| `total_cash_in_hand` | Already returned (e.g. 222) | No change if correct. |

---

## 4. GET `/api/handyman-dashboard` (if handyman role is used)

Same as provider-dashboard: ensure `total_cash_in_hand`, `total_revenue`, and `remaining_payout` are computed and returned (as number or parseable string).

---

## 5. POST `/api/configurations?is_authenticated=1`

The app only stores and displays what this API returns. To change the many `0` / `false` values:

- Update the **backend** (or admin/DB) that **produces** the configuration response.
- There is no separate "update" API in the app; the app only calls this endpoint and saves the response.

---

## Summary Table

| API | What to Update on Backend |
|-----|---------------------------|
| **provider-dashboard** | Add/fix `remaining_payout`. |
| **payment-history** | Create payment-history rows when booking is completed/paid; return them in `data`. |
| **cash-detail** | Set `today_cash` = sum for date range; set `cash_detail` = list of transaction rows for date range (and status). |
| **handyman-dashboard** | Same as provider-dashboard for totals and `remaining_payout`. |
| **configurations** | Change the backend/source that builds the config JSON; app only reads it. |

---

## Expected Response Examples

### provider-dashboard (relevant fields)

```json
{
  "total_cash_in_hand": "222",
  "total_revenue": "222",
  "remaining_payout": "222"
}
```

### payment-history (for a paid booking)

```json
{
  "pagination": { "total_items": 1, "per_page": 10, "currentPage": 1, "totalPages": 1 },
  "data": [
    {
      "id": 501,
      "payment_id": 30,
      "booking_id": 61,
      "action": "booking_completed",
      "type": "cash",
      "status": "approved_by_handyman",
      "sender_id": 58,
      "receiver_id": 59,
      "datetime": "2026-02-25",
      "total_amount": 222
    }
  ]
}
```

### cash-detail (with list and period sum)

```json
{
  "total_cash_in_hand": 222,
  "today_cash": 222,
  "cash_detail": [
    {
      "id": 700,
      "payment_id": 30,
      "booking_id": 61,
      "action": "booking_completed",
      "type": "cash",
      "status": "approved_by_handyman",
      "sender_id": 58,
      "receiver_id": 59,
      "datetime": "2026-02-25",
      "total_amount": 222
    }
  ]
}
```

---

All updates are done **on the backend** (e.g. fiksopp.inoor.buzz). The Flutter app only consumes these APIs and displays the response.
