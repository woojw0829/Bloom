"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const notification_helpers_1 = require("../notification_helpers");
// ── isValidNotificationType ───────────────────────────────────────────────────
describe("isValidNotificationType", () => {
    test('accepts "like"', () => {
        expect((0, notification_helpers_1.isValidNotificationType)("like")).toBe(true);
    });
    test('accepts "match"', () => {
        expect((0, notification_helpers_1.isValidNotificationType)("match")).toBe(true);
    });
    test('accepts "message"', () => {
        expect((0, notification_helpers_1.isValidNotificationType)("message")).toBe(true);
    });
    test('accepts "verification"', () => {
        expect((0, notification_helpers_1.isValidNotificationType)("verification")).toBe(true);
    });
    test("rejects unknown string", () => {
        expect((0, notification_helpers_1.isValidNotificationType)("unknown")).toBe(false);
    });
    test("rejects empty string", () => {
        expect((0, notification_helpers_1.isValidNotificationType)("")).toBe(false);
    });
    test("rejects null", () => {
        expect((0, notification_helpers_1.isValidNotificationType)(null)).toBe(false);
    });
    test("rejects undefined", () => {
        expect((0, notification_helpers_1.isValidNotificationType)(undefined)).toBe(false);
    });
    test("rejects number", () => {
        expect((0, notification_helpers_1.isValidNotificationType)(1)).toBe(false);
    });
});
// ── makeMatchNotificationId ───────────────────────────────────────────────────
describe("makeMatchNotificationId", () => {
    test("formats as match_{matchId}_{userId}", () => {
        expect((0, notification_helpers_1.makeMatchNotificationId)("m1", "u1")).toBe("match_m1_u1");
    });
    test("produces different IDs for different users on the same match", () => {
        expect((0, notification_helpers_1.makeMatchNotificationId)("m1", "u1")).not.toBe((0, notification_helpers_1.makeMatchNotificationId)("m1", "u2"));
    });
    test("produces different IDs for different matches for the same user", () => {
        expect((0, notification_helpers_1.makeMatchNotificationId)("m1", "u1")).not.toBe((0, notification_helpers_1.makeMatchNotificationId)("m2", "u1"));
    });
    test("is deterministic", () => {
        expect((0, notification_helpers_1.makeMatchNotificationId)("match123", "userABC")).toBe((0, notification_helpers_1.makeMatchNotificationId)("match123", "userABC"));
    });
});
// ── makeMessageNotificationId ─────────────────────────────────────────────────
describe("makeMessageNotificationId", () => {
    test("formats as message_{matchId}_{messageId}", () => {
        expect((0, notification_helpers_1.makeMessageNotificationId)("m1", "msg1")).toBe("message_m1_msg1");
    });
    test("produces different IDs for different message IDs", () => {
        expect((0, notification_helpers_1.makeMessageNotificationId)("m1", "msg1")).not.toBe((0, notification_helpers_1.makeMessageNotificationId)("m1", "msg2"));
    });
    test("is deterministic", () => {
        expect((0, notification_helpers_1.makeMessageNotificationId)("matchX", "msgY")).toBe((0, notification_helpers_1.makeMessageNotificationId)("matchX", "msgY"));
    });
});
// ── makeLikeNotificationId ────────────────────────────────────────────────────
describe("makeLikeNotificationId", () => {
    test("formats as like_{likeId}", () => {
        expect((0, notification_helpers_1.makeLikeNotificationId)("userA_userB")).toBe("like_userA_userB");
    });
    test("produces different IDs for different like IDs", () => {
        expect((0, notification_helpers_1.makeLikeNotificationId)("userA_userB")).not.toBe((0, notification_helpers_1.makeLikeNotificationId)("userA_userC"));
    });
});
// ── buildMessageBody ──────────────────────────────────────────────────────────
describe("buildMessageBody", () => {
    test("text message with sender name", () => {
        expect((0, notification_helpers_1.buildMessageBody)("Alex", false)).toBe("Alex sent you a message.");
    });
    test("image message with sender name", () => {
        expect((0, notification_helpers_1.buildMessageBody)("Alex", true)).toBe("Alex sent you a photo.");
    });
    test("text message without sender name falls back to generic", () => {
        expect((0, notification_helpers_1.buildMessageBody)("", false)).toBe("You have a new message.");
    });
    test("image message without sender name falls back to generic", () => {
        expect((0, notification_helpers_1.buildMessageBody)("", true)).toBe("You received a photo.");
    });
    test("whitespace-only sender name treated as missing", () => {
        expect((0, notification_helpers_1.buildMessageBody)("   ", false)).toBe("You have a new message.");
    });
    test("whitespace-only sender name treated as missing for image", () => {
        expect((0, notification_helpers_1.buildMessageBody)("   ", true)).toBe("You received a photo.");
    });
});
// ── buildLikeBody ─────────────────────────────────────────────────────────────
describe("buildLikeBody", () => {
    test("with sender name", () => {
        expect((0, notification_helpers_1.buildLikeBody)("Alex")).toBe("Alex liked you.");
    });
    test("without sender name falls back to generic", () => {
        expect((0, notification_helpers_1.buildLikeBody)("")).toBe("Someone liked you.");
    });
    test("whitespace-only name treated as missing", () => {
        expect((0, notification_helpers_1.buildLikeBody)("   ")).toBe("Someone liked you.");
    });
});
//# sourceMappingURL=notification_helpers.test.js.map