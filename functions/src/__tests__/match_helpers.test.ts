import {
  makeMatchId,
  makeReverseLikeId,
  isValidLikeType,
} from "../match_helpers";

describe("makeMatchId", () => {
  test("sorts user IDs lexicographically", () => {
    expect(makeMatchId("userB", "userA")).toBe("userA_userB");
  });

  test("is deterministic regardless of argument order", () => {
    expect(makeMatchId("userA", "userB")).toBe(makeMatchId("userB", "userA"));
  });

  test("is stable when arguments are already in order", () => {
    expect(makeMatchId("userA", "userB")).toBe("userA_userB");
  });

  test("produces different IDs for different user pairs", () => {
    expect(makeMatchId("userA", "userB")).not.toBe(
      makeMatchId("userA", "userC")
    );
  });
});

describe("makeReverseLikeId", () => {
  test("returns toUserId_fromUserId", () => {
    expect(makeReverseLikeId("userA", "userB")).toBe("userB_userA");
  });

  test("is not symmetric", () => {
    expect(makeReverseLikeId("userA", "userB")).not.toBe(
      makeReverseLikeId("userB", "userA")
    );
  });

  test("reverse of reverse returns original like id", () => {
    expect(makeReverseLikeId("userB", "userA")).toBe("userA_userB");
  });
});

describe("isValidLikeType", () => {
  test('accepts "like"', () => {
    expect(isValidLikeType("like")).toBe(true);
  });

  test('accepts "super_like"', () => {
    expect(isValidLikeType("super_like")).toBe(true);
  });

  test('rejects "pass"', () => {
    expect(isValidLikeType("pass")).toBe(false);
  });

  test("rejects empty string", () => {
    expect(isValidLikeType("")).toBe(false);
  });

  test("rejects null", () => {
    expect(isValidLikeType(null)).toBe(false);
  });

  test("rejects undefined", () => {
    expect(isValidLikeType(undefined)).toBe(false);
  });

  test("rejects number", () => {
    expect(isValidLikeType(1)).toBe(false);
  });
});
