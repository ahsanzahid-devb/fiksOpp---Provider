# Reply to App Review (App Store Connect)

Use the text below when you **Reply to this message** in App Store Connect for submission `4f66aeec-cd6e-4658-823c-c0b6962e8e45`.

---

## 1. Guideline 5.1.1(v) – Account deletion

**Where to find account deletion**

The app supports **permanent account deletion** (not deactivation). Users can delete their account from the **Profile** screen:

**Provider account:**
1. Log in as a **Provider** (or create an account).
2. Open the **Profile** tab (bottom navigation, rightmost or profile icon).
3. Scroll down to the **Settings** section.
4. Tap **"Delete account"** (trash icon). It appears in the same list as "Change password," and again in the red **"DANGER ZONE"** section further down.
5. In the confirmation dialog, tap **"Delete"** to permanently delete the account. Data cannot be restored.

**Handyman account:**
1. Log in as a **Handyman** (or create an account).
2. Open the **Profile** tab (bottom navigation).
3. Scroll down to the **Settings** section.
4. Tap **"Delete account"** (trash icon), in the list and again in the **"DANGER ZONE"** section.
5. Confirm with **"Delete"** to permanently delete the account.

The flow includes a confirmation step to prevent accidental deletion. Deletion is permanent: the app calls our backend to remove the user and related data, then clears Firebase Auth and Firestore, and returns the user to the Sign In screen.

---

## 2. Guideline 2.3.6 – Age rating / In-App Controls

We do **not** include Parental Controls or Age Assurance in the app.

**What to do in App Store Connect (Age Rating – Step 1: Features):**

1. Go to **App Information** → **Age Ratings** → **Edit** (or **View Details** then **Edit**).
2. On **Step 1: Features** (In-App Controls and Capabilities):
   - **In-App Controls**
     - **Parental Controls:** select **No**
     - **Age Assurance:** select **No**
   - **Capabilities** (answer according to your app):
     - Unrestricted Web Access: **No** (unless the app has a full browser)
     - User-Generated Content: **Yes** if providers/handymen post content; otherwise **No**
     - Messaging and Chat: **Yes** (app has in-app chat)
     - Advertising: **Yes** only if you show third-party ads; otherwise **No**
3. Click **Next**. On **Step 2: Mature Themes**, set all to **None** (unless your app actually contains this content):
   - **Profanity or Crude Humor:** None  
   - **Horror/Fear Themes:** None  
   - **Alcohol, Tobacco, or Drug Use or References:** None  

4. Click **Next** and complete **Steps 3–7** (answer according to your app; choose the lowest/most conservative option when unsure). Save when finished.

After saving, the age rating will no longer indicate In-App Controls (Parental Controls / Age Assurance), which resolves the Guideline 2.3.6 issue.

---

You can paste the sections above (or a shortened version) into your reply to App Review in App Store Connect.
