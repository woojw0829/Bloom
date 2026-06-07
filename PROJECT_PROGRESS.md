# Bloom Project Progress

## Purpose

This file tracks the actual implementation progress of the Bloom app across all phases and tasks. It records which tasks are complete, which are in progress, which are deferred, and what the next recommended task is.

**Rules for using this file:**

- **Read this file before starting any new task.** Confirm the next recommended task and check for deferred tasks that must not be accidentally implemented.
- **Update this file after completing each task.** Mark the task `[x]`, update the next recommended task to `[>]`, add any new deferred tasks as `[!]`, and add deploy commands if rules / functions / storage / indexes changed.
- **Deferred tasks must remain visible.** Do not remove them — they may be resumed later under specific conditions.
- This file complements [`task_breakdown.md`](task_breakdown.md). It does not replace the official task list.

---

## Status Legend

| Symbol | Meaning |
|--------|---------|
| `[x]` | Complete |
| `[ ]` | Not started |
| `[~]` | In progress |
| `[!]` | Deferred / intentionally postponed |
| `[>]` | Next recommended task |

---

## Current Project Status Summary

| Phase / Task | Status |
|---|---|
| Phase 10 Notifications | Complete |
| Phase 11 Safety | Complete |
| Post-Phase 11 Location Privacy Hardening | Complete |
| Phase 12 Verification | In progress |
| Task 12.1 Photo Verification | Complete |
| Task 12.2 Government ID Verification | **Deferred for MVP** |
| Task 12.3 Verification Request Management | **Next recommended task** |
| Task 12.4 Verification Badges | Not started |

---

## Completed Work

### Phase 7 — Matching

- [x] Task 7.1 Swipe actions
- [x] Task 7.2 Pass tracking
- [x] Task 7.3 Like tracking
- [x] Task 7.4 Match creation (Cloud Function) — requires `firebase deploy --only functions`
- [x] Task 7.5 Match celebration screen

### Post-Phase 7 Enhancements

- [x] Map Enhancement — show current device location on Map Discovery
- [x] Location Privacy Logging Cleanup — removed exact lat/lng from debug logs

### Phase 8 — Messaging

- [x] Task 8.1 Conversation list
- [x] Task 8.2 Real-time messaging
- [x] Task 8.3 Image messaging
- [x] Chat Image Storage Security Hardening
- [x] Task 8.4 Typing indicator
- [x] Task 8.5 Read receipts
- [x] Task 8.6 Unmatch flow

### Phase 9 — Presence System

- [x] Task 9.1 Realtime Database status tracking
- [x] Task 9.2 onDisconnect handling
- [x] Task 9.3 Cloud Function sync

### Phase 10 — Notifications

- [x] Task 10.1 FCM token registration
- [x] Post-Task 10.1 FCM token privacy hardening — token moved to `users/{userId}/private/notificationTokens`
- [x] Task 10.2 Notification collection
- [x] Task 10.3 Push notifications (Cloud Functions deployed)
- [x] Task 10.4 Notification center screen

### Phase 11 — Safety

- [x] Task 11.1 Block user — block domain/data/presentation layer; ChatScreen overflow menu with confirmation dialog; discovery feed filtering (Explore/Browse/Map); Firestore block rules tightened + block-aware like/message rules; `onLikeCreated` Cloud Function block check; EN+KO localization; 19 unit tests
- [x] Task 11.2 Report user — report domain/data/presentation layer; ChatScreen overflow menu with bottom sheet (reason selection + optional description); Firestore reports rule tightened (full field validation, no client reads); EN+KO localization; 35 unit tests
- [x] Task 11.3 Safety Center — `SafetyCenterScreen` at `/profile/safety`; blocked users list with unblock (confirmation dialog + snackbar); `UnblockUserUseCase`; `fetchBlockedUsers` + `unblockUser` on `BlockRepository`; `SafetyCenterNotifier`; Firestore block delete rule updated; EN+KO localization (24 keys); 10 unit tests

### Post-Phase 11 — Location Privacy Hardening

- [x] Replace map user markers with aggregate nearby user count
- [x] Remove individual user markers from Map Discovery
- [x] Remove approximate user location markers
- [x] Remove geoHash/cell markers
- [x] Remove marker tap profile preview cards
- [x] Show only privacy-safe nearby count buckets (`"1–4"`, `"5–9"`, `"10–19"`, `"20–49"`, `"50+"`)
- [x] Use fixed 5 km radius for nearby count
- [x] Hide exact counts for 1–4 nearby users
- [x] Keep private location documents unread by other clients
- [x] Do not write current device location to Firestore during discovery

### Phase 12 — Verification

