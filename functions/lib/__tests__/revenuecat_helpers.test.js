"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const revenuecat_helpers_1 = require("../revenuecat_helpers");
const SECRET = "test_webhook_authorization_secret";
const BODY = JSON.stringify({ event: { type: "RENEWAL", app_user_id: "uid123" } });
// ── extractRevenueCatAuthorization ────────────────────────────────────────────
describe("extractRevenueCatAuthorization", () => {
    test("returns the header value when present", () => {
        expect((0, revenuecat_helpers_1.extractRevenueCatAuthorization)({ authorization: "my-secret" })).toBe("my-secret");
    });
    test("returns first element when header is an array", () => {
        expect((0, revenuecat_helpers_1.extractRevenueCatAuthorization)({ authorization: ["my-secret", "other"] })).toBe("my-secret");
    });
    test("returns null when header is absent", () => {
        expect((0, revenuecat_helpers_1.extractRevenueCatAuthorization)({})).toBeNull();
    });
    test("returns null when header is undefined", () => {
        expect((0, revenuecat_helpers_1.extractRevenueCatAuthorization)({ authorization: undefined })).toBeNull();
    });
    test("returns null when header is empty string", () => {
        expect((0, revenuecat_helpers_1.extractRevenueCatAuthorization)({ authorization: "" })).toBeNull();
    });
    test("does not read x-revenuecat-signature (uses authorization key)", () => {
        expect((0, revenuecat_helpers_1.extractRevenueCatAuthorization)({ "x-revenuecat-signature": "sig_value" })).toBeNull();
    });
});
// ── verifyRevenueCatAuthorizationHeader ───────────────────────────────────────
describe("verifyRevenueCatAuthorizationHeader", () => {
    test("returns true when authorizationHeader exactly matches expectedSecret", () => {
        expect((0, revenuecat_helpers_1.verifyRevenueCatAuthorizationHeader)({
            authorizationHeader: SECRET,
            expectedSecret: SECRET,
        })).toBe(true);
    });
    test("returns false when authorizationHeader does not match expectedSecret", () => {
        expect((0, revenuecat_helpers_1.verifyRevenueCatAuthorizationHeader)({
            authorizationHeader: "wrong_secret",
            expectedSecret: SECRET,
        })).toBe(false);
    });
    test("returns false when authorizationHeader is empty string", () => {
        expect((0, revenuecat_helpers_1.verifyRevenueCatAuthorizationHeader)({
            authorizationHeader: "",
            expectedSecret: SECRET,
        })).toBe(false);
    });
    test("returns false when expectedSecret is empty string", () => {
        expect((0, revenuecat_helpers_1.verifyRevenueCatAuthorizationHeader)({
            authorizationHeader: SECRET,
            expectedSecret: "",
        })).toBe(false);
    });
    test("returns false when authorizationHeader is shorter than expectedSecret", () => {
        expect((0, revenuecat_helpers_1.verifyRevenueCatAuthorizationHeader)({
            authorizationHeader: SECRET.slice(0, -1),
            expectedSecret: SECRET,
        })).toBe(false);
    });
    test("returns false when authorizationHeader is longer than expectedSecret", () => {
        expect((0, revenuecat_helpers_1.verifyRevenueCatAuthorizationHeader)({
            authorizationHeader: SECRET + "x",
            expectedSecret: SECRET,
        })).toBe(false);
    });
    test("does not throw for arbitrary byte values in inputs", () => {
        expect(() => (0, revenuecat_helpers_1.verifyRevenueCatAuthorizationHeader)({
            authorizationHeader: "\x00\xffĀ",
            expectedSecret: "\x00\xffĀ",
        })).not.toThrow();
    });
});
// ── parseRevenueCatEvent ──────────────────────────────────────────────────────
describe("parseRevenueCatEvent", () => {
    test("parses a valid JSON object", () => {
        const result = (0, revenuecat_helpers_1.parseRevenueCatEvent)(BODY);
        expect(result).toHaveProperty("event");
    });
    test("throws on non-JSON input", () => {
        expect(() => (0, revenuecat_helpers_1.parseRevenueCatEvent)("not json")).toThrow();
    });
    test("throws when root is a JSON array", () => {
        expect(() => (0, revenuecat_helpers_1.parseRevenueCatEvent)("[1,2,3]")).toThrow();
    });
    test("throws when root is a JSON string", () => {
        expect(() => (0, revenuecat_helpers_1.parseRevenueCatEvent)('"just a string"')).toThrow();
    });
    test("throws when root is null", () => {
        expect(() => (0, revenuecat_helpers_1.parseRevenueCatEvent)("null")).toThrow();
    });
    test("throws on empty string", () => {
        expect(() => (0, revenuecat_helpers_1.parseRevenueCatEvent)("")).toThrow();
    });
});
// ── isRevenueCatWebhookEventType ──────────────────────────────────────────────
describe("isRevenueCatWebhookEventType", () => {
    test("returns true for every known event type", () => {
        for (const type of revenuecat_helpers_1.REVENUE_CAT_EVENT_TYPES) {
            expect((0, revenuecat_helpers_1.isRevenueCatWebhookEventType)(type)).toBe(true);
        }
    });
    test("returns false for unknown string", () => {
        expect((0, revenuecat_helpers_1.isRevenueCatWebhookEventType)("UNKNOWN_EVENT")).toBe(false);
    });
    test("returns false for null", () => {
        expect((0, revenuecat_helpers_1.isRevenueCatWebhookEventType)(null)).toBe(false);
    });
    test("returns false for number", () => {
        expect((0, revenuecat_helpers_1.isRevenueCatWebhookEventType)(42)).toBe(false);
    });
    test("returns false for empty string", () => {
        expect((0, revenuecat_helpers_1.isRevenueCatWebhookEventType)("")).toBe(false);
    });
});
//# sourceMappingURL=revenuecat_helpers.test.js.map