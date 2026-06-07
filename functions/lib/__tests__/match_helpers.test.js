"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const match_helpers_1 = require("../match_helpers");
describe("makeMatchId", () => {
    test("sorts user IDs lexicographically", () => {
        expect((0, match_helpers_1.makeMatchId)("userB", "userA")).toBe("userA_userB");
    });
    test("is deterministic regardless of argument order", () => {
        expect((0, match_helpers_1.makeMatchId)("userA", "userB")).toBe((0, match_helpers_1.makeMatchId)("userB", "userA"));
    });
    test("is stable when arguments are already in order", () => {
        expect((0, match_helpers_1.makeMatchId)("userA", "userB")).toBe("userA_userB");
    });
    test("produces different IDs for different user pairs", () => {
        expect((0, match_helpers_1.makeMatchId)("userA", "userB")).not.toBe((0, match_helpers_1.makeMatchId)("userA", "userC"));
    });
});
describe("makeReverseLikeId", () => {
    test("returns toUserId_fromUserId", () => {
        expect((0, match_helpers_1.makeReverseLikeId)("userA", "userB")).toBe("userB_userA");
    });
    test("is not symmetric", () => {
        expect((0, match_helpers_1.makeReverseLikeId)("userA", "userB")).not.toBe((0, match_helpers_1.makeReverseLikeId)("userB", "userA"));
    });
    test("reverse of reverse returns original like id", () => {
        expect((0, match_helpers_1.makeReverseLikeId)("userB", "userA")).toBe("userA_userB");
    });
});
describe("isValidLikeType", () => {
    test('accepts "like"', () => {
        expect((0, match_helpers_1.isValidLikeType)("like")).toBe(true);
    });
    test('accepts "super_like"', () => {
        expect((0, match_helpers_1.isValidLikeType)("super_like")).toBe(true);
    });
    test('rejects "pass"', () => {
        expect((0, match_helpers_1.isValidLikeType)("pass")).toBe(false);
    });
    test("rejects empty string", () => {
        expect((0, match_helpers_1.isValidLikeType)("")).toBe(false);
    });
    test("rejects null", () => {
        expect((0, match_helpers_1.isValidLikeType)(null)).toBe(false);
    });
    test("rejects undefined", () => {
        expect((0, match_helpers_1.isValidLikeType)(undefined)).toBe(false);
    });
    test("rejects number", () => {
        expect((0, match_helpers_1.isValidLikeType)(1)).toBe(false);
    });
});
//# sourceMappingURL=match_helpers.test.js.map