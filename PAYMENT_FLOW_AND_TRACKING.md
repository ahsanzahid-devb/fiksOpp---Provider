# Payment Flow & Cash Tracking – Provider App

This document describes how payments appear on the **dashboard** and **cash balance** screens, and how to **generate and track** them.

---

## 1. Where payment appears

### 1.1 Dashboard (Provider & Handyman)

| Screen | File | What is shown |
|--------|------|----------------|
| **Provider Home** | `lib/provider/fragments/provider_home_fragment.dart` | **TodayCashComponent** shows `totalCashInHand` from **provider dashboard API**. Tapping it opens **Cash Balance Detail** screen. |
| **Handyman Home** | `lib/handyman/screen/fragments/handyman_fragment.dart` | Same **TodayCashComponent** with `totalCashInHand` from **handyman dashboard API**. Same tap → Cash Balance Detail. |

- **APIs:**  
  - Provider: `provider-dashboard` → `DashboardResponse.totalCashInHand`, `todayCashAmount`  
  - Handyman: `handyman-dashboard` → `HandymanDashBoardResponse.totalCashInHand`, `todayCashAmount`  
- **Model:** `lib/models/dashboard_response.dart` (provider), `lib/models/handyman_dashboard_response.dart` (handyman).

So: **dashboard shows one number – total cash in hand** – and the only payment-related action from dashboard is **tap “Total Cash” → open Cash Balance screen**.

---

## 2. Cash Balance (Cash in Hand) screen

**Screen:** `lib/screens/cash_management/view/cash_balance_detail_screen.dart`  
**Opened from:** Dashboard “Total Cash” card (`TodayCashComponent`).

### 2.1 What it shows

- **Total cash in hand** (same concept as dashboard, but can be re-fetched here).
- **Transactions for selected date range** (today, yesterday, this week, etc.).
- **Status filter tabs:** All, or by status (e.g. Sent to admin, Approved by admin; “Pending by provider” / “Approved by provider” are commented out in your app).
- **List of payment items** (`CashListWidget`): each item is one cash record (amount, booking ID, date, status, type cash/bank, ref number if bank). Tapping a row opens **Booking Detail** for that booking.

### 2.2 Data source

- **API:** `cash-detail` (GET).  
- **Repository:** `lib/screens/cash_management/cash_repository.dart` → `getCashDetails()`.  
- **Query params:** `page`, `from`, `to`, `status`, `per_page`.  
- **Response model:** `lib/screens/cash_management/model/cash_detail_model.dart` → `CashHistoryModel`:  
  - `total_cash_in_hand`  
  - `today_cash`  
  - `cash_detail`: list of `PaymentHistoryData`.

So: **payment tracking on “Cash in Hand / Cash Balance” is the list from `cash-detail`**, filtered by date and status.

---

## 3. Payment flow (status lifecycle)

Payments are **tracked by status**. Status and actions are in `lib/screens/cash_management/cash_constant.dart` and used in `cash_list_widget.dart` and `pay_to_screen.dart`.

### 3.1 Status constants (cash_constant.dart)

| Status | Meaning |
|--------|--------|
| `approved_by_handyman` | Handyman approved the request (cash ready to send) |
| `send_to_provider` | Request sent to the provider (handyman sent to provider) |
| `pending_by_provider` | Request pending with the provider (commented out in your UI) |
| `approved_by_provider` | Provider approved the request (commented out in your UI) |
| `send_to_admin` | Request sent to the admin |
| `pending_by_admin` | Request pending with the admin |
| `approved_by_admin` | Admin approved the request |

### 3.2 Actions (what the app sends to backend)

| Action | When used |
|--------|-----------|
| `handyman_approved_cash` | Handyman approves (creates/updates cash record on backend) |
| `handyman_send_provider` | Handyman sends cash to provider |
| `provider_approved_cash` | Provider confirms payment (pending → approved by provider) |
| `provider_send_admin` | Provider sends cash to admin |
| `admin_approved_cash` | Admin approves (backend) |

### 3.3 Who sees which buttons (CashListWidget)

