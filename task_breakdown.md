# Bloom Development Task Breakdown

## Version

2.0 (Flutter Edition)

---

# Project Overview

Bloom is a premium LGBTQ+ dating application built with Flutter and Firebase.

Primary goals:

* Safe dating environment
* Modern mobile experience
* Real-time messaging
* Location-based discovery
* Premium subscription model
* Scalable architecture

---

# Technology Stack

Frontend

* Flutter 3.x
* Dart

Architecture

* Feature-First Architecture
* Clean Architecture

State Management

* Riverpod

Navigation

* GoRouter

Models

* Freezed
* JsonSerializable

Backend

* Firebase Authentication
* Cloud Firestore
* Firebase Storage
* Firebase Cloud Messaging
* Firebase Realtime Database
* Cloud Functions

Subscription

* RevenueCat

---

# Development Strategy

Implementation order:

```text
Foundation
↓
Authentication
↓
Profile
↓
Location
↓
Discovery
↓
Matching
↓
Messaging
↓
Presence
↓
Notifications
↓
Safety
↓
Verification
↓
Premium
↓
Admin
↓
Testing
↓
Release
```

---

# Phase 0

# Project Foundation

Goal:

Establish Flutter project architecture and development environment.

---

## Task 0.1

Create Flutter project.

Deliverables:

* Flutter project initialized
* Android support
* iOS support

Acceptance Criteria:

* Project builds successfully

---

## Task 0.2

Install dependencies.

Required packages:

```yaml
flutter_riverpod
go_router
freezed
freezed_annotation
json_annotation
firebase_core
firebase_auth
cloud_firestore
firebase_storage
firebase_messaging
firebase_database
google_maps_flutter
geolocator
cached_network_image
flutter_animate
purchases_flutter
```

Acceptance Criteria:

* Application compiles successfully

---

## Task 0.3

Configure code generation.

Setup:

```text
build_runner
Freezed
JsonSerializable
```

Acceptance Criteria:

* Model generation works

---

## Task 0.4

Create project structure.

Acceptance Criteria:

```text
lib/
core/
shared/
features/
```

exists and follows architecture.md

---

## Task 0.5

Implement design system.

Create:

* Color system
* Typography system
* Spacing system
* Radius system
* Shadow system

Reference:

```text
ui_guidelines.md
```

Acceptance Criteria:

* ThemeData configured

---

# Phase 1

# Firebase Setup

Goal:

Configure backend services.

---

## Task 1.1

Connect Firebase project.

Services:

* Authentication
* Firestore
* Storage
* Messaging
* Realtime Database

Acceptance Criteria:

* Firebase initialized successfully

---

## Task 1.2

Create Firestore indexes.

Reference:

```text
database_schema.md
```

Acceptance Criteria:

* Required indexes deployed

---

## Task 1.3

Configure Firebase Security Rules.

Acceptance Criteria:

* Unauthorized access blocked

---

## Task 1.4

Configure Firebase Storage Rules.

Acceptance Criteria:

* Storage protected

---

# Phase 2

# Authentication

Goal:

Allow secure account access.

---

## Task 2.1

Email registration.

Features:

* Sign Up
* Login
* Logout
* Password Reset

Acceptance Criteria:

* Authentication flow completed

---

## Task 2.2

Google Sign-In.

Acceptance Criteria:

* Google authentication works

---

## Task 2.3

Apple Sign-In.

Acceptance Criteria:

* Apple authentication works

---

## Task 2.4

Authentication Guards.

Implement:

```text
GoRouter route protection
```

Acceptance Criteria:

* Unauthenticated users redirected

---

# Phase 3

# Onboarding

Goal:

Create initial user profile.

---

## Task 3.1

Identity selection.

---

## Task 3.2

Age verification.

18+ required.

---

## Task 3.3

Profile creation.

Fields:

* Nickname
* Birthdate
* Bio
* Relationship Goal
* Interests

---

## Task 3.4

Photo upload.

Requirements:

* Maximum 6 photos
* Primary photo selection
* Reordering support

---

## Task 3.5

Discovery preferences.

Acceptance Criteria:

* Complete onboarding flow works

---

# Phase 4

# User Profile

Goal:

Manage profile information.

---

## Task 4.1

Profile screen.

---

## Task 4.2

Edit profile.

---

## Task 4.3

Photo management.

---

## Task 4.4

Privacy settings.

Settings:

* Profile visibility
* Online status visibility

---

## Task 4.5

Notification settings.

---

# Phase 5

# Location System

Goal:

Support nearby discovery.

---

## Task 5.1

Location permission flow.

---

## Task 5.2

Location collection.

Store on main user document:

* GeoHash

Store in private subcollection:

* GeoPoint

Path:

```text
users/{userId}/private/location
```

---

## Task 5.3

Distance calculation.

---

## Task 5.4

Location update lifecycle.

Update when:

* Login
* App foreground
* Significant movement

Acceptance Criteria:

* User location updates correctly

---

# Phase 6

# Discovery

Goal:

Discover nearby users.

---

## Task 6.1

Explore feed.

Features:

* Swipe cards
* Pagination
* Infinite loading

---

## Task 6.2

Browse screen.

List-based discovery.

---

## Task 6.3

Filtering.

Filters:

* Age
* Distance
* Identity
* Relationship Goal
* Verification

---

## Task 6.4

