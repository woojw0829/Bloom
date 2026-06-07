# Bloom Phase 8.1 — Seoul Test Data Seed Tools

Generates 100 synthetic Seoul-area test users and optional matching / conversation data for testing all completed functionality through Phase 8.1.

**Safety**: All data is synthetic and clearly marked. Scripts never modify real user documents. All test user IDs are deterministic (`test_seoul_001` through `test_seoul_100`).

---

## Prerequisites

### 1. Node.js ≥ 18

```
node --version
```

### 2. Install dependencies

Run once from the `tools/seed/` directory:

```
npm install
```

### 3. Firebase credentials

The scripts use Firebase Admin SDK. Provide credentials via one of these methods:

**Option A — Service account JSON (recommended for local dev):**

1. Firebase Console → Project Settings → Service Accounts → Generate new private key
2. Save the downloaded JSON somewhere safe (NOT inside the project repo)
3. Set the path:

```
# bash / zsh
export SERVICE_ACCOUNT_PATH="/path/to/serviceAccountKey.json"

# PowerShell
$env:SERVICE_ACCOUNT_PATH = "C:\path\to\serviceAccountKey.json"
```

**Option B — Application Default Credentials:**

```
gcloud auth application-default login
```

### 4. Realtime Database URL (optional, for presence seeding)

If the app uses RTDB for online presence, set:

```
# bash / zsh
export FIREBASE_DATABASE_URL="https://<project-id>-default-rtdb.firebaseio.com"

# PowerShell
$env:FIREBASE_DATABASE_URL = "https://<project-id>-default-rtdb.firebaseio.com"
```

If not set, RTDB presence seeding is skipped (Firestore `isOnline: true` is still written).

---

## Quick Start

All commands run from `tools/seed/`.

### Dry-run (no writes, shows plan only)

```
node phase8_1_seoul_seed.js --dry-run
```

### Seed 100 users only

```
node phase8_1_seoul_seed.js --confirm phase8_1_seoul_001
```

### Seed users + incoming likes for your UID

```
CURRENT_USER_ID=<your-uid> node phase8_1_seoul_seed.js --confirm phase8_1_seoul_001 --seed-incoming-likes
```

### Seed users + incoming likes + existing matches

```
CURRENT_USER_ID=<your-uid> node phase8_1_seoul_seed.js --confirm phase8_1_seoul_001 --seed-incoming-likes --seed-existing-matches
```

### Seed users + incoming likes + existing matches + passes

```
CURRENT_USER_ID=<your-uid> node phase8_1_seoul_seed.js --confirm phase8_1_seoul_001 --seed-incoming-likes --seed-existing-matches --seed-passes
```

### Seed everything (users + likes + matches + chat previews)

```
CURRENT_USER_ID=<your-uid> node phase8_1_seoul_seed.js --confirm phase8_1_seoul_001 --seed-incoming-likes --seed-existing-matches --seed-chat-previews
```

### Cleanup dry-run

```
node phase8_1_seoul_cleanup.js --dry-run
```

### Cleanup (delete all seed data)

```
node phase8_1_seoul_cleanup.js --confirm phase8_1_seoul_001
```

---

## PowerShell equivalents (Windows)

```powershell
# Dry-run
node phase8_1_seoul_seed.js --dry-run

# Users only
node phase8_1_seoul_seed.js --confirm phase8_1_seoul_001

# Users + incoming likes
$env:CURRENT_USER_ID = "<your-uid>"
node phase8_1_seoul_seed.js --confirm phase8_1_seoul_001 --seed-incoming-likes

# Users + likes + matches
$env:CURRENT_USER_ID = "<your-uid>"
node phase8_1_seoul_seed.js --confirm phase8_1_seoul_001 --seed-incoming-likes --seed-existing-matches

# Users + likes + matches + chat previews
$env:CURRENT_USER_ID = "<your-uid>"
node phase8_1_seoul_seed.js --confirm phase8_1_seoul_001 --seed-incoming-likes --seed-existing-matches --seed-chat-previews

# Full seed
$env:CURRENT_USER_ID = "<your-uid>"
node phase8_1_seoul_seed.js --confirm phase8_1_seoul_001 --seed-incoming-likes --seed-existing-matches --seed-passes --seed-chat-previews

# Cleanup
node phase8_1_seoul_cleanup.js --confirm phase8_1_seoul_001
```

---

## What gets created

### Always (100 users)

| Collection | Document path | Count |
|---|---|---|
| `users` | `users/test_seoul_001` – `users/test_seoul_100` | 100 |
| `users/.../private/location` | `users/{id}/private/location` | 100 |
| RTDB | `status/test_seoul_001` – `status/test_seoul_100` | 100 (if DATABASE_URL set) |
| `test_seed_batches` | `test_seed_batches/phase8_1_seoul_001` | 1 |

### With `--seed-incoming-likes` + `CURRENT_USER_ID`

Creates 30 likes **from** test users **to** your UID. When you like them back in the app, the Cloud Function creates a real match.

| Slot | Test user IDs | Like type |
|---|---|---|
| Incoming like | `test_seoul_001` – `test_seoul_024` | `like` |
| Incoming super like | `test_seoul_025` – `test_seoul_030` | `super_like` |

### With `--seed-existing-matches` + `CURRENT_USER_ID`

Creates 5 pre-built match documents between your UID and test users 031–035. These appear immediately in the Phase 8.1 Messages tab.

| Slot | Test user IDs |
|---|---|
| Existing matches | `test_seoul_031` – `test_seoul_035` |

### With `--seed-passes` + `CURRENT_USER_ID`

