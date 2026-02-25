# Wallet & Bank Data Flow

This document describes how wallet and bank APIs are used in the app: where they are called, how responses are parsed, and where data is displayed. When the backend returns `0` or `[]`, the app already parses and shows that correctly.

---

## Bank detail API – screen flow (where it’s called)

The **user-bank-detail** API is used in two ways: **paginated list** (`getBankListDetail`) and **single-detail** (`getUserBankDetail`). Below is the navigation path and which screen triggers which call.

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│  NAVIGATION PATH                          │  SCREEN                │  API CALL   │
├─────────────────────────────────────────────────────────────────────────────────┤
│  Bottom nav → Profile (Provider)          │  ProviderProfileFragment           │
│    → Tap "Bank Details"                   │    → BankDetails()     │  GET user-  │
│                                           │  (bank_details.dart)   │  bank-detail│
│                                           │  init()                │  ?per_page= │
│                                           │                        │  25&page=1&  │
│                                           │                        │  user_id=59  │
│                                           │                        │  (getBank-  │
│                                           │                        │  ListDetail) │
├─────────────────────────────────────────────────────────────────────────────────┤
│  Profile → Tap "Wallet History"           │  WalletHistoryScreen   │  (wallet-   │
│    → On Wallet screen, tap card/Withdraw  │  (wallet_history_       │  history +  │
│                                           │  screen.dart)          │  user-      │
│                                           │    → WithdrawRequest() │  wallet-    │
│                                           │  (withdraw_request.    │  balance    │
│                                           │  dart)                 │  called     │
│                                           │  init()                │  first)     │
│                                           │                        │  GET user-  │
│                                           │                        │  bank-detail│
│                                           │                        │  ?per_page= │
│                                           │                        │  25&page=1&  │
│                                           │                        │  user_id=59  │
│                                           │                        │  (getBank-  │
│                                           │                        │  ListDetail) │
├─────────────────────────────────────────────────────────────────────────────────┤
│  Dashboard → Today Cash / Cash balance    │  CashManagementScreen  │             │
│    → Cash list → Tap "Pay to Admin" etc. │    → PayToScreen()     │  GET user-  │
│    (or from booking/cash flow)            │  (pay_to_screen.dart)  │  bank-detail│
│                                           │  loadBankDetails()     │  ?user_id=  │
│                                           │                        │  59 (no     │
│                                           │                        │  pagination)│
│                                           │                        │  (getUser-  │
│                                           │                        │  BankDetail)│
└─────────────────────────────────────────────────────────────────────────────────┘
```

**Summary**

| Screen           | File / class           | API method           | URL shape                                      |
|-----------------|------------------------|----------------------|------------------------------------------------|
| Bank Details    | `bank_details.dart` → `BankDetails` | `getBankListDetail`  | `user-bank-detail?per_page=25&page=1&user_id=59` |
| Withdraw (Wallet)| `withdraw_request.dart` → `WithdrawRequest` | `getBankListDetail` | Same as above                                   |
| Pay To (Send cash) | `pay_to_screen.dart` → `PayToScreen` | `getUserBankDetail` (cash_repository) | `user-bank-detail?user_id=59`                    |

So in your logs, **user-bank-detail** appears when you open either **Bank Details** from Profile or **Withdraw** from Wallet History; both use the paginated list. **Pay To** uses the same endpoint without pagination to load the bank list for “send cash”.

**Note (from your log):** The **withdraw-money** POST that returns 500 (`"Trying to access array offset on value of type null"` in `WalletController.php` line 249) is a **backend** bug. The app correctly sends `user_id`, `bank`, `amount`, etc.; the server must fix null handling in that controller.

---

## Wallet APIs – log order (screen flow)

When you open **Wallet History** from Profile, the logs show this order:

| Order | API | Trigger |
|-------|-----|--------|
| 1 | `GET /api/user-wallet-balance` | Profile fragment init (or WalletBalanceComponent) → `setUserWalletAmount()` |
| 2 | `GET /api/wallet-history?per_page=25&page=1&orderby=desc` | **WalletHistoryScreen** `init()` → `getWalletHistory()` → list + `available_balance` (and `setUserWalletAmountFromValue` so balance is not fetched again) |
| 3 | `GET /api/user-bank-detail?per_page=25&page=1&user_id=59` | User taps **Withdraw** on the wallet card → **WithdrawRequest** `init()` → `getBankListDetail()` |

So: **user-wallet-balance** runs once from the profile (or WalletBalanceComponent); **wallet-history** runs when the Wallet History screen opens and returns both the list and `available_balance`. **user-bank-detail** runs when the user opens the Withdraw screen.

*Optimization:* The app avoids a second **user-wallet-balance** call by updating `appStore.userWalletAmount` from the **wallet-history** response `available_balance` (`setUserWalletAmountFromValue`) and not calling `setUserWalletAmount()` in `WalletHistoryScreen.init()`.

---

## 1. Wallet balance (single number)

### API
- **Endpoint:** `GET /api/user-wallet-balance`
- **Backend response (example):** `{"balance": 0}` or `{"balance": 222}`

### Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  WHO CALLS                    │  API / PARSING              │  WHERE SHOWN   │
├─────────────────────────────────────────────────────────────────────────────┤
│  • AppStore.setUserWalletAmount()                                            │
│    - On login: profile fragments call it in init (provider + handyman)       │
│    - On Wallet History screen open: wallet_history_screen init()             │
│    - On logout: rest_apis (reset to 0)                                       │
│                                                                              │
│  • WalletBalanceComponent.loadBalance()                                      │
│    - When the component is shown (its own Future)                            │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  rest_apis.dart :: getUserWalletBalance()                                    │
│    → buildHttpResponse('user-wallet-balance', GET)                           │
│    → handleResponse(response)                                                │
│    → WalletResponse.fromJson(json)  ← lib/models/wallet_response.dart        │
│       • balance: num from json['balance'] (or 0 if null/wrong type)          │
│    → return res.balance.validate()  (or appStore.userWalletAmount on error)   │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                    ┌───────────────┴───────────────┐
                    ▼                               ▼
┌──────────────────────────────┐    ┌──────────────────────────────────────────┐
│  AppStore.userWalletAmount   │    │  WalletBalanceComponent                   │
│  (global state, MobX)        │    │  • futureWalletBalance = getUserWallet...  │
│  Set by setUserWalletAmount()│    │  • SnapHelperWidget → balance.toPriceFormat│
└──────────────────────────────┘    └──────────────────────────────────────────┘
                    │
                    ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│  UI that reads appStore.userWalletAmount                                      │
│  • provider_profile_fragment: "Wallet Balance" row → toPriceFormat()          │
│  • handyman_profile_fragment: "Wallet Balance" row → toPriceFormat()          │
│  • Tapping opens WalletHistoryScreen                                          │
└──────────────────────────────────────────────────────────────────────────────┘
```