Compatibility score display.

---

## Task 6.5

Map Discovery.

Show approximate nearby user locations on map.

Requirements:

* Approximate positions only
* No exact coordinates exposed
* Cluster markers for density areas

Acceptance Criteria:

* Users discover relevant profiles
* Map view displays nearby users without exposing exact coordinates

---

# Phase 7

# Matching

Goal:

Create mutual connections.

---

## Task 7.1

Swipe actions.

Actions:

* Pass
* Like
* Super Like

---

## Task 7.2

Pass tracking.

Collection:

```text
users/{userId}/passes
```

---

## Task 7.3

Like tracking.

Collection:

```text
likes
```

---

## Task 7.4

Match creation.

Cloud Function:

```text
Mutual Like
→ Match
```

---

## Task 7.5

Match celebration screen.

Acceptance Criteria:

* Match generation works

---

# Phase 8

# Messaging

Goal:

Enable real-time communication.

---

## Task 8.1

Conversation list.

---

## Task 8.2

Real-time messaging.

---

## Task 8.3

Image messaging.

---

## Task 8.4

Typing indicator.

---

## Task 8.5

Read receipts.

Premium feature.

---

## Task 8.6

Unmatch flow.

Acceptance Criteria:

* Chat works in real time

---

# Phase 9

# Presence System

Goal:

Track online status.

---

## Task 9.1

Realtime Database status tracking.

Path:

```text
status/{userId}
```

---

## Task 9.2

onDisconnect handling.

---

## Task 9.3

Cloud Function sync.

RTDB → Firestore

Acceptance Criteria:

* Presence information accurate

---

# Phase 10

# Notifications

Goal:

Keep users engaged.

---

## Task 10.1

FCM token registration.

---

## Task 10.2

Notification collection.

---

## Task 10.3

Push notifications.

Triggers:

* Like
* Match
* Message
* Verification

---

## Task 10.4

Notification center screen.

Acceptance Criteria:

* Notifications delivered successfully

---

# Phase 11

# Safety

Goal:

Protect users.

---

## Task 11.1

Block user.

Collection:

```text
users/{userId}/blocks
```

---

## Task 11.2

Report user.

Reasons:

* Spam
* Fake Profile
* Harassment
* Hate Speech
* Inappropriate Content

---

## Task 11.3

Safety Center.

Acceptance Criteria:

* Unsafe users can be blocked

---

# Phase 12

# Verification

Goal:

Increase trust.

---

## Task 12.1

Photo verification.

---

## Task 12.2

Government ID verification.

Requirements:

* Store images as Firebase Storage paths, not public download URLs
* Serve images through Cloud Function signed URLs
* Block direct client access via Firebase Storage Rules

---

## Task 12.3

Verification request management.

Collection:

```text
verification_requests
```

---

## Task 12.4

Verification badges.

Acceptance Criteria:

* Verification workflow completed

---

# Phase 13

# Premium Subscription

Goal:

Monetization.

---

## Task 13.1

RevenueCat integration.

Requirements:

* Initialize `purchases_flutter` SDK
* Webhook endpoint must verify `X-RevenueCat-Signature` header before processing any subscription update

---

## Task 13.2

Subscription synchronization.

---

## Task 13.3

Premium feature gates.

Features:

* Unlimited Likes
* View Received Likes
* Read Receipts
* Advanced Filters
* Premium Badge

Acceptance Criteria:

* Premium features restricted correctly

---

# Phase 14

# Admin

Goal:

Platform management.

---

## Task 14.1

Admin authentication.

Firebase Custom Claims.

---

## Task 14.2

User management.

Actions:

* Suspend
* Restore
* Delete

---

## Task 14.3

Report management.

---

## Task 14.4

Verification review.

---

## Task 14.5

Analytics dashboard.

Metrics:

* DAU
* MAU
* Match Rate
* Subscription Conversion

Acceptance Criteria:

* Admin tools functional

---

# Phase 15

# Testing

Goal:

Validate system quality.

---

## Task 15.1

Unit tests.

---

## Task 15.2

Widget tests.

---

## Task 15.3

Integration tests.

---

## Task 15.4

Authentication tests.

---

## Task 15.5

Messaging tests.

---

## Task 15.6

Subscription tests.

Acceptance Criteria:

* Core flows tested

---

# Phase 16

# Performance Optimization

Goal:

Optimize user experience.

---

## Task 16.1

Image optimization.

---

## Task 16.2

Firestore query optimization.

---

## Task 16.3

Provider optimization.

---

## Task 16.4

Animation optimization.

Target:

```text
60 FPS
```

Acceptance Criteria:

* Smooth experience maintained

---

# Phase 17

# Release Preparation

Goal:

Production deployment.

---

## Task 17.1

Production Firebase environment.

---

## Task 17.2

Environment configuration.

---

## Task 17.3

Crashlytics integration.

---

## Task 17.4

App Store preparation.

---

## Task 17.5

Google Play preparation.

---

## Task 17.6

Production release.

Acceptance Criteria:

* App successfully published

---

# Definition of Done

The project is complete when:

* Authentication works
* Onboarding works
* Profiles work
* Discovery works
* Matching works
* Messaging works
* Presence works
* Notifications work
* Verification works
* Premium subscriptions work
* Admin tools work
* Tests pass
* Production deployment succeeds

```
```
