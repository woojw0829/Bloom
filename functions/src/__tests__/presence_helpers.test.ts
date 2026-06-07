import { isValidPresencePayload } from "../presence_helpers";

describe("isValidPresencePayload", () => {
  test("valid payload with isOnline true and numeric lastSeen passes", () => {
    expect(isValidPresencePayload({ isOnline: true, lastSeen: 1234567890 })).toBe(true);
  });

  test("valid payload with isOnline false and numeric lastSeen passes", () => {
    expect(isValidPresencePayload({ isOnline: false, lastSeen: 0 })).toBe(true);
  });

  test("missing isOnline is invalid", () => {
    expect(isValidPresencePayload({ lastSeen: 1234567890 })).toBe(false);
  });

  test("non-boolean isOnline is invalid", () => {
    expect(isValidPresencePayload({ isOnline: "true", lastSeen: 1234567890 })).toBe(false);
  });

  test("missing lastSeen is invalid", () => {
    expect(isValidPresencePayload({ isOnline: true })).toBe(false);
  });

  test("non-number lastSeen is invalid", () => {
    expect(isValidPresencePayload({ isOnline: true, lastSeen: "1234" })).toBe(false);
  });

  test("null is invalid", () => {
    expect(isValidPresencePayload(null)).toBe(false);
  });

  test("non-object value is invalid", () => {
    expect(isValidPresencePayload("presence")).toBe(false);
  });

  test("extra fields alongside valid fields are still valid", () => {
    expect(
      isValidPresencePayload({ isOnline: true, lastSeen: 100, extra: "ignored" })
    ).toBe(true);
  });
});