- [x] Task 12.1 Photo verification — `VerificationRequest` model + `VerificationType`/`VerificationRequestStatus` enums; `VerificationRepository` + `VerificationRepositoryImpl`; `SubmitPhotoVerificationUseCase` (sealed outcomes); `PhotoVerificationController` (image picker + submit); `PhotoVerificationScreen` at `/profile/verification` (pending/approved/rejected/submission states); Profile tile added; Firestore rules tightened (key validation + `selfieImageUrl` path validation); Storage rules added for `verification_requests/{userId}/{requestId}/selfie.jpg` (write-only, read blocked); composite index added (`userId+verificationType+createdAt`); EN+KO localization (20 keys); 27 new unit tests; `flutter analyze` clean, 433/433 passed
- [!] Task 12.2 Government ID verification — **Deferred for MVP** (see [Deferred Tasks](#deferred-tasks))
- [ ] Task 12.3 Verification request management
- [ ] Task 12.4 Verification badges

---

## Deferred Tasks

### Task 12.2 — Government ID Verification

**Status:** Deferred for MVP.

**Reason:**
Government ID verification collects highly sensitive personal information and may be excessive for a normal dating app signup or basic trust flow. Bloom is an LGBTQ+ dating app, so collecting government ID images may create additional privacy, safety, and identity-related risks for users. Some users' legal ID information may not match their gender identity or public profile identity. The risk to user safety and trust outweighs the verification benefit at MVP scale.

**Decision:**
Do not implement Government ID verification in the MVP.

**Do not implement:**
- Government ID upload
- `governmentIdImageUrl` write flow
- Government ID verification screen
- Government ID Storage path
- Government ID signed URL Cloud Function
- OCR or automated ID parsing
- ID number collection
- Legal name collection
- Address collection
- Mandatory government ID verification
- Government ID requirement during signup
- Government ID requirement during onboarding

**May be reconsidered later, only if explicitly requested, for:**
- Exceptional safety review cases (e.g., serious abuse reports requiring identity confirmation)
- Manual re-verification during a suspended account appeal process
- Legal or compliance requirement imposed by a specific jurisdiction
- An optional high-trust verification tier (fully opt-in, never required)

**Future implementation notes (if this task is ever resumed):**
- Store government ID images as Firebase Storage paths — never as download URLs.
- Do not call `getDownloadURL()`.
- Block direct client read access through Storage rules (`allow read: if false`).
- Serve images only through short-lived signed URLs generated by a Cloud Function, for authorized admins only.
- Do not store ID number, home address, legal name, or OCR-extracted data unless there is a clear legal basis and explicit user consent.
- Do not expose government ID verification to standard signup or onboarding by default.
- `VerificationType.governmentId` already exists in the domain model for Firestore parsing compatibility — do not re-add it.
- `VerificationRequest.governmentIdImageUrl` already exists as a nullable read-only field — do not re-add it.
- Firestore rules already block client writes of `governmentIdImageUrl` — verify the rule is still in place before resuming.

---

## Next Recommended Task

**[>] Task 12.3 — Verification Request Management**

**Scope:**
Implement verification request management for **photo verification only**.

**Important constraints:**
- Task 12.3 must not depend on or reference Government ID verification.
- Task 12.3 manages photo verification requests created by Task 12.1.
- If admin review is introduced, it must review only:
  - `verificationType == "photo"`
  - `selfieImageUrl` (Storage path)
  - `status` (`pending` / `approved` / `rejected`)
- Do not add government ID review to Task 12.3 unless Task 12.2 is explicitly resumed later.
- Do not update `users/{userId}.verificationLevel` from the client.
- Do not create notification documents from the client.
- Do not send push notifications from the client.

---

## Required Rules for Future Claude Code Sessions

Before starting any new task, a Claude Code session must:

1. Read `PROJECT_PROGRESS.md`.
2. Confirm the next recommended task (look for `[>]`).
3. Confirm that deferred tasks (marked `[!]`) are not accidentally implemented.
4. After completing the task, update this file:
   - Mark the completed task as `[x]`.
   - Update the next recommended task to `[>]`.
   - Add any new deferred task as `[!]` with a reason.
   - Add deploy commands if `firestore.rules`, `storage.rules`, `firestore.indexes.json`, or Cloud Functions changed.
   - Add important privacy or security notes under the completed task entry.

---

## Deployment Notes

### Pending Deploy — Task 12.1 Photo Verification

Task 12.1 changed the following files, which require a Firebase deploy if not already run:

| File changed | Deploy command |
|---|---|
| `firestore.rules` | `firebase deploy --only firestore:rules` |
| `storage.rules` | `firebase deploy --only storage` |
| `firestore.indexes.json` | `firebase deploy --only firestore:indexes` |

```bash
firebase deploy --only firestore:rules
firebase deploy --only storage
firebase deploy --only firestore:indexes
```

If the user confirms these have been deployed, mark this section as deployed.

---

## Privacy Principles

Bloom follows a **data minimization** approach: collect only the information needed for the feature to work. These principles apply to all tasks.

**For MVP:**

- Photo verification is allowed and implemented.
- Government ID verification is deferred — do not collect government ID images.
- Exact user locations must not be exposed to other clients.
- Individual user location markers must not be shown on the map.
- Verification images must not be stored as public download URLs.
- Direct Storage reads for verification images must remain blocked (`allow read: if false`).
- `selfieImageUrl` in Firestore must store a Firebase Storage path, never a `https://` URL.
- `getDownloadURL()` must not be called for verification images.
- `users/{userId}.verificationLevel` must not be updated by client code — it is a system field controlled by Cloud Functions and admins.
- Sensitive data (legal name, address, ID number, government documents) must not be collected unless there is a clear legal basis and explicit user consent.
