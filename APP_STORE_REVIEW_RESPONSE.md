# App Store Review – How to Address Rejection (Mar 2026)

Your app was rejected for two reasons. Below is what was done in code and what you must do in App Store Connect.

---

## 1. Guideline 5.1.1(v) – Account deletion

**What Apple said:** The app must offer a way to delete the account (not only disable it).

**What we did in the app:**

- Account deletion was already implemented. It has been made **easier to find** for reviewers:
  - **Provider:** Open the **Profile** tab (bottom navigation) → scroll to the **"Account"** section (near the top, right below the profile card / subscription) → tap **"Delete account"**.
  - **Handyman:** Same: **Profile** tab → **"Account"** section → **"Delete account"**.
- Tapping **"Delete account"** shows a confirmation dialog. On confirm, the app calls the backend `delete-account` API, clears local data, and returns to the sign-in screen. This is **permanent** account deletion, not deactivation.

**What you should do:**

1. Ensure your **backend** actually deletes (or anonymizes) the user and their data when `delete-account` is called. If it only disables the account, Apple can reject again.
2. When you resubmit, in **App Store Connect → App Review → Reply to App Review**, you can paste something like:

```
Account deletion is available in the app:

1. Log in as a provider or handyman.
2. Open the "Profile" tab in the bottom navigation.
3. In the "Account" section (near the top of the screen), tap "Delete account".
4. Confirm in the dialog. The account and associated data are then permanently deleted and the user is returned to the sign-in screen.

The option is available for all logged-in users (Provider and Handyman) in Profile → Account → Delete account.
```

---

## 2. Guideline 2.3.6 – Accurate metadata (Age rating / In‑App Controls)

**What Apple said:** The age rating indicates "In-App Controls" (e.g. Parental Controls or Age Assurance), but reviewers did not find these features. You must either add them or change the age rating.

**What to do (no code change):**

1. In **App Store Connect**, open your app (FiksOpp Provider).
2. Go to **App Information** (under "General" in the left sidebar).
3. Find **Age Rating** and click **Edit** (or the age rating row).
4. In the questionnaire, find the question about **Parental Controls / In-App Controls**.
5. Set it to **"None"** (or the option that means no parental controls / age assurance).
6. Save and complete the age rating flow.

After that, the age rating no longer claims In-App Controls, so it matches the app.

---

## Summary

| Issue | Action |
|-------|--------|
| **5.1.1(v) Account deletion** | Already in app; made more visible under Profile → **Account** → Delete account. Ensure backend performs real deletion. Use the reply text above when resubmitting. |
| **2.3.6 Age rating** | In App Store Connect: App Information → Age Rating → set Parental Controls / In-App Controls to **None**. |

Then resubmit the app for review.