- **Handyman:**  
  - If status = `approved_by_handyman` → button **“Send cash to provider”** → opens **PayToScreen** (cash or bank), then calls **transfer-payment** with `action: HANDYMAN_SEND_PROVIDER`, `status: SEND_TO_PROVIDER`.
- **Provider:**  
  - If status = `approved_by_provider` → button **“Send cash to admin”** → **PayToScreen** → **transfer-payment** with `action: PROVIDER_SEND_ADMIN`, `status: PENDING_BY_ADMIN`.  
  - If status = `pending_by_provider` → button **“Confirm payment”** → **transfer-payment** with `action: PROVIDER_APPROVED_CASH`, `status: APPROVED_BY_PROVIDER` (no PayToScreen).

So: **tracking = list of payment records from `cash-detail`**, each with a **status**. Moving money (handyman→provider, provider→admin) is done by calling **transfer-payment** with the right **action** and **status**.

---

## 4. How payments are “generated” (created / updated)

- **Creation of the first payment record** (e.g. when a booking is completed with cash, or when handyman “approves” cash) is **not done in this app**: it is done on the **backend** (e.g. when booking status becomes completed or when handyman confirms cash).
- **This app only:**
  1. **Reads** payment list from `cash-detail` and per-booking from `payment-history`.
  2. **Updates** payment (and status) by calling **transfer-payment** with:
     - `payment_id`, `booking_id`, `action`, `type` (cash/bank), `sender_id`, `receiver_id`, `txn_id` (ref for bank), `datetime`, `total_amount`, `status`, `p_id`, `parent_id`.

So to **generate** a new payment in the system you must do it **server-side** (e.g. when marking a booking as completed with cash, or when handyman confirms cash). To **track** it: use **dashboard** for the single “total cash in hand” number and **Cash Balance** screen for the list and status flow.

---

## 5. APIs summary (for tracking and flow)

| API | Method | Purpose |
|-----|--------|--------|
| `provider-dashboard` | GET | Provider dashboard: `total_cash_in_hand`, `today_cash`. |
| `handyman-dashboard` | GET | Handyman dashboard: same. |
| `cash-detail` | GET | List of cash payments (cash in hand list) with filters: `page`, `from`, `to`, `status`, `per_page`. Returns `total_cash_in_hand`, `today_cash`, `cash_detail[]`. |
| `payment-history` | GET | Payment history for **one booking**: `booking_id`. Used in **Booking Detail** screen. |
| `transfer-payment` | POST | Update payment (send to provider/admin, confirm). Body: `payment_id`, `booking_id`, `action`, `type`, `sender_id`, `receiver_id`, `txn_id`, `datetime`, `total_amount`, `status`, `p_id`, `parent_id`. |
| `user-bank-detail` | GET | Bank details for PayToScreen (provider): `user_id`. |

---

## 6. Flow diagrams

### 6.1 Dashboard → Cash Balance

```
Dashboard (Provider or Handyman)
  → TodayCashComponent(totalCashInHand from dashboard API)
  → User taps "Total Cash"
  → CashBalanceDetailScreen(totalCashInHand)
  → getCashDetails() → cash-detail API (with date + status filters)
  → Shows total cash, date range, status tabs, list of PaymentHistoryData
  → Each item: CashListWidget → tap opens BookingDetailScreen(bookingId)
```

### 6.2 Handyman: Send cash to provider

```
Cash Balance list item with status = approved_by_handyman
  → "Send cash to provider" → PayToScreen(paymentData)
  → User selects Cash/Bank, if Bank: ref number + bank details
  → Submit → transferAmountAPI(..., status: SEND_TO_PROVIDER, action: HANDYMAN_SEND_PROVIDER)
  → transfer-payment POST
  → Backend updates record to send_to_provider
```

### 6.3 Provider: Send cash to admin

```
Cash Balance list item with status = approved_by_provider
  → "Send cash to admin" → PayToScreen(paymentData)
  → User selects Cash/Bank, if Bank: ref number + bank details
  → Submit → transferAmountAPI(..., status: PENDING_BY_ADMIN, action: PROVIDER_SEND_ADMIN)
  → transfer-payment POST
  → Backend updates record to pending_by_admin / send_to_admin
```

