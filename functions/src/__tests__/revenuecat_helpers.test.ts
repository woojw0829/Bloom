import {
  extractRevenueCatAuthorization,
  verifyRevenueCatAuthorizationHeader,
  parseRevenueCatEvent,
  isRevenueCatWebhookEventType,
  REVENUE_CAT_EVENT_TYPES,
} from "../revenuecat_helpers";

const SECRET = "test_webhook_authorization_secret";
const BODY = JSON.stringify({ event: { type: "RENEWAL", app_user_id: "uid123" } });

// ── extractRevenueCatAuthorization ────────────────────────────────────────────

describe("extractRevenueCatAuthorization", () => {
  test("returns the header value when present", () => {
    expect(
      extractRevenueCatAuthorization({ authorization: "my-secret" })
    ).toBe("my-secret");
  });

  test("returns first element when header is an array", () => {
    expect(
      extractRevenueCatAuthorization({ authorization: ["my-secret", "other"] })
    ).toBe("my-secret");
  });

  test("returns null when header is absent", () => {
    expect(extractRevenueCatAuthorization({})).toBeNull();
  });

  test("returns null when header is undefined", () => {
    expect(
      extractRevenueCatAuthorization({ authorization: undefined })
    ).toBeNull();
  });

  test("returns null when header is empty string", () => {
    expect(
      extractRevenueCatAuthorization({ authorization: "" })
    ).toBeNull();
  });

  test("does not read x-revenuecat-signature (uses authorization key)", () => {
    expect(
      extractRevenueCatAuthorization({ "x-revenuecat-signature": "sig_value" })
    ).toBeNull();
  });
});

// ── verifyRevenueCatAuthorizationHeader ───────────────────────────────────────

describe("verifyRevenueCatAuthorizationHeader", () => {
  test("returns true when authorizationHeader exactly matches expectedSecret", () => {
    expect(
      verifyRevenueCatAuthorizationHeader({
        authorizationHeader: SECRET,
        expectedSecret: SECRET,
      })
    ).toBe(true);
  });

  test("returns false when authorizationHeader does not match expectedSecret", () => {
    expect(
      verifyRevenueCatAuthorizationHeader({
        authorizationHeader: "wrong_secret",
        expectedSecret: SECRET,
      })
    ).toBe(false);
  });

  test("returns false when authorizationHeader is empty string", () => {
    expect(
      verifyRevenueCatAuthorizationHeader({
        authorizationHeader: "",
        expectedSecret: SECRET,
      })
    ).toBe(false);
  });

  test("returns false when expectedSecret is empty string", () => {
    expect(
      verifyRevenueCatAuthorizationHeader({
        authorizationHeader: SECRET,
        expectedSecret: "",
      })
    ).toBe(false);
  });

  test("returns false when authorizationHeader is shorter than expectedSecret", () => {
    expect(
      verifyRevenueCatAuthorizationHeader({
        authorizationHeader: SECRET.slice(0, -1),
        expectedSecret: SECRET,
      })
    ).toBe(false);
  });

  test("returns false when authorizationHeader is longer than expectedSecret", () => {
    expect(
      verifyRevenueCatAuthorizationHeader({
        authorizationHeader: SECRET + "x",
        expectedSecret: SECRET,
      })
    ).toBe(false);
  });

  test("does not throw for arbitrary byte values in inputs", () => {
    expect(() =>
      verifyRevenueCatAuthorizationHeader({
        authorizationHeader: "\x00\xffĀ",
        expectedSecret: "\x00\xffĀ",
      })
    ).not.toThrow();
  });
});

// ── parseRevenueCatEvent ──────────────────────────────────────────────────────

describe("parseRevenueCatEvent", () => {
  test("parses a valid JSON object", () => {
    const result = parseRevenueCatEvent(BODY);
    expect(result).toHaveProperty("event");
  });

  test("throws on non-JSON input", () => {
    expect(() => parseRevenueCatEvent("not json")).toThrow();
  });

  test("throws when root is a JSON array", () => {
    expect(() => parseRevenueCatEvent("[1,2,3]")).toThrow();
  });

  test("throws when root is a JSON string", () => {
    expect(() => parseRevenueCatEvent('"just a string"')).toThrow();
  });

  test("throws when root is null", () => {
    expect(() => parseRevenueCatEvent("null")).toThrow();
  });

  test("throws on empty string", () => {
    expect(() => parseRevenueCatEvent("")).toThrow();
  });
});

// ── isRevenueCatWebhookEventType ──────────────────────────────────────────────

describe("isRevenueCatWebhookEventType", () => {
  test("returns true for every known event type", () => {
    for (const type of REVENUE_CAT_EVENT_TYPES) {
      expect(isRevenueCatWebhookEventType(type)).toBe(true);
    }
  });

  test("returns false for unknown string", () => {
    expect(isRevenueCatWebhookEventType("UNKNOWN_EVENT")).toBe(false);
  });

  test("returns false for null", () => {
    expect(isRevenueCatWebhookEventType(null)).toBe(false);
  });

  test("returns false for number", () => {
    expect(isRevenueCatWebhookEventType(42)).toBe(false);
  });

  test("returns false for empty string", () => {
    expect(isRevenueCatWebhookEventType("")).toBe(false);
  });
});
