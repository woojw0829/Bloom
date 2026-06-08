"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getVerificationImageSignedUrl = void 0;
const https_1 = require("firebase-functions/v2/https");
const firestore_1 = require("firebase-admin/firestore");
const storage_1 = require("firebase-admin/storage");
const verification_helpers_1 = require("./verification_helpers");
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
exports.getVerificationImageSignedUrl = (0, https_1.onCall)(async (request) => {
    if (!request.auth?.token?.["admin"]) {
        throw new https_1.HttpsError("permission-denied", "Admin access required.");
    }
    const { requestId } = (0, verification_helpers_1.validateSignedUrlRequest)(request.data);
    const db = (0, firestore_1.getFirestore)();
    const doc = await db
        .collection("verification_requests")
        .doc(requestId)
        .get();
    if (!doc.exists) {
        throw new https_1.HttpsError("not-found", "Verification request not found.");
    }
    const storagePath = (0, verification_helpers_1.extractSelfieStoragePath)(doc.data());
    const storage = (0, storage_1.getStorage)();
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
//# sourceMappingURL=get_verification_image_signed_url.js.map