### 6.4 Tracking a single booking’s payments

```
BookingDetailScreen(bookingId)
  → CashPaymentHistoryScreen(bookingId)
  → getPaymentHistory(bookingId) → payment-history?booking_id=...
  → List of PaymentHistoryData for that booking
```

---

## 7. How to “track” payments (practical)

1. **Total amount:**  
   - **Dashboard:** “Total Cash” = `totalCashInHand` from `provider-dashboard` or `handyman-dashboard`.  
   - **Cash Balance screen:** Same idea from `cash-detail` response (`total_cash_in_hand`, `today_cash`).

2. **List of payments (who paid whom, when, status):**  
   - Open **Cash Balance** from dashboard.  
   - Data = `cash-detail` with `from`, `to`, `status`, `page`.  
   - Each row = one payment; status and actions (send to provider/admin, confirm) are in **CashListWidget**.

3. **Payments for one booking:**  
   - Open that **booking** → **Booking Detail** → **Cash Payment History** section.  
   - Data = `payment-history?booking_id=<id>`.

4. **Generating new payments:**  
   - Done on the **backend** when a booking is completed with cash or when handyman approves cash.  
   - This app only **changes status** of existing payments via **transfer-payment** (send to provider, send to admin, confirm).

If you want to **track more** (e.g. export, or extra filters), you would:
- Add more query params or endpoints on the backend for `cash-detail` / `payment-history`, and/or  
- Add UI in **Cash Balance** or **Booking Detail** that calls those APIs and shows or exports the data.

---

## 8. Troubleshooting: “I have bookings and payments but dashboard/cash balance show nothing”

### What the app does

- **Dashboard** shows exactly what the **provider-dashboard** API returns: `total_cash_in_hand`, `total_revenue`, `today_cash`.
- **Cash Balance screen** shows exactly what the **cash-detail** API returns: `total_cash_in_hand`, `today_cash`, and the list in `cash_detail`.
- **Booking detail → Payment history** shows exactly what **payment-history?booking_id=…** returns in `data`.

If those APIs return `0` or empty arrays, the app will show zero and “No payments found” — the app does not compute totals from bookings locally.

### What to check (backend)

1. **provider-dashboard**
   - For the logged-in provider, the backend must compute:
     - `total_revenue`: sum of revenue from completed bookings (after commission, etc., per your business rules).
     - `total_cash_in_hand`: sum of cash payments that are “in hand” for this provider (e.g. status = approved_by_handyman, send_to_provider, approved_by_provider, etc., depending on your rules).
   - If these are always 0, completed bookings are not being included in the backend calculation.

2. **payment-history?booking_id=X**
   - Must return a list of payment records for that booking (each with fields like `id`, `payment_id`, `booking_id`, `action`, `type`, `status`, `total_amount`, `datetime`, etc., as in `PaymentHistoryData`).
   - If the response is `"data": []` for a booking that has a payment (e.g. `payment_id`, `payment_status`, `payment_total_amount` in booking-detail), then the backend is not creating or returning payment history rows for that booking.

3. **cash-detail**
   - Must return:
     - `total_cash_in_hand`: same concept as dashboard.
     - `today_cash`: sum of cash in the selected date range (from/to) that counts as “today” cash.
     - `cash_detail`: array of payment records (same shape as `PaymentHistoryData`) for the provider, filtered by the request’s `from`, `to`, and `status`.
   - If `cash_detail` is always `[]`, the backend is not creating cash records when bookings are completed with cash (or not returning them for this provider/date/status).

### Expected flow on the backend

- When a **booking is completed** (and has a payment, cash or online):
  1. Create or update **payment** and **payment history** records so that:
     - **payment-history?booking_id=X** returns at least one record for that booking.
     - **provider-dashboard** includes this payment in `total_revenue` (and, for cash, in `total_cash_in_hand` if it is “in hand”).
  2. For **cash** payments, create/update the records that should appear in **cash-detail** (with the correct `status`, e.g. `approved_by_handyman` or `send_to_provider`, and date so that filtering by `from`/`to` returns them).

Until the backend does the above, the dashboard and cash balance screens will continue to show zero and no payments.
