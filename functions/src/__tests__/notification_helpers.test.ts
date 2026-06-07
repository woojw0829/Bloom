import {
  isValidNotificationType,
  makeMatchNotificationId,
  makeMessageNotificationId,
  makeLikeNotificationId,
  buildMessageBody,
  buildLikeBody,
} from "../notification_helpers";

// ── isValidNotificationType ───────────────────────────────────────────────────

describe("isValidNotificationType", () => {
  test('accepts "like"', () => {
    expect(isValidNotificationType("like")).toBe(true);
  });

  test('accepts "match"', () => {
    expect(isValidNotificationType("match")).toBe(true);
  });

  test('accepts "message"', () => {
    expect(isValidNotificationType("message")).toBe(true);
  });

  test('accepts "verification"', () => {
    expect(isValidNotificationType("verification")).toBe(true);
  });

  test("rejects unknown string", () => {
    expect(isValidNotificationType("unknown")).toBe(false);
  });

  test("rejects empty string", () => {
    expect(isValidNotificationType("")).toBe(false);
  });

  test("rejects null", () => {
    expect(isValidNotificationType(null)).toBe(false);
  });

  test("rejects undefined", () => {
    expect(isValidNotificationType(undefined)).toBe(false);
  });

  test("rejects number", () => {
    expect(isValidNotificationType(1)).toBe(false);
  });
});

// ── makeMatchNotificationId ───────────────────────────────────────────────────

describe("makeMatchNotificationId", () => {
  test("formats as match_{matchId}_{userId}", () => {
    expect(makeMatchNotificationId("m1", "u1")).toBe("match_m1_u1");
  });

  test("produces different IDs for different users on the same match", () => {
    expect(makeMatchNotificationId("m1", "u1")).not.toBe(
      makeMatchNotificationId("m1", "u2")
    );
  });

  test("produces different IDs for different matches for the same user", () => {
    expect(makeMatchNotificationId("m1", "u1")).not.toBe(
      makeMatchNotificationId("m2", "u1")
    );
  });

  test("is deterministic", () => {
    expect(makeMatchNotificationId("match123", "userABC")).toBe(
      makeMatchNotificationId("match123", "userABC")
    );
  });
});

// ── makeMessageNotificationId ─────────────────────────────────────────────────

describe("makeMessageNotificationId", () => {
  test("formats as message_{matchId}_{messageId}", () => {
    expect(makeMessageNotificationId("m1", "msg1")).toBe("message_m1_msg1");
  });

  test("produces different IDs for different message IDs", () => {
    expect(makeMessageNotificationId("m1", "msg1")).not.toBe(
      makeMessageNotificationId("m1", "msg2")
    );
  });

  test("is deterministic", () => {
    expect(makeMessageNotificationId("matchX", "msgY")).toBe(
      makeMessageNotificationId("matchX", "msgY")
    );
  });
});

// ── makeLikeNotificationId ────────────────────────────────────────────────────

describe("makeLikeNotificationId", () => {
  test("formats as like_{likeId}", () => {
    expect(makeLikeNotificationId("userA_userB")).toBe("like_userA_userB");
  });

  test("produces different IDs for different like IDs", () => {
    expect(makeLikeNotificationId("userA_userB")).not.toBe(
      makeLikeNotificationId("userA_userC")
    );
  });
});

// ── buildMessageBody ──────────────────────────────────────────────────────────

describe("buildMessageBody", () => {
  test("text message with sender name", () => {
    expect(buildMessageBody("Alex", false)).toBe("Alex sent you a message.");
  });

  test("image message with sender name", () => {
    expect(buildMessageBody("Alex", true)).toBe("Alex sent you a photo.");
  });

  test("text message without sender name falls back to generic", () => {
    expect(buildMessageBody("", false)).toBe("You have a new message.");
  });

  test("image message without sender name falls back to generic", () => {
    expect(buildMessageBody("", true)).toBe("You received a photo.");
  });

  test("whitespace-only sender name treated as missing", () => {
    expect(buildMessageBody("   ", false)).toBe("You have a new message.");
  });

  test("whitespace-only sender name treated as missing for image", () => {
    expect(buildMessageBody("   ", true)).toBe("You received a photo.");
  });
});

// ── buildLikeBody ─────────────────────────────────────────────────────────────

describe("buildLikeBody", () => {
  test("with sender name", () => {
    expect(buildLikeBody("Alex")).toBe("Alex liked you.");
  });

  test("without sender name falls back to generic", () => {
    expect(buildLikeBody("")).toBe("Someone liked you.");
  });

  test("whitespace-only name treated as missing", () => {
    expect(buildLikeBody("   ")).toBe("Someone liked you.");
  });
});
