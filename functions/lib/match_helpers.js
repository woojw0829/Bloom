"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.VALID_LIKE_TYPES = void 0;
exports.makeMatchId = makeMatchId;
exports.makeReverseLikeId = makeReverseLikeId;
exports.isValidLikeType = isValidLikeType;
/**
 * Deterministic match document ID.
 *
 * Sorts the two user IDs lexicographically so the ID is identical regardless
 * of which user triggered the mutual-like check.
 *
 * Example: makeMatchId("userB", "userA") → "userA_userB"
 */
function makeMatchId(userA, userB) {
    const [first, second] = [userA, userB].sort();
    return `${first}_${second}`;
}
/**
 * Reverse-like document ID for a given like.
 *
 * A like from A→B has id "A_B". The reverse like (B→A) has id "B_A".
 */
function makeReverseLikeId(fromUserId, toUserId) {
    return `${toUserId}_${fromUserId}`;
}
exports.VALID_LIKE_TYPES = ["like", "super_like"];
/** Type guard — accepts both "like" and "super_like". */
function isValidLikeType(type) {
    return (typeof type === "string" &&
        exports.VALID_LIKE_TYPES.includes(type));
}
//# sourceMappingURL=match_helpers.js.map