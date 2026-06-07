# Bloom Database Schema

## Version

1.0

---

# Database

Database Provider:

```text
Cloud Firestore
```

---

# Collection Overview

## Top-Level Collections

```text
users
likes
matches
notifications
reports
verification_requests
subscriptions
```

## User Subcollections

```text
users/{userId}/private/location
users/{userId}/blocks
users/{userId}/passes
```

## Realtime Database

```text
status/{userId}
typing/{matchId}/{userId}
```

---

# users

Document Path

```text
users/{userId}
```

---

## Purpose

Stores user profiles, preferences, visibility settings, and application state.

---

## Schema

```typescript
{
  id: string

  email: string

  nickname: string

  birthDate: Timestamp

  age: number

  identity: string

  relationshipGoal: string

  bio: string

  interests: string[]

  occupation?: string

  education?: string

  height?: number

  socialLinks?: {
    instagram?: string
    twitter?: string
    tiktok?: string
  }

  city: string

  geoHash: string

  profileImages: string[]

  profileVisibility:
    | "public"
    | "hidden"
    | "selective"

  accountStatus:
    | "active"
    | "suspended"
    | "deleted"

  verificationLevel:
    | "none"
    | "photo"
    | "government_id"

  premium: boolean

  premiumBadgeVisible: boolean

  fcmToken: string

  isOnline: boolean

  lastSeen: Timestamp

  onlineStatusVisible: boolean

  lastSeenVisible: boolean

  notificationSettings: {
    match: boolean
    message: boolean
    like: boolean
    verification: boolean
  }

  compatibilityPreferences: {
    minAge: number
    maxAge: number
    maxDistanceKm: number
    identities: string[]
    relationshipGoals: string[]
  }

  createdAt: Timestamp

  updatedAt: Timestamp
}
```

---

## Example

```typescript
{
  id: "user123",

  nickname: "Alex",

  age: 29,

  identity: "Gay",

  relationshipGoal: "Serious Relationship",

  interests: [
    "Travel",
    "Music",
    "Coffee"
  ],

  verificationLevel: "photo",

  premium: true,

  isOnline: true
}
```

---

# users/{userId}/private/location

Subcollection Path

```text
users/{userId}/private/location
```

---

## Purpose

Stores exact user coordinates. Readable only by the document owner and Cloud Functions.

---

## Schema

```typescript
{
  location: GeoPoint

  updatedAt: Timestamp
}
```

---

## Security Note

Firestore Security Rules must restrict read access to this subcollection to the document owner only. Exact coordinates are never returned in user-facing profile queries.

---

# users/{userId}/passes

Subcollection Path

```text
users/{userId}/passes/{passedUserId}
```

---

## Purpose

Tracks profiles the user has passed on. Document ID is the passed user's ID, enabling O(1) existence checks to prevent re-showing passed profiles.

---

## Schema

```typescript
{
  passedUserId: string

  createdAt: Timestamp
}
```

---

# users/{userId}/blocks

Subcollection Path

```text
users/{userId}/blocks/{blockedUserId}
```

---

## Purpose

Stores blocked user relationships. Document ID is the blocked user's ID, enabling O(1) existence checks.

---

## Schema

```typescript
{
  blockedUserId: string

  createdAt: Timestamp
}
```

---

## Effect

Blocked users:

* Cannot discover each other
* Cannot match
* Cannot send messages
* Cannot view profiles

---

# likes

Document Path

```text
likes/{likeId}
```

---

## Purpose

Stores like and super-like actions.

---

## Schema

```typescript
{
  id: string

  fromUserId: string

  toUserId: string

  type:
    | "like"
    | "super_like"

  createdAt: Timestamp
}
```

---

## Example

```typescript
{
  fromUserId: "userA",

  toUserId: "userB",

  type: "super_like"
}
```

---

# matches

Document Path

```text
matches/{matchId}
```

---

## Purpose

Represents mutual matches between users.

A match also serves as a conversation room.

---

## Schema

```typescript
{
  id: string

  users: string[]

  compatibilityScore: number

  createdAt: Timestamp

  lastMessageAt: Timestamp

  lastMessagePreview: string

  active: boolean
}
```

---

## Example

```typescript
{
  users: [
    "userA",
    "userB"
  ],

  compatibilityScore: 84,

  active: true
}
```

---

# messages

Subcollection

```text
matches/{matchId}/messages/{messageId}
```

---

## Purpose

Stores all conversation messages.

---

## Schema

