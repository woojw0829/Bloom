"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.VERIFICATION_STORAGE_PATH_PREFIX = exports.SUPPORTED_IMAGE_TYPES = void 0;
exports.validateSignedUrlRequest = validateSignedUrlRequest;
exports.validateStoragePath = validateStoragePath;
exports.extractSelfieStoragePath = extractSelfieStoragePath;
const https_1 = require("firebase-functions/v2/https");
exports.SUPPORTED_IMAGE_TYPES = ["selfie"];
exports.VERIFICATION_STORAGE_PATH_PREFIX = "verification_requests/";
/**
 * Validates the raw callable request data for getVerificationImageSignedUrl.
 * Pure function — no Firebase SDK calls; fully testable without mocks.
 *
 * Throws HttpsError on invalid input so the caller can propagate it directly.
 */
function validateSignedUrlRequest(data) {
    if (data == null || typeof data !== "object") {
        throw new https_1.HttpsError("invalid-argument", "Request data must be an object.");
    }
    const { requestId, imageType } = data;
    if (typeof requestId !== "string" || requestId.trim() === "") {
        throw new https_1.HttpsError("invalid-argument", "requestId is required.");
    }
    if (imageType !== "selfie") {
        throw new https_1.HttpsError("invalid-argument", "Only 'selfie' imageType is supported for photo verification.");
    }
    return {
        requestId: requestId.trim(),
        imageType: imageType,
    };
}
/**
 * Validates that a Storage path is a legitimate verification selfie path.
 * Rejects paths that do not start with the expected prefix to prevent
 * admins from accidentally generating signed URLs for unrelated files.
 *
 * Pure function — no Firebase SDK calls; fully testable without mocks.
 */
function validateStoragePath(path) {
    if (typeof path !== "string" ||
        !path.startsWith(exports.VERIFICATION_STORAGE_PATH_PREFIX)) {
        throw new https_1.HttpsError("invalid-argument", "Invalid storage path for a verification selfie.");
    }
    return path;
}
/**
 * Validates that the Firestore document describes a photo verification request.
 * Returns the selfie storage path on success.
 * Throws HttpsError on any mismatch.
 */
function extractSelfieStoragePath(data) {
    if (data["verificationType"] !== "photo") {
        throw new https_1.HttpsError("invalid-argument", "Only photo verification requests are supported in Task 12.3.");
    }
    return validateStoragePath(data["selfieImageUrl"]);
}
//# sourceMappingURL=verification_helpers.js.map