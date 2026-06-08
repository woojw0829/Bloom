"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const https_1 = require("firebase-functions/v2/https");
const verification_helpers_1 = require("../verification_helpers");
// ── validateSignedUrlRequest ──────────────────────────────────────────────────
describe("validateSignedUrlRequest", () => {
    test("accepts valid selfie request", () => {
        const result = (0, verification_helpers_1.validateSignedUrlRequest)({
            requestId: "req123",
            imageType: "selfie",
        });
        expect(result.requestId).toBe("req123");
        expect(result.imageType).toBe("selfie");
    });
    test("trims requestId whitespace", () => {
        const result = (0, verification_helpers_1.validateSignedUrlRequest)({
            requestId: "  req123  ",
            imageType: "selfie",
        });
        expect(result.requestId).toBe("req123");
    });
    test("throws invalid-argument when data is null", () => {
        expect(() => (0, verification_helpers_1.validateSignedUrlRequest)(null)).toThrow(https_1.HttpsError);
        try {
            (0, verification_helpers_1.validateSignedUrlRequest)(null);
        }
        catch (e) {
            expect(e.code).toBe("invalid-argument");
        }
    });
    test("throws invalid-argument when data is not an object", () => {
        expect(() => (0, verification_helpers_1.validateSignedUrlRequest)("string")).toThrow(https_1.HttpsError);
    });
    test("throws invalid-argument when requestId is missing", () => {
        expect(() => (0, verification_helpers_1.validateSignedUrlRequest)({ imageType: "selfie" })).toThrow(https_1.HttpsError);
    });
    test("throws invalid-argument when requestId is empty string", () => {
        expect(() => (0, verification_helpers_1.validateSignedUrlRequest)({ requestId: "", imageType: "selfie" })).toThrow(https_1.HttpsError);
    });
    test("throws invalid-argument when requestId is whitespace only", () => {
        expect(() => (0, verification_helpers_1.validateSignedUrlRequest)({ requestId: "   ", imageType: "selfie" })).toThrow(https_1.HttpsError);
    });
    test("throws invalid-argument when imageType is not selfie", () => {
        expect(() => (0, verification_helpers_1.validateSignedUrlRequest)({ requestId: "req1", imageType: "government_id" })).toThrow(https_1.HttpsError);
    });
    test("throws invalid-argument when imageType is missing", () => {
        expect(() => (0, verification_helpers_1.validateSignedUrlRequest)({ requestId: "req1" })).toThrow(https_1.HttpsError);
    });
    test("throws invalid-argument when imageType is arbitrary string", () => {
        expect(() => (0, verification_helpers_1.validateSignedUrlRequest)({ requestId: "req1", imageType: "photo" })).toThrow(https_1.HttpsError);
    });
    test("error code is invalid-argument for unsupported imageType", () => {
        try {
            (0, verification_helpers_1.validateSignedUrlRequest)({ requestId: "req1", imageType: "government_id" });
        }
        catch (e) {
            expect(e.code).toBe("invalid-argument");
        }
    });
});
// ── validateStoragePath ───────────────────────────────────────────────────────
describe("validateStoragePath", () => {
    test("accepts valid verification_requests path", () => {
        const path = "verification_requests/user1/req1/selfie.jpg";
        expect((0, verification_helpers_1.validateStoragePath)(path)).toBe(path);
    });
    test("throws for path not starting with prefix", () => {
        expect(() => (0, verification_helpers_1.validateStoragePath)("users/user1/photos/photo.jpg")).toThrow(https_1.HttpsError);
    });
    test("throws for empty string", () => {
        expect(() => (0, verification_helpers_1.validateStoragePath)("")).toThrow(https_1.HttpsError);
    });
    test("throws for non-string value", () => {
        expect(() => (0, verification_helpers_1.validateStoragePath)(null)).toThrow(https_1.HttpsError);
    });
    test("throws for number", () => {
        expect(() => (0, verification_helpers_1.validateStoragePath)(42)).toThrow(https_1.HttpsError);
    });
    test("VERIFICATION_STORAGE_PATH_PREFIX is correct", () => {
        expect(verification_helpers_1.VERIFICATION_STORAGE_PATH_PREFIX).toBe("verification_requests/");
    });
});
// ── extractSelfieStoragePath ──────────────────────────────────────────────────
describe("extractSelfieStoragePath", () => {
    test("extracts selfieImageUrl for photo verification request", () => {
        const data = {
            verificationType: "photo",
            selfieImageUrl: "verification_requests/user1/req1/selfie.jpg",
        };
        expect((0, verification_helpers_1.extractSelfieStoragePath)(data)).toBe("verification_requests/user1/req1/selfie.jpg");
    });
    test("throws invalid-argument for government_id verificationType", () => {
        const data = {
            verificationType: "government_id",
            selfieImageUrl: "verification_requests/user1/req1/selfie.jpg",
        };
        expect(() => (0, verification_helpers_1.extractSelfieStoragePath)(data)).toThrow(https_1.HttpsError);
        try {
            (0, verification_helpers_1.extractSelfieStoragePath)(data);
        }
        catch (e) {
            expect(e.code).toBe("invalid-argument");
        }
    });
    test("throws invalid-argument when selfieImageUrl is a download URL", () => {
        const data = {
            verificationType: "photo",
            selfieImageUrl: "https://firebasestorage.googleapis.com/v0/b/bucket/o/selfie.jpg",
        };
        expect(() => (0, verification_helpers_1.extractSelfieStoragePath)(data)).toThrow(https_1.HttpsError);
    });
    test("throws invalid-argument when selfieImageUrl is missing", () => {
        const data = { verificationType: "photo" };
        expect(() => (0, verification_helpers_1.extractSelfieStoragePath)(data)).toThrow(https_1.HttpsError);
    });
    test("throws invalid-argument for unknown verificationType", () => {
        const data = {
            verificationType: "unknown",
            selfieImageUrl: "verification_requests/user1/req1/selfie.jpg",
        };
        expect(() => (0, verification_helpers_1.extractSelfieStoragePath)(data)).toThrow(https_1.HttpsError);
    });
});
//# sourceMappingURL=verification_helpers.test.js.map