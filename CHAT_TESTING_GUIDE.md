# Chat Feature Testing Guide - Provider App

## Overview
This guide explains how to test the chat feature from the Provider app to send messages to users/customers.

## Prerequisites

1. **Provider Account**: Logged in as a provider
2. **User/Customer Account**: Must exist in the system (for testing, you need a customer user)
3. **Firebase Authentication**: Chat uses Firebase, so ensure Firebase is properly configured
4. **Chat Enabled**: Ensure `appConfigurationStore.isEnableChat` is enabled

## Testing Methods

### Method 1: Chat from Booking Detail Screen ✅ (Recommended)

**Steps:**
1. Navigate to **Bookings** tab in the provider dashboard
2. Open any booking detail screen
3. Scroll down to find the **"Chat"** button (blue button with chat icon)
4. Click the **Chat** button
5. Wait for "Loading chat details..." message
6. Chat screen will open with the customer
7. Type a message and send

**Location in Code:**
- File: `lib/components/basic_info_component.dart`
- Component: `BasicInfoComponent`
- Button: Chat button in booking detail

**What Happens:**
- Fetches customer user by email: `getUserNull(email: userData.email)`
- Opens `UserChatScreen` with customer as receiver
- Provider can send messages to customer

**Testing Checklist:**
- [ ] Chat button is visible on booking detail screen
- [ ] Clicking chat button shows loading message
- [ ] Chat screen opens successfully
- [ ] Can type and send messages
- [ ] Messages appear on right side (provider messages)
- [ ] Customer messages appear on left side
- [ ] Read receipts (✓✓) show for sent messages
- [ ] No self-chat error (if customer email matches provider email)

---

### Method 2: Chat from Handyman List ✅

**Steps:**
1. Navigate to **Handyman** section in provider app
2. Find a handyman in the list
3. Look for the **message icon** (text message icon) next to contact number
4. Click the message icon
5. Wait for "Loading chat details..." message
6. Chat screen will open with the handyman
7. Type a message and send

**Location in Code:**
- File: `lib/provider/components/handyman_widget.dart`
- Component: `HandymanWidget`
- Icon: Text message icon (`textMsg`)

**What Happens:**
- Fetches handyman user by email: `getUserNull(email: widget.data!.email)`
- Opens `UserChatScreen` with handyman as receiver
- Provider can send messages to handyman

**Testing Checklist:**
- [ ] Message icon is visible next to handyman contact
- [ ] Clicking icon shows loading message
- [ ] Chat screen opens successfully
- [ ] Can send messages to handyman
- [ ] Messages display correctly

---

### Method 3: Chat from Chat List Screen ✅

**Steps:**
1. Navigate to **Chat** tab in bottom navigation (if enabled)
2. You'll see a list of all your chat conversations
3. Click on any conversation/user from the list
4. Chat screen opens with that user
5. Type and send messages

**Location in Code:**
- File: `lib/screens/chat/user_chat_list_screen.dart`
- Component: `ChatListScreen`
- Navigation: Bottom tab in provider dashboard

**What Happens:**
- Shows list of all chat contacts
- Clicking a contact opens `UserChatScreen`
- Provider can continue existing conversations or start new ones

**Testing Checklist:**
- [ ] Chat tab is visible in bottom navigation
- [ ] Chat list shows previous conversations
- [ ] Clicking a contact opens chat screen
- [ ] Can send new messages
- [ ] Previous messages are displayed

---

## Chat Screen Features to Test

### 1. **Message Sending**
- ✅ Type message in text field
- ✅ Press send button or Enter key
- ✅ Message appears on right side (your messages)
- ✅ Message has timestamp and read receipt

### 2. **Message Alignment**
- ✅ Your messages: **Right side** (blue/purple background)
- ✅ Receiver messages: **Left side** (light gray/white background)
- ✅ Messages don't exceed 75% screen width

### 3. **File Attachments**
- ✅ Click attachment icon (paperclip)
- ✅ Can send images
- ✅ Can send documents/PDFs
- ✅ Files display correctly

### 4. **Read Receipts**
- ✅ Single check (✓): Message sent
- ✅ Double check (✓✓): Message read by receiver
- ✅ Only shown on your messages (right side)

### 5. **Online Status**
- ✅ Shows if receiver is online
- ✅ Updates in real-time

### 6. **Message Actions**
- ✅ Long press on your messages: Copy/Delete options
- ✅ Long press on receiver messages: Copy option only

---

## Testing Scenarios

### Scenario 1: New Chat (First Time)
1. Open booking detail
2. Click Chat button
3. Chat screen opens (empty)
4. Send first message: "Hello, this is a test message"
5. ✅ Message appears on right side
6. ✅ Message is saved to Firebase

