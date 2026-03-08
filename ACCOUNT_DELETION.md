# Account deletion (store compliance)

The app supports account creation and **must** offer account deletion. This document describes where it is in the app and what the backend/Firebase must do.

---

## Where users can delete their account

- **Provider:** Profile tab → scroll to **Settings** → **Delete account** (also in **Danger Zone** below).
- **Handyman:** Profile tab → scroll to **Settings** → **Delete account** (also in **Danger Zone** below).

Flow: user taps **Delete account** → confirmation dialog (“Your account will be deleted permanently…”) → on confirm, the app calls the backend, then cleans up Firebase and local data, then navigates to Sign in.

---

## Backend: account deletion API

The app calls the same API as in your API client (e.g. Postman):

- **Method:** `POST`
- **Endpoint path:** `delete-account` (app builds URL as `BASE_URL` + `delete-account`).
- **Query params:** none.
- **Headers:** same as other authenticated requests (e.g. `Authorization: Bearer <token>`); the app sends these via `buildHeaderTokens()`.
- **Body:** empty `{}` (user is identified by the auth token).

### Cross-check: exact URL the app calls

- In code: `lib/utils/configs.dart` has `BASE_URL = "$DOMAIN_URL/api/"` and `DOMAIN_URL = "https://fiksopp.inoor.buzz"`.
- So the app sends **POST** to:
  - **Full URL:** `https://fiksopp.inoor.buzz/api/delete-account`
- In your API client (Postman etc.):
  - Set base URL / `{{live}}` to **`https://fiksopp.inoor.buzz/api`** (include `/api`).
  - Request: **POST** `{{live}}/delete-account` → `https://fiksopp.inoor.buzz/api/delete-account`.
- If your backend is served at a different domain or path, either change `DOMAIN_URL` / `BASE_URL` in `lib/utils/configs.dart` or ensure the server handles `POST /api/delete-account` at the same base URL.

**Backend must:**

1. Validate the authenticated user (from the token).
2. Permanently delete (or anonymize) that user and their related data in your database (bookings, payments, addresses, documents, etc.) according to your privacy policy.
3. Return a JSON response the app can parse as `BaseResponseModel`, e.g.:
   - `{"status": true, "message": "Account deleted successfully"}` on success.
   - `{"status": false, "message": "…"}` on failure.

If this endpoint does not exist or does not actually delete/anonymize the user and related data, account deletion is incomplete and may fail store review.

---

## Firebase (already used by the app)

After a **successful** backend response, the app:

1. **Firestore:** Removes the user document (e.g. `USER_COLLECTION` / `appStore.uid`) so chat/Firestore user data is cleared.
2. **Firebase Auth:** Calls `FirebaseAuth.instance.currentUser!.delete()` so the Firebase Auth account is deleted.

So:

- **Firebase Auth:** Used for auth and for deleting the auth account; no extra backend call for Auth.
- **Firestore:** Used for chat/user doc; the app deletes the doc locally via `userService.removeDocument(appStore.uid)`.

If the user never had a Firebase Auth account (e.g. social login only and no Firestore doc), the app skips Firebase when `appStore.uid` is empty; the backend still must delete the user in your API database.

---

## Summary

| Layer        | Responsibility |
|-------------|-----------------|
| **App (Flutter)** | Shows “Delete account” in Settings (and Danger Zone), confirmation dialog, calls `POST delete-account`, then Firebase cleanup and navigation to Sign in. |
| **Backend (API)** | **Must** implement `POST /api/delete-account` and permanently delete (or anonymize) the user and related data. |
| **Firebase**      | Auth: delete account. Firestore: app removes the user document. No separate “deletion API” needed for Firebase. |

You do **not** need a separate “Firebase deletion API”; you **do** need the **backend `delete-account` API** to delete the user and their data in your own database.
