/**
 * Deterministic match document ID.
 *
 * Sorts the two user IDs lexicographically so the ID is identical regardless
 * of which user triggered the mutual-like check.
 *
 * Example: makeMatchId("userB", "userA") → "userA_userB"
 */
export function makeMatchId(userA: string, userB: string): string {
  const [first, second] = [userA, userB].sort();
  return `${first}_${second}`;
}

/**
 * Reverse-like document ID for a given like.
 *
 * A like from A→B has id "A_B". The reverse like (B→A) has id "B_A".
 */
export function makeReverseLikeId(
  fromUserId: string,
  toUserId: string
): string {
  return `${toUserId}_${fromUserId}`;
}

export const VALID_LIKE_TYPES = ["like", "super_like"] as const;
export type LikeDocType = (typeof VALID_LIKE_TYPES)[number];

/** Type guard — accepts both "like" and "super_like". */
export function isValidLikeType(type: unknown): type is LikeDocType {
  return (
    typeof type === "string" &&
    (VALID_LIKE_TYPES as readonly string[]).includes(type)
  );
}
