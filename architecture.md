# Bloom Architecture

## Version

2.0 (Flutter Edition)

---

# Overview

Bloom is a premium LGBTQ+ dating application focused on meaningful relationships, safety, and authentic connections.

This architecture is designed for:

* Scalability
* Maintainability
* Testability
* Security
* Feature-based development

Target scale:

* 100,000+ users
* 1,000,000+ messages
* Multi-region deployment ready

---

# Technology Stack

## Frontend

Framework

```text
Flutter 3.x
```

Language

```text
Dart
```

---

## State Management

```text
Riverpod
```

Purpose:

* Global application state
* Authentication state
* User state
* UI state

---

## Navigation

```text
GoRouter
```

Purpose:

* Authentication routing
* Deep linking
* Route guards
* Nested navigation

---

## Data Models

```text
Freezed
JsonSerializable
```

Purpose:

* Immutable models
* Serialization
* Type safety
* Union types

---

## Backend

Firebase Authentication

```text
Email
Google
Apple
```

Cloud Firestore

```text
Primary database
```

Firebase Storage

```text
Images
Verification documents
```

Verification document images are stored in restricted Storage paths and served exclusively through Cloud Function signed URLs. Long-lived public download URLs must never be used for government ID or selfie images.

Firebase Cloud Messaging

```text
Push notifications
```

Firebase Realtime Database

```text
Presence system
Online status
Last seen tracking
Typing indicators
```

Cloud Functions

```text
Match creation
Notifications
Moderation
Subscription sync
```

---

## Subscription Platform

```text
RevenueCat
```

Purpose:

* iOS subscriptions
* Android subscriptions
* Subscription synchronization

---

## Maps & Location

Google Maps Flutter

```text
google_maps_flutter
```

Location Services

```text
geolocator
```

GeoHash

```text
Location-based discovery
```

---

## Image Handling

```text
cached_network_image
```

Purpose:

* Image caching
* Performance optimization

---

## Animations

```text
flutter_animate
```

Purpose:

* Swipe animations
* Match celebration
* Premium screens

---

# Architecture Pattern

## Feature-First Architecture

Project structure must be organized by feature.

Never organize by screen type.

---

# Project Structure

```text
lib/

core/
├── constants/
├── theme/
├── router/
├── services/
├── utils/
├── extensions/

shared/
├── widgets/
├── models/
├── providers/

features/

auth/
├── data/
├── domain/
├── presentation/

profile/
├── data/
├── domain/
├── presentation/

explore/
├── data/
├── domain/
├── presentation/

match/
├── data/
├── domain/
├── presentation/

chat/
├── data/
├── domain/
├── presentation/

notification/
├── data/
├── domain/
├── presentation/

verification/
├── data/
├── domain/
├── presentation/

premium/
├── data/
├── domain/
├── presentation/

admin/
├── data/
├── domain/
├── presentation/
```

---

# Layer Architecture

Each feature follows:

```text
Presentation
↓
Domain
↓
Data
```

---

## Presentation Layer

Responsibilities:

* Screens
* Widgets
* State consumption
* User interaction

Examples:

```text
ProfileScreen
ExploreScreen
ChatScreen
```

---

## Domain Layer

Responsibilities:

* Business logic
* Use cases
* Validation rules

Examples:

```text
CreateMatchUseCase
SendMessageUseCase
LikeUserUseCase
```

---

## Data Layer

Responsibilities:

* Firestore access
* Firebase Storage access
* Cloud Function calls
* DTO mapping

Examples:

```text
AuthRepository
UserRepository
MatchRepository
```

---

# State Management Architecture

## Global Providers

Required providers:

```dart
authProvider

currentUserProvider

notificationProvider

subscriptionProvider

locationProvider
```

---

## Feature Providers

Each feature owns its own providers.

Example:

```dart
exploreProvider

matchProvider

chatProvider
```

---

# Authentication Flow

```text
Launch App
↓
Check Firebase Auth
↓
Authenticated?
↓
YES → Home
NO → Login
```

---

# Onboarding Flow

```text
Welcome
↓
Identity Selection
↓
Age Verification
↓
Profile Creation
↓
Photo Upload
↓
Discovery Preferences
↓
Home
```

---

# Navigation Structure

## Root Routes

```text
/
```

Splash

```text
/login
```

Authentication

```text
/onboarding
```

User onboarding

```text
/home
```

Authenticated application

---

## Bottom Navigation

```text
Explore
Browse
Chat
Notifications
Profile
```

---

# Firebase Architecture

## Firestore

Purpose:

```text
Profiles
Likes
Matches
Messages
Notifications
Reports
Subscriptions
```

---

## Realtime Database

Purpose:

```text
Presence
Online state
Last seen
Typing indicators
```

Structure:

```text
status/{userId}
typing/{matchId}/{userId}
```

---

## Cloud Functions

Responsibilities:

### Match Creation

```text
Mutual Like
↓
Create Match
```

---

### Compatibility Calculation

```text
Interest Matching
Goal Matching
Distance Score
```

---

### Notification Dispatch

```text
Like
Match
Message
Verification
```

---

### RevenueCat Synchronization

```text
Subscription status updates
Webhook signature verification
```

Verify the `X-RevenueCat-Signature` header on every incoming webhook request before processing.

---

# Location Architecture

## Discovery Flow

```text
User Location
↓
GeoHash Generation
↓
Firestore Query
↓
Distance Filtering
↓
Explore Feed
```

---

## Privacy Requirements

Never expose:

```text
Exact latitude
Exact longitude
```

Only expose:

```text
Approximate distance
```

Examples:

```text
2 km away
10 km away
```

---

## Location Storage

Exact GeoPoint:

```text
users/{userId}/private/location
```

GeoHash on main user document:

```text
users/{userId}.geoHash
```

GeoHash is used for discovery queries. Exact GeoPoint is never stored on the main user document.

---

# Messaging Architecture

Conversation source:

```text
matches/{matchId}
```

Messages:

```text
matches/{matchId}/messages
```

---

## Message Types

```text
Text
Image
```

---

## Premium Feature

Read receipts:

```text
Premium only
```

---

# Presence Architecture

Realtime Database:

```text
status/{userId}
```

Stores:

```text
isOnline
lastSeen
```

Cloud Function syncs state into:

```text
users/{userId}
```

for UI consumption.

---

# Subscription Architecture

RevenueCat

↓

Webhook

↓

Cloud Function

↓

Firestore

↓

users.premium

subscriptions collection

---

# Security Architecture

Authentication:

```text
Firebase Auth
```

Authorization:

```text
Firestore Security Rules
```

Admin Access:

```text
Firebase Custom Claims
```

---

# Performance Requirements

Profile Feed

```text
< 1 second
```

---

Chat Message Delivery

```text
< 500 ms
```

---

Image Upload

```text
< 5 seconds
```

---

Swipe Animation

```text
60 FPS
```

---

# Monitoring

Firebase Crashlytics

Purpose:

```text
Crash tracking
```

---

Firebase Analytics

Purpose:

```text
User behavior
Conversion tracking
Retention metrics
```

---

# Scalability Rules

Never query entire collections.

Always:

```text
Paginate
Index
Cache
```

---

Use GeoHash for discovery.

Use cached_network_image for profile photos.

Use Riverpod providers instead of singleton state.

---

# Definition of Success

The architecture is successful when:

* Authentication is reliable
* Matching is scalable
* Messaging is real-time
* Notifications are delivered
* Presence is accurate
* Premium subscriptions are synchronized
* UI remains responsive
* Security rules protect all sensitive data

```
```
