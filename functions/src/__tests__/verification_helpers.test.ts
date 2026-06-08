import { HttpsError } from "firebase-functions/v2/https";
import {
  validateSignedUrlRequest,
  validateStoragePath,
  extractSelfieStoragePath,
  VERIFICATION_STORAGE_PATH_PREFIX,
} from "../verification_helpers";

// ── validateSignedUrlRequest ──────────────────────────────────────────────────

describe("validateSignedUrlRequest", () => {
  test("accepts valid selfie request", () => {
    const result = validateSignedUrlRequest({
      requestId: "req123",
      imageType: "selfie",
    });
    expect(result.requestId).toBe("req123");
    expect(result.imageType).toBe("selfie");
  });

  test("trims requestId whitespace", () => {
    const result = validateSignedUrlRequest({
      requestId: "  req123  ",
      imageType: "selfie",
    });
    expect(result.requestId).toBe("req123");
  });

  test("throws invalid-argument when data is null", () => {
    expect(() => validateSignedUrlRequest(null)).toThrow(HttpsError);
    try {
      validateSignedUrlRequest(null);
    } catch (e) {
      expect((e as HttpsError).code).toBe("invalid-argument");
    }
  });

  test("throws invalid-argument when data is not an object", () => {
    expect(() => validateSignedUrlRequest("string")).toThrow(HttpsError);
  });

  test("throws invalid-argument when requestId is missing", () => {
    expect(() =>
      validateSignedUrlRequest({ imageType: "selfie" })
    ).toThrow(HttpsError);
  });

  test("throws invalid-argument when requestId is empty string", () => {
    expect(() =>
      validateSignedUrlRequest({ requestId: "", imageType: "selfie" })
    ).toThrow(HttpsError);
  });

  test("throws invalid-argument when requestId is whitespace only", () => {
    expect(() =>
      validateSignedUrlRequest({ requestId: "   ", imageType: "selfie" })
    ).toThrow(HttpsError);
  });

  test("throws invalid-argument when imageType is not selfie", () => {
    expect(() =>
      validateSignedUrlRequest({ requestId: "req1", imageType: "government_id" })
    ).toThrow(HttpsError);
  });

  test("throws invalid-argument when imageType is missing", () => {
    expect(() =>
      validateSignedUrlRequest({ requestId: "req1" })
    ).toThrow(HttpsError);
  });

  test("throws invalid-argument when imageType is arbitrary string", () => {
    expect(() =>
      validateSignedUrlRequest({ requestId: "req1", imageType: "photo" })
    ).toThrow(HttpsError);
  });

  test("error code is invalid-argument for unsupported imageType", () => {
    try {
      validateSignedUrlRequest({ requestId: "req1", imageType: "government_id" });
    } catch (e) {
      expect((e as HttpsError).code).toBe("invalid-argument");
    }
  });
});

// ── validateStoragePath ───────────────────────────────────────────────────────

describe("validateStoragePath", () => {
  test("accepts valid verification_requests path", () => {
    const path = "verification_requests/user1/req1/selfie.jpg";
    expect(validateStoragePath(path)).toBe(path);
  });

  test("throws for path not starting with prefix", () => {
    expect(() => validateStoragePath("users/user1/photos/photo.jpg")).toThrow(
      HttpsError
    );
  });

  test("throws for empty string", () => {
    expect(() => validateStoragePath("")).toThrow(HttpsError);
  });

  test("throws for non-string value", () => {
    expect(() => validateStoragePath(null)).toThrow(HttpsError);
  });

  test("throws for number", () => {
    expect(() => validateStoragePath(42)).toThrow(HttpsError);
  });

  test("VERIFICATION_STORAGE_PATH_PREFIX is correct", () => {
    expect(VERIFICATION_STORAGE_PATH_PREFIX).toBe("verification_requests/");
  });
});

// ── extractSelfieStoragePath ──────────────────────────────────────────────────

describe("extractSelfieStoragePath", () => {
  test("extracts selfieImageUrl for photo verification request", () => {
    const data = {
      verificationType: "photo",
      selfieImageUrl: "verification_requests/user1/req1/selfie.jpg",
    };
    expect(extractSelfieStoragePath(data)).toBe(
      "verification_requests/user1/req1/selfie.jpg"
    );
  });

  test("throws invalid-argument for government_id verificationType", () => {
    const data = {
      verificationType: "government_id",
      selfieImageUrl: "verification_requests/user1/req1/selfie.jpg",
    };
    expect(() => extractSelfieStoragePath(data)).toThrow(HttpsError);
    try {
      extractSelfieStoragePath(data);
    } catch (e) {
      expect((e as HttpsError).code).toBe("invalid-argument");
    }
  });

  test("throws invalid-argument when selfieImageUrl is a download URL", () => {
    const data = {
      verificationType: "photo",
      selfieImageUrl:
        "https://firebasestorage.googleapis.com/v0/b/bucket/o/selfie.jpg",
    };
    expect(() => extractSelfieStoragePath(data)).toThrow(HttpsError);
  });

  test("throws invalid-argument when selfieImageUrl is missing", () => {
    const data = { verificationType: "photo" };
    expect(() => extractSelfieStoragePath(data)).toThrow(HttpsError);
  });

  test("throws invalid-argument for unknown verificationType", () => {
    const data = {
      verificationType: "unknown",
      selfieImageUrl: "verification_requests/user1/req1/selfie.jpg",
    };
    expect(() => extractSelfieStoragePath(data)).toThrow(HttpsError);
  });
});