### Scenario 2: Existing Chat
1. Open Chat tab
2. Click on existing conversation
3. Previous messages load
4. Send new message
5. ✅ New message appears below previous messages
6. ✅ Scroll works correctly

### Scenario 3: Self-Chat Prevention
1. Try to chat with yourself (if your email appears in list)
2. ✅ Should show: "Cannot chat with yourself"
3. ✅ Chat screen should not open

### Scenario 4: User Not Found
1. Try to chat with user that doesn't exist
2. ✅ Should show: "[Name] is not available for chat"
3. ✅ Chat screen should not open

### Scenario 5: Offline User
1. Chat with user who is offline
2. ✅ Send message
3. ✅ Notification should be sent (if notification service works)
4. ✅ Read receipt shows single check until user reads

---

## Debug Logs to Check

When testing, check the console logs for:

### Chat Initialization:
```
====================== Chat Initialization Debug ======================
Current User ID: [provider_id]
Current User Email: [provider_email]
Receiver User ID: [customer_id]
Receiver User Email: [customer_email]
Is Self-Chat: false
```

### Message Sending:
```
====================== Add Message Debug ======================
Sender ID: [provider_id]
Receiver ID: [customer_id]
Is Self-Chat: false
Different users: Adding message to both sender and receiver collections
Message added to sender collection with ID: [message_id]
Message added to receiver collection with ID: [message_id]
```

### Self-Chat Prevention:
```
⚠️ Self-chat prevented: User trying to chat with themselves
Current User ID: [id]
Receiver User ID: [id]
Receiver Email: [email]
```

---

## Common Issues & Solutions

### Issue 1: Chat Button Not Visible
**Solution:**
- Check if booking has customer data
- Check if `showChat` is true in `BasicInfoComponent`
- Check if booking status allows chatting

### Issue 2: "User is not available for chat"
**Solution:**
- User might not exist in Firebase
- User email might be incorrect
- Check Firebase user collection

### Issue 3: Messages Not Sending
**Solution:**
- Check Firebase connection
- Check internet connection
- Check Firebase permissions
- Check console for errors

### Issue 4: Messages Not Appearing
**Solution:**
- Check Firebase Firestore rules
- Check if messages are being saved
- Check console logs for errors
- Verify receiver user ID is correct

### Issue 5: Self-Chat Error
**Solution:**
- Already fixed - should show "Cannot chat with yourself"
- Check logs to see why receiver ID matches provider ID

---

## Firebase Requirements

### Collections Needed:
1. **users** - User data collection
2. **messages** - Chat messages collection
3. **contacts** - User contacts collection

### Firestore Rules:
```javascript
// Messages collection
match /messages/{userId}/messages/{messageId} {
  allow read, write: if request.auth != null;
}

// Users collection
match /users/{userId} {
  allow read: if request.auth != null;
  allow write: if request.auth.uid == userId;
}
```

---

## Quick Test Checklist

- [ ] Provider is logged in
- [ ] Navigate to Bookings tab
- [ ] Open any booking detail
- [ ] Click Chat button
- [ ] Chat screen opens
- [ ] Type message: "Test message from provider"
- [ ] Send message
- [ ] Message appears on right side
- [ ] Check console logs for success
- [ ] Verify message in Firebase console

---

## Expected Behavior

### ✅ Success Flow:
1. Click Chat button → Loading message appears
2. Chat screen opens → Shows empty chat or previous messages
3. Type message → Text appears in input field
4. Send message → Message appears on right side
5. Message saved → Shows in Firebase
6. Receiver gets notification → (if online/offline handling works)

### ❌ Error Flow:
1. Click Chat button → Loading message appears
2. User not found → "User is not available for chat"
3. Self-chat attempt → "Cannot chat with yourself"
4. Network error → Error message shown

---

## Testing with Real User Account

To test properly, you need:

1. **Provider Account** (logged in on provider app)
   - Email: provider@example.com
   - User Type: Provider

2. **Customer Account** (for receiving messages)
   - Email: customer@example.com
   - User Type: Customer
   - Must exist in Firebase users collection

3. **Test Steps:**
   - Provider sends message from booking detail
   - Customer receives message (check customer app or Firebase)
   - Customer replies
   - Provider sees reply in chat screen

---

**Last Updated:** Chat testing guide for provider app
**Files Involved:**
- `lib/components/basic_info_component.dart` - Booking chat button
- `lib/provider/components/handyman_widget.dart` - Handyman chat icon
- `lib/screens/chat/user_chat_screen.dart` - Chat screen
- `lib/screens/chat/user_chat_list_screen.dart` - Chat list
- `lib/provider/provider_dashboard_screen.dart` - Dashboard with chat tab

