import { HttpsError } from "firebase-functions/v2/https";

export const SUPPORTED_IMAGE_TYPES = ["selfie"] as const;
export type VerificationImageType = (typeof SUPPORTED_IMAGE_TYPES)[number];

export const VERIFICATION_STORAGE_PATH_PREFIX = "verification_requests/";

/**
 * Validates the raw callable request data for getVerificationImageSignedUrl.
 * Pure function — no Firebase SDK calls; fully testable without mocks.
 *
 * Throws HttpsError on invalid input so the caller can propagate it directly.
 */
export function validateSignedUrlRequest(data: unknown): {
  requestId: string;
  imageType: VerificationImageType;
} {
  if (data == null || typeof data !== "object") {
    throw new HttpsError("invalid-argument", "Request data must be an object.");
  }

  const { requestId, imageType } = data as Record<string, unknown>;

  if (typeof requestId !== "string" || requestId.trim() === "") {
    throw new HttpsError("invalid-argument", "requestId is required.");
  }

  if (imageType !== "selfie") {
    throw new HttpsError(
      "invalid-argument",
      "Only 'selfie' imageType is supported for photo verification."
    );
  }

  return {
    requestId: requestId.trim(),
    imageType: imageType as VerificationImageType,
  };
}

/**
 * Validates that a Storage path is a legitimate verification selfie path.
 * Rejects paths that do not start with the expected prefix to prevent
 * admins from accidentally generating signed URLs for unrelated files.
 *
 * Pure function — no Firebase SDK calls; fully testable without mocks.
 */
export function validateStoragePath(path: unknown): string {
  if (
    typeof path !== "string" ||
    !path.startsWith(VERIFICATION_STORAGE_PATH_PREFIX)
  ) {
    throw new HttpsError(
      "invalid-argument",
      "Invalid storage path for a verification selfie."
    );
  }
  return path;
}

/**
 * Validates that the Firestore document describes a photo verification request.
 * Returns the selfie storage path on success.
 * Throws HttpsError on any mismatch.
 */
export function extractSelfieStoragePath(
  data: Record<string, unknown>
): string {
  if (data["verificationType"] !== "photo") {
    throw new HttpsError(
      "invalid-argument",
      "Only photo verification requests are supported in Task 12.3."
    );
  }

  return validateStoragePath(data["selfieImageUrl"]);
}