```typescript
{
  id: string

  senderId: string

  type:
    | "text"
    | "image"

  content: string

  imageUrl?: string

  readBy: string[]

  deleted: boolean

  createdAt: Timestamp
}
```

---

## Notes

Read receipts are only shown to Premium users.

Message data is still stored for all users.

---

# notifications

Document Path

```text
notifications/{notificationId}
```

---

## Purpose

Stores user notification feed.

---

## Schema

```typescript
{
  id: string

  userId: string

  type:
    | "match"
    | "message"
    | "like"
    | "verification"

  title: string

  body: string

  read: boolean

  referenceId?: string

  referenceType?:
    | "match"
    | "message"
    | "like"
    | "verification_request"

  createdAt: Timestamp
}
```

---

# reports

Document Path

```text
reports/{reportId}
```

---

## Purpose

Stores user reports.

---

## Schema

```typescript
{
  id: string

  reporterId: string

  targetUserId: string

  reason:
    | "spam"
    | "fake_profile"
    | "harassment"
    | "hate_speech"
    | "inappropriate_content"

  description: string

  status:
    | "pending"
    | "reviewing"
    | "resolved"
    | "rejected"

  reviewedBy?: string

  reviewedAt?: Timestamp

  createdAt: Timestamp
}
```

---

# verification_requests

Document Path

```text
verification_requests/{requestId}
```

---

## Purpose

Stores verification requests.

---

## Schema

```typescript
{
  id: string

  userId: string

  verificationType:
    | "photo"
    | "government_id"

  selfieImageUrl: string

  governmentIdImageUrl?: string

  status:
    | "pending"
    | "approved"
    | "rejected"

  rejectionReason?: string

  reviewedBy?: string

  reviewedAt?: Timestamp

  createdAt: Timestamp
}
```

---

## Image Access

`selfieImageUrl` and `governmentIdImageUrl` store Firebase Storage paths, not public download URLs.

Images must be served through short-lived signed URLs generated by a Cloud Function. Direct client access to these Storage paths must be blocked by Firebase Storage Rules.

---

# subscriptions

Document Path

```text
subscriptions/{subscriptionId}
```

---

## Purpose

Stores RevenueCat synchronized subscription data.

---

## Schema

```typescript
{
  id: string

  userId: string

  plan:
    | "free"
    | "premium"

  status:
    | "active"
    | "expired"
    | "cancelled"

  revenueCatCustomerId: string

  startedAt: Timestamp

  expiresAt: Timestamp

  updatedAt: Timestamp
}
```

---

# Realtime Database Schema

## Presence

Path

```text
status/{userId}
```

Schema

```typescript
{
  isOnline: boolean

  lastSeen: number
}
```

---

## Typing Indicators

Path

```text
typing/{matchId}/{userId}
```

Schema

```typescript
boolean
```

Value is `true` when the user is actively typing. Clients remove the entry or set it to `false` when typing stops. Cloud Functions do not sync typing state to Firestore.

---

# Recommended Firestore Indexes

## User Discovery

```text
identity
relationshipGoal
city
verificationLevel
```

---

## Nearby Search

```text
geoHash
verificationLevel
```

---

## Explore Feed

```text
identity
relationshipGoal
age
```

---

## Matches

```text
users
lastMessageAt
```

---

## Notifications

```text
userId
read
createdAt
```

---

# Relationships

```text
User
 ↓
Like
 ↓
Match
 ↓
Message
```

---

```text
User
 ↓
Verification Request
```

---

```text
User
 ↓
Subscription
```

---

```text
User
 ↓
Notification
```

---

```text
User
 ↓
users/{userId}/blocks (subcollection)
```

---

```text
User
 ↓
Report
```

---

# Data Retention Policy

## Messages

Retained until:

* User deletion
* Admin removal

---

## Reports

Retained for moderation history.

---

## Verification Requests

Retained for audit purposes.

---

## Notifications

Automatically archived after 90 days.

---

# Scalability Considerations

Design target:

```text
100,000+ users
```

```text
1,000,000+ messages
```

without requiring schema redesign.

---

# Security Requirements

Users may only access:

* Their own profile settings
* Their own notifications
* Matches they belong to
* Messages within their matches
* Their own blocks and passes subcollections

Exact location coordinates in `users/{userId}/private/location` must be readable only by the document owner.

Verification document images must be served through Cloud Function signed URLs only. Direct Firebase Storage access must be blocked.

Admin access must be controlled through Firebase Custom Claims.
