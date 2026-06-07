# Bloom Requirements Specification

## Version

2.0 (Flutter Edition)

---

# Project Overview

## Application Name

Bloom

---

## Application Type

LGBTQ+ Dating Application

---

## Mission

Bloom helps LGBTQ+ individuals build meaningful, safe, and authentic connections through a modern and trustworthy mobile experience.

The platform focuses on:

* Authentic relationships
* User safety
* Privacy protection
* Inclusive experiences
* Premium user experience

---

# Branding

## Application Name

```text
Bloom
```

---

## Primary Color

```text
#00C896
```

---

## Secondary Colors

```text
#6D5EF4
#FF7FBF
```

Used for:

* Premium experiences
* Match celebrations
* Highlight interactions

---

## Design Keywords

```text
Modern
Friendly
Warm
Inclusive
Trustworthy
Premium
Youthful
```

---

# Target Audience

## Primary Audience

Adults aged:

```text
18 - 40
```

who identify as LGBTQ+.

---

## Geographic Scope

Initial Launch:

```text
Global
```

Localization-ready architecture required.

---

# Supported Platforms

## Mobile Platforms

```text
iOS
Android
```

---

## Framework

```text
Flutter
```

---

# Technology Requirements

## Frontend

```text
Flutter 3.x
Dart
```

---

## State Management

```text
Riverpod
```

---

## Navigation

```text
GoRouter
```

---

## Model Generation

```text
Freezed
JsonSerializable
```

---

## Backend

```text
Firebase Authentication
Cloud Firestore
Firebase Storage
Firebase Cloud Messaging
Firebase Realtime Database
Cloud Functions
```

---

## Subscription Platform

```text
RevenueCat
```

---

# Core Features

The application must include the following features.

---

# User Authentication

## Requirements

Users must be able to:

* Create account
* Log in
* Log out
* Reset password

---

## Authentication Providers

Required:

* Email / Password
* Google Sign-In
* Apple Sign-In

---

# User Onboarding

New users must complete onboarding before accessing discovery features.

---

## Onboarding Steps

1. Welcome
2. Identity Selection
3. Age Verification
4. Profile Creation
5. Photo Upload
6. Discovery Preferences

---

# User Profile

## Profile Information

Required:

* Nickname
* Birthdate
* Identity
* Relationship Goal
* Bio

Optional:

* Interests
* Occupation
* Education
* Height
* Social Links

---

## Profile Photos

Requirements:

* Maximum 6 photos
* One primary photo
* Reordering supported
* Upload and deletion supported

---

## Profile Visibility

Options:

```text
public
hidden
selective
```

---

# Discovery System

Users must be able to discover nearby profiles.

---

## Discovery Modes

### Explore

Card-based swipe interface.

Actions:

```text
Pass
Like
Super Like
```

---

### Browse

List-based profile browsing.

---

### Map Discovery

Optional map view showing approximate nearby users.

Exact locations must never be exposed.

---

# Matching System

## Match Creation

A match occurs when:

```text
User A likes User B
AND
User B likes User A
```

---

## Compatibility Score

Display:

```text
0 - 100%
```

based on:

* Shared interests
* Relationship goals
* Distance
* Activity level

---

## Match Celebration

Display Bloom-themed celebration screen.

Example:

```text
It's a Bloom! 🌸
```

---

# Messaging System

Matched users can communicate through real-time messaging.

---

## Supported Message Types

* Text
* Image

---

## Messaging Features

Required:

* Real-time updates
* Typing indicators
* Message deletion
* Unmatch support

---

## Premium Messaging Feature

Read receipts.

---

# Presence System

Users may view activity status.

---

## Presence Information

```text
Online
Offline
Last Seen
```

---

## Privacy Controls

Users may hide:

* Online status
* Last seen status

---

# Notifications

## In-App Notifications

Required:

* Match
* Message
* Like
* Verification

---

## Push Notifications

Supported through:

```text
Firebase Cloud Messaging
```

---

# Safety Features

User safety is a core requirement.

---

## Blocking

Users must be able to block other users.

---

## Reporting

Report reasons:

* Spam
* Fake Profile
* Harassment
* Hate Speech
* Inappropriate Content

---

## Safety Center

Provide safety information and reporting tools.

---

# Verification System

Purpose:

Increase trust and reduce fake accounts.

---

## Verification Levels

```text
none
photo
government_id
```

---

## Verification Badges

Verification status must be visible on profiles.

---

# Premium Subscription

Premium subscriptions must be supported.

---

## Premium Features

* Unlimited Likes
* View Received Likes
* Read Receipts
* Advanced Filters
* Premium Badge
* Priority Profile Exposure

---

## Subscription Management

Managed through:

```text
RevenueCat
```

---

# Admin Features

Administrative tools must be available.

---

## User Management

Actions:

* Suspend
* Restore
* Delete

---

## Verification Management

Actions:

* Approve
* Reject

---

## Report Management

Actions:

* Review
* Resolve
* Dismiss

---

## Analytics Dashboard

Metrics:

* Daily Active Users
* Monthly Active Users
* Match Rate
* Message Volume
* Subscription Conversion

---

# Privacy Requirements

The application must protect user privacy.

---

## Location Privacy

Never expose:

```text
Exact latitude
Exact longitude
```

Expose only:

```text
Approximate distance
```

Examples:

```text
2 km away
10 km away
```

---

## Account Visibility

Users control:

* Profile visibility
* Online status visibility
* Last seen visibility
* Notification preferences

---

# Performance Requirements

## Feed Loading

```text
< 1 second
```

---

## Message Delivery

```text
< 500 ms
```

---

## Image Upload

```text
< 5 seconds
```

---

## Swipe Performance

```text
60 FPS
```

---

# Scalability Requirements

The system must support:

```text
100,000+ users
1,000,000+ messages
```

without architectural changes.

---

# Definition of Success

Bloom is considered complete when:

* Authentication works
* Onboarding works
* Profile management works
* Discovery works
* Matching works
* Messaging works
* Presence works
* Notifications work
* Verification works
* Premium subscriptions work
* Admin tools work
* Security requirements are satisfied
* Production deployment succeeds

```
```