### Key files
- **API:** `lib/networks/rest_apis.dart` → `getUserWalletBalance()`
- **Model:** `lib/models/wallet_response.dart` → `WalletResponse.fromJson` (parses `balance`, default 0)
- **State:** `lib/store/AppStore.dart` → `userWalletAmount`, `setUserWalletAmount()`
- **UI:** `lib/provider/fragments/provider_profile_fragment.dart`, `lib/handyman/screen/fragments/handyman_profile_fragment.dart`, `lib/components/wallet_balance_component.dart`

---

## 2. Wallet history (list + available balance)

### API
- **Endpoint:** `GET /api/wallet-history?per_page=25&page=1&orderby=desc`
- **Backend response (example):** `{"pagination":{...},"data":[],"available_balance":0}`

### Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  WHO CALLS                                                                    │
│  • WalletHistoryScreen.init()  (when user opens "Wallet History" from profile)│
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  rest_apis.dart :: getWalletHistory(page, list, lastPageCallback,            │
│                                     availableBalance: (num) => ...)          │
│    → buildHttpResponse('wallet-history?per_page=...&page=...&orderby=desc')   │
│    → WalletHistoryListResponse.fromJson(json)  ← wallet_history_list_response │
│       • data: list of WalletHistory (or [] if null)                           │
│       • availableBalance: num (or 0)                                           │
│    → list.clear() / list.addAll(res.data)                                      │
│    → availableBalance?.call(res.availableBalance ?? 0)                        │
│    → cachedWalletList = list                                                   │
│    → lastPageCallback(res.data.length != perPage)                              │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  WalletHistoryScreen                                                          │
│  • future = getWalletHistory(...)                                             │
│  • availableBalance callback sets local state → passed to WalletCard          │
│  • SnapHelperWidget(future) → onSuccess(snap)                                 │
│    - WalletCard(availableBalance: availableBalance)  ← shows balance          │
│    - AnimatedListView(snap)  ← list of WalletHistory items or empty            │
│  • If snap.isEmpty → noWalletHistoryTitle / noWalletHistorySubTitle           │
│  • Also calls appStore.setUserWalletAmount() to refresh global balance         │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Key files
- **API:** `lib/networks/rest_apis.dart` → `getWalletHistory()`
- **Model:** `lib/models/wallet_history_list_response.dart` → `WalletHistoryListResponse`, `WalletHistory`, `ActivityData`
- **Screen:** `lib/provider/wallet/wallet_history_screen.dart`
- **Card:** `lib/provider/wallet/components/wallet_card.dart` (shows available balance + withdraw)

---

## 3. Bank detail list (for withdraw / bank details)