Creates 5 pass records under `users/{CURRENT_USER_ID}/passes/`. Passed users are excluded from discovery by the app.

| Slot | Test user IDs |
|---|---|
| Passes | `test_seoul_036` – `test_seoul_040` |

### With `--seed-chat-previews` + `--seed-existing-matches` + `CURRENT_USER_ID`

Populates `lastMessagePreview` and `lastMessageAt` on the 5 seeded match documents. The Phase 8.1 conversation list displays this preview text. No `messages` subcollection entries are created — Phase 8.1 only reads `lastMessagePreview` from the match document.

---

## User data summary

| Field | Values |
|---|---|
| `id` | `test_seoul_001` – `test_seoul_100` |
| `email` | `test_seoul_NNN@bloomtest.invalid` |
| `nickname` | `SeoulTest001` – `SeoulTest100` |
| `age` | 20–45 (cycling) |
| `identity` | All 11 app values; weighted Gay ×20, Lesbian ×15, Bisexual ×15, etc. |
| `relationshipGoal` | All 5 app values; 20 users each |
| `interests` | 3–7 per user from the 24 app interest values |
| `verificationLevel` | ~10% `government_id`, ~30% `photo`, ~60% `none` |
| `premium` | ~20% `true`, ~80% `false` |
| `accountStatus` | `active` (all) |
| `profileVisibility` | `public` (all) |
| `isOnline` | `true` (all) |
| `city` | Seoul neighborhoods + Bundang/Gimpo metro area |
| `geoHash` | 5-char precision, same algorithm as `GeoHashUtils.dart` |
| `profileImages` | 1–3 HTTPS placehold.co placeholder URLs |
| `bio` | `Bloom Seoul test profile NNN. [safe descriptive text]` |
| `isTestUser` | `true` (test marker, ignored by UserModel.fromJson) |
| `testSeedBatch` | `phase8_1_seoul_001` |

---

## Coordinate distribution

20 Seoul neighborhoods, 5 users each, with ±400 m deterministic jitter per user:

| Neighborhood | Base lat/lng |
|---|---|
| Gangnam | 37.4979, 127.0276 |
| Yeoksam | 37.5004, 127.0360 |
| Jamsil | 37.5133, 127.1000 |
| Hongdae | 37.5563, 126.9236 |
| Sinchon | 37.5552, 126.9368 |
| Mapo | 37.5583, 126.9095 |
| Yeouido | 37.5219, 126.9245 |
| Jongno | 37.5720, 126.9793 |
| Euljiro | 37.5662, 126.9908 |
| Itaewon | 37.5350, 126.9945 |
| Yongsan | 37.5327, 126.9651 |
| Seongsu | 37.5444, 127.0560 |
| Konkuk | 37.5402, 127.0717 |
| Wangsimni | 37.5606, 127.0374 |
| Nowon | 37.6543, 127.0570 |
| Gwanak | 37.4764, 126.9522 |
| Sadang | 37.4786, 126.9813 |
| Mokdong | 37.5270, 126.8747 |
| Gimpo metro | 37.5579, 126.7993 |
| Bundang metro | 37.3797, 127.1187 |

Exact coordinates stored in `users/{id}/private/location` (GeoPoint). Only `geoHash` is on the public user document.

---

## Firebase Console verification after seeding

1. **Firestore → users → test_seoul_001**: confirm `geoHash`, `isOnline: true`, `accountStatus: active`, `isTestUser: true`
2. **Firestore → users → test_seoul_001 → private → location**: confirm GeoPoint is present
3. **Firestore → test_seed_batches → phase8_1_seoul_001**: confirms the batch metadata
4. **Realtime Database → status → test_seoul_001**: confirm `isOnline: true` (if DATABASE_URL was set)
5. **App — Discovery**: seed users should appear in the discovery feed (they are `public` + `active`)
6. **App — Messages tab** (Phase 8.1): if `--seed-existing-matches` was used, 5 conversations appear
7. **App — Like back**: like any of `test_seoul_001`–`test_seoul_030` to trigger the Cloud Function match

---

## Cleanup

The cleanup script deletes by deterministic ID range — it does **not** query by `testSeedBatch` field, so no extra Firestore index is required.

```
node phase8_1_seoul_cleanup.js --dry-run    # preview
node phase8_1_seoul_cleanup.js --confirm phase8_1_seoul_001  # execute
```

What gets deleted:
- `users/test_seoul_001` through `users/test_seoul_100`
- All `users/{id}/private/*` documents
- All `users/{id}/passes/*` documents
- All `users/{id}/blocks/*` documents
- All `likes` where `fromUserId` or `toUserId` is any `test_seoul_*`
- All `matches` where `users[]` contains any `test_seoul_*` (+ `messages` subcollection)
- RTDB `status/test_seoul_*`
- `test_seed_batches/phase8_1_seoul_001`

What is NOT deleted:
- Any document not matching the above patterns
- Real user documents
- Likes or matches not involving `test_seoul_*` IDs

---

## Re-seeding

The seed script uses `set()` (not `create()`), so running it again overwrites existing seed data cleanly. No cleanup required before re-running.

---

## Environment variable reference

| Variable | Required | Description |
|---|---|---|
| `SERVICE_ACCOUNT_PATH` | Optional | Absolute path to Firebase service account JSON. If not set, uses Application Default Credentials. |
| `FIREBASE_DATABASE_URL` | Optional | RTDB URL. If not set, RTDB presence seeding is skipped. |
| `CURRENT_USER_ID` | Required for like/match/pass flags | Firebase Auth UID of the test user (you) |
