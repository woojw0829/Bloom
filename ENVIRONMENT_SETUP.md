# Environment Setup

This document explains how to configure secrets and environment variables for local development and production deployment of the Bloom Cloud Functions and Flutter app.

---

## Local environment file structure

| File | Purpose | Committed? |
|---|---|---|
| `.env` | Personal local memo — all values in one place. Never passed to Flutter. | ❌ gitignored |
| `.env.flutter.local` | Flutter runtime env — public SDK keys only. Used with `--dart-define-from-file`. | ❌ gitignored |
| `functions/.secret.local` | Local Cloud Functions secret for emulator testing. | ❌ gitignored |
| `.env.example` | Placeholder template for `.env`. | ✅ committed |
| `.env.flutter.example` | Placeholder template for `.env.flutter.local`. | ✅ committed |
| `functions/.env.example` | Placeholder template for `functions/.env`. | ✅ committed |
| `functions/.secret.example` | Placeholder template for `functions/.secret.local`. | ✅ committed |

---

## Secrets overview

| Secret / Variable | Where it lives (production) | Where it lives (local dev) | Used by |
|---|---|---|---|
| `REVENUECAT_WEBHOOK_SECRET` | Firebase Secret Manager | `functions/.secret.local` (gitignored) | `revenueCatWebhook` Cloud Function only |
| `REVENUECAT_IOS_API_KEY` | `--dart-define` at build time | `.env.flutter.local` via `--dart-define-from-file` | Flutter app (iOS/macOS) |
| `REVENUECAT_ANDROID_API_KEY` | `--dart-define` at build time | `.env.flutter.local` via `--dart-define-from-file` | Flutter app (Android) |

**Critical:** `REVENUECAT_WEBHOOK_SECRET` is a server-only secret. It must **never** appear in `.env.flutter.local` or be passed to Flutter via `--dart-define`.

---

## 1. Generate REVENUECAT_WEBHOOK_SECRET

The webhook secret is any strong random string. Use PowerShell to generate one:

```powershell
$bytes = New-Object byte[] 32
$rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
$rng.GetBytes($bytes)
[Convert]::ToBase64String($bytes)
```

This produces a 44-character base64 string. Copy the output — this is your secret. Do not share it and do not commit it.

---

## 2. Store the secret for local development

Create `functions/.secret.local` (this file is gitignored):

```
REVENUECAT_WEBHOOK_SECRET=<paste your generated secret here>
```

`functions/.secret.local` is read by the Firebase Local Emulator Suite for local testing. It is never deployed and must never be committed. See `functions/.secret.example` for the template.

---

## 3. Store the secret in Firebase Secret Manager (production)

Run this command once before deploying Cloud Functions:

```bash
firebase functions:secrets:set REVENUECAT_WEBHOOK_SECRET
```

Firebase CLI will prompt you to enter the secret value. Paste the same value you generated in step 1. The secret is stored encrypted in Google Cloud Secret Manager and is never written to disk or source control.

To verify the secret was stored:

```bash
firebase functions:secrets:access REVENUECAT_WEBHOOK_SECRET
```

---

## 4. Configure RevenueCat Dashboard Webhook Authorization

1. Open [RevenueCat Dashboard](https://app.revenuecat.com).
2. Select your project.
3. Go to **Integrations > Webhooks**.
4. Add or edit your webhook endpoint URL (your deployed Cloud Function URL).
5. In the **Authorization** field, paste the **same value** you stored as `REVENUECAT_WEBHOOK_SECRET`.
6. Save.

RevenueCat will send this value as the `Authorization` header with every webhook POST request. The Cloud Function verifies it using constant-time comparison before processing any payload.

---

## 5. Configure Flutter local environment

Create `.env.flutter.local` (this file is gitignored) by copying from the example:

```
cp .env.flutter.example .env.flutter.local
```

Then fill in the real public SDK keys obtained from:
**RevenueCat Dashboard > Project > Apps > (your app) > API keys**

```
REVENUECAT_IOS_API_KEY=appl_YOUR_PUBLIC_IOS_KEY
REVENUECAT_ANDROID_API_KEY=goog_YOUR_PUBLIC_ANDROID_KEY
```

⚠️ **Do not add `REVENUECAT_WEBHOOK_SECRET` to `.env.flutter.local`.** That secret is server-only.

⚠️ **Do not run Flutter with `--dart-define-from-file=.env`** if `.env` contains `REVENUECAT_WEBHOOK_SECRET`. Use `.env.flutter.local` instead, which contains only public SDK keys.

---

## 6. Run Flutter locally

Recommended command (Android emulator):

```bash
flutter run -d emulator-5554 --dart-define-from-file=.env.flutter.local
```

Run without keys (local dev — RevenueCat SDK stays unconfigured, no crash):

```bash
flutter run
```

---

## 7. Deploy Cloud Functions

Set the secret in Firebase Secret Manager first (step 3), then deploy:

```bash
firebase deploy --only functions
```

---

## Security notes

- `REVENUECAT_WEBHOOK_SECRET` is the expected value of the `Authorization` header. It is **not** an HMAC key — RevenueCat sends it verbatim. The Cloud Function compares it using constant-time comparison to prevent timing attacks.
- Never log the `Authorization` header or the raw webhook body.
- Never store `REVENUECAT_WEBHOOK_SECRET` in Flutter client code.
- Never commit `.env`, `.env.flutter.local`, `functions/.env`, `functions/.secret.local`, or any file containing a real secret.
- RevenueCat public SDK keys (`REVENUECAT_IOS_API_KEY`, `REVENUECAT_ANDROID_API_KEY`) are safe to include in compiled app binaries but should still not be hardcoded in source — use `--dart-define` so keys can be rotated without a code change.
- `REVENUECAT_WEBHOOK_SECRET` must match the Authorization value configured in the RevenueCat Dashboard Webhooks settings exactly.