### API
- **Endpoint:** `GET /api/user-bank-detail?per_page=25&page=1&user_id={userId}`  
  (also used as `GET /api/user-bank-detail?user_id={userId}` for Pay To screen)
- **Backend response (Postman example):**
```json
{
  "pagination": {
    "total_items": 1,
    "per_page": 10,
    "currentPage": 1,
    "totalPages": 1,
    "from": 1,
    "to": 1,
    "next_page": null,
    "previous_page": null
  },
  "data": [
    {
      "id": 1,
      "provider_id": 59,
      "bank_name": "Gggv",
      "branch_name": "Vvv",
      "account_no": "5654577777",
      "ifsc_no": "Vvvvgxxcc",
      "mobile_no": null,
      "aadhar_no": null,
      "pan_no": null,
      "is_default": 0
    }
  ]
}
```

### Frontend expectations (verified)
| API key        | Type   | Handled in app |
|----------------|--------|----------------|
| `pagination`   | object | `BankListResponse` / `UserBankDetails` → Pagination (total_items, from, to, currentPage, totalPages; null from/to → safe int) |
| `data`         | array  | List of bank items; empty `[]` when none |
| `id`           | int    | `BankHistory` / `BankData` (int or string from API → parsed) |
| `provider_id`  | int    | Same |
| `bank_name`    | string | Non-empty from API; **null** → `""` so UI never shows "null" |
| `branch_name`  | string | Same |
| `account_no`   | string | Same |
| `ifsc_no`      | string | Same |
| `mobile_no`    | **null** | → `""` in list model, `""` in BankData |
| `aadhar_no`    | **null** | → `""` |
| `pan_no`       | **null** | → `""` |
| `is_default`   | **0** (int) | → `0`; UI shows "Default" badge only when `== 1` |

### Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  WHO CALLS                                                                    │
│  • BankDetailsScreen (bank_details.dart) → getBankListDetail(userId, list…)   │
│  • WithdrawRequestScreen (withdraw_request.dart) → getBankListDetail(userId…) │
│  • PayToScreen (pay_to_screen.dart) → getUserBankDetail(userId) (no pagination)│
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                    ┌───────────────┴───────────────┐
                    ▼                               ▼
┌──────────────────────────────────────┐  ┌──────────────────────────────────────┐
│  getBankListDetail (paginated list)   │  │  getUserBankDetail (cash_repository)   │
│  → BankListResponse.fromJson         │  │  → UserBankDetails.fromJson             │
│  → BankHistory (id, provider_id,      │  │  → BankData (same keys; null → "")      │
│    bank_name, branch_name,           │  │  Used in: Pay To screen (send cash)     │
│    account_no, ifsc_no, mobile_no,   │  │                                        │
│    aadhar_no, pan_no, is_default)   │  │                                        │
└──────────────────────────────────────┘  └──────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  UI: Bank details screen (list + default badge), Withdraw (dropdown),        │
│  Pay To screen (bank list). Null/0 from API → empty string or 0; no "null" text.│
└─────────────────────────────────────────────────────────────────────────────┘
```

### Key files
- **API:** `lib/networks/rest_apis.dart` → `getBankListDetail()`
- **Models:** `lib/models/bank_list_response.dart` (BankListResponse, BankHistory, Pagination), `lib/models/user_bank_model.dart` (UserBankDetails, BankData)
- **Screens:** `lib/provider/bank_details/bank_details.dart`, `lib/provider/withdraw/withdraw_request/withdraw_request.dart`, `lib/screens/cash_management/view/pay_to_screen.dart`

---

## 4. Summary: why “0 / []” is correct in the app

| API                  | Backend returns     | App parses / stores                    | UI shows                          |
|----------------------|---------------------|----------------------------------------|-----------------------------------|
| user-wallet-balance  | `{"balance":0}`     | `WalletResponse` → balance = 0         | Profile: "0.00" (toPriceFormat)    |
| wallet-history       | `data:[], available_balance:0` | `WalletHistoryListResponse` → data=[], availableBalance=0 | Wallet History: empty list, balance 0.00 |
| user-bank-detail     | `data:[]` or one item with `mobile_no`/`aadhar_no`/`pan_no`: null, `is_default`: 0 | `BankListResponse` / `UserBankDetails`; null → `""`, 0 kept | Bank list, Withdraw, Pay To: no "null" text; default badge only when `is_default == 1` |

So when the backend has no wallet balance, no wallet history, or no bank accounts, it returns 0 or empty arrays and the app shows 0 or empty state. When the backend returns a bank with **null** for `mobile_no`, `aadhar_no`, `pan_no` and **0** for `is_default` (as in your Postman response), the app parses them as empty string and 0 so the UI never shows "null" and the default badge is hidden. All keys are mapped and parsing is robust for int/string/null.
