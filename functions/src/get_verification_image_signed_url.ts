import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getFirestore } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";
import {
  validateSignedUrlRequest,
  extractSelfieStoragePath,
} from "./verification_helpers";

// Signed URLs expire after 5 minutes. Short-lived to limit exposure if a URL
// is inadvertently logged or cached beyond the intended admin session.
const SIGNED_URL_TTL_MS = 5 * 60 * 1000;

/**
 * Admin-only callable function that returns a short-lived signed URL for a
 * photo verification selfie image stored in Firebase Storage.
 *
 * Authorization: requires the 'admin' Firebase Custom Claim.
 * Scope: photo verification only (verificationType == 'photo').
 * Image type: selfie only (imageType == 'selfie').
 *
 * Input:  { requestId: string, imageType: 'selfie' }
 * Output: { url: string, expiresAt: number }
 *
 * The signed URL is not logged to prevent accidental exposure.
 */
export const getVerificationImageSignedUrl = onCall<Record<string, unknown>>(async (request) => {
  if (!request.auth?.token?.["admin"]) {
    throw new HttpsError("permission-denied", "Admin access required.");
  }

  const { requestId } = validateSignedUrlRequest(request.data);

  const db = getFirestore();
  const doc = await db
    .collection("verification_requests")
    .doc(requestId)
    .get();

  if (!doc.exists) {
    throw new HttpsError("not-found", "Verification request not found.");
  }

  const storagePath = extractSelfieStoragePath(
    doc.data() as Record<string, unknown>
  );

  const storage = getStorage();
  const bucket = storage.bucket();
  const file = bucket.file(storagePath);

  const expiresAt = Date.now() + SIGNED_URL_TTL_MS;
  const [url] = await file.getSignedUrl({
    action: "read",
    expires: expiresAt,
  });

  // Return url and expiry; never log the signed URL.
  return { url, expiresAt };
});
