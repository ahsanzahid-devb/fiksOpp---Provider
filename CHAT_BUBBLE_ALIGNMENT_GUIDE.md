# Chat Bubble Alignment Guide

## Overview
This document explains how chat message bubbles are aligned in the chat interface.

## Alignment Structure

### Current User Messages (Right Side)
```
┌─────────────────────────────────────────────┐
│                                             │
│                    ┌─────────────┐          │
│                    │ Your Message│          │
│                    │  10:30 AM ✓✓│          │
│                    └─────────────┘          │
│                                             │
└─────────────────────────────────────────────┘
```

**Properties:**
- **Alignment**: `Alignment.centerRight` (right side of screen)
- **Background Color**: `primaryColor` (blue/purple)
- **Border Radius**: Rounded on left side, sharp on right
- **Max Width**: 75% of screen width
- **Margin**: 8px from right edge, 50px from left edge

### Receiver Messages (Left Side)
```
┌─────────────────────────────────────────────┐
│                                             │
│  ┌─────────────┐                           │
│  │Their Message │                           │
│  │  10:31 AM    │                           │
│  └─────────────┘                           │
│                                             │
└─────────────────────────────────────────────┘
```

**Properties:**
- **Alignment**: `Alignment.centerLeft` (left side of screen)
- **Background Color**: `context.cardColor` (light gray/white)
- **Border Radius**: Rounded on right side, sharp on left
- **Max Width**: 75% of screen width
- **Margin**: 8px from left edge, 50px from right edge

## Code Implementation

### Main Container Alignment
```dart
Align(
  alignment: widget.chatItemData.isMe.validate() 
      ? Alignment.centerRight   // Current user → Right
      : Alignment.centerLeft,    // Receiver → Left
  child: Container(
    constraints: BoxConstraints(
      maxWidth: context.width() * 0.75,  // Max 75% width
    ),
    margin: EdgeInsets.only(
      top: 2.0,
      bottom: 2.0,
      left: widget.chatItemData.isMe.validate() 
          ? (isRTL ? 0 : 50)  // Right-aligned: 50px from left
          : 8,                 // Left-aligned: 8px from left
      right: widget.chatItemData.isMe.validate() 
          ? 8                  // Right-aligned: 8px from right
          : (isRTL ? 0 : 50),  // Left-aligned: 50px from right
    ),
    // ... decoration and content
  ),
)
```

### Message Content Alignment
```dart
Column(
  crossAxisAlignment: widget.chatItemData.isMe! 
      ? CrossAxisAlignment.end   // Right-align text
      : CrossAxisAlignment.start, // Left-align text
  children: [
    Text(widget.chatItemData.message!),
    Row(
      mainAxisAlignment: widget.chatItemData.isMe! 
          ? MainAxisAlignment.end   // Right-align time/read receipt
          : MainAxisAlignment.start, // Left-align time
      children: [
        Text(time),
        Icon(readReceipt), // Only shown for current user
      ],
    ),
  ],
)
```

## Visual Breakdown

### Right-Aligned Bubble (Current User)
```
Screen Width (100%)
│
│                    ┌─────────────────────┐
│                    │                     │
│                    │   Message Text      │
│                    │   10:30 AM ✓✓       │
│                    │                     │
│                    └─────────────────────┘
│                    ↑                     ↑
│                    50px margin           8px margin
│                    from left            from right
│
└─────────────────────────────────────────────┘
```

### Left-Aligned Bubble (Receiver)
```
Screen Width (100%)
│
│  ┌─────────────────────┐
│  │                     │
│  │   Message Text      │
│  │   10:31 AM          │
│  │                     │
│  └─────────────────────┘
│  ↑                     ↑
│  8px margin            50px margin
│  from left             from right
│
└─────────────────────────────────────────────┘
```

## Border Radius Details

### Current User (Right Side)
- **Top Left**: 12px (rounded)
- **Top Right**: 12px (rounded)
- **Bottom Left**: 12px (rounded)
- **Bottom Right**: 0px (sharp point on right)

### Receiver (Left Side)
- **Top Left**: 12px (rounded)
- **Top Right**: 12px (rounded)
- **Bottom Left**: 0px (sharp point on left)
- **Bottom Right**: 12px (rounded)

## RTL (Right-to-Left) Support

The alignment automatically adjusts for RTL languages:
- **LTR**: Current user on right, receiver on left
- **RTL**: Margins are reversed to maintain proper alignment

## Features

✅ **Right-aligned bubbles** for current user messages
✅ **Left-aligned bubbles** for receiver messages
✅ **Max width constraint** (75% of screen) for readability
✅ **Proper margins** to prevent edge-to-edge messages
✅ **RTL language support** with automatic margin reversal
✅ **Read receipts** (✓✓) only shown for current user messages
✅ **Time stamps** aligned within each bubble

## Testing Checklist

- [ ] Current user messages appear on right side
- [ ] Receiver messages appear on left side
- [ ] Messages don't exceed 75% screen width
- [ ] Margins are correct (8px from edge, 50px from opposite side)
- [ ] Border radius is correct (sharp edge points toward screen edge)
- [ ] Read receipts only show for current user
- [ ] Time stamps are aligned correctly within bubbles
- [ ] RTL languages display correctly

---

**Last Updated**: Chat bubble alignment implementation
**File**: `lib/screens/chat/components/chat_item_widget.dart`

