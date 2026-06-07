"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onLikeCreated = void 0;
const firestore_1 = require("firebase-functions/v2/firestore");
const firestore_2 = require("firebase-admin/firestore");
const match_helpers_1 = require("./match_helpers");
const notification_helpers_1 = require("./notification_helpers");
/**
 * Triggered when a new like document is created at likes/{likeId}.
 *
 * Checks whether the reverse like already exists:
 * - No reverse like: sends a like notification to the recipient, then returns.
 * - Mutual like: creates a match document (inside a transaction to prevent
 *   duplicates). No like notification is sent — the onMatchCreatedNotification
 *   trigger handles match notifications for both participants.
 *
 * Does NOT write messages or modify any user document.
 */
exports.onLikeCreated = (0, firestore_1.onDocumentCreated)("likes/{likeId}", async (event) => {
    const snapshot = event.data;
    if (!snapshot)
        return;
    const likeId = event.params.likeId;
    const data = snapshot.data();
    const fromUserId = data.fromUserId;
    const toUserId = data.toUserId;
    const type = data.type;
    // Validate required fields before any Firestore reads.
    if (typeof fromUserId !== "string" || fromUserId.trim() === "")
        return;
    if (typeof toUserId !== "string" || toUserId.trim() === "")
        return;
    if (fromUserId === toUserId)
        return;
    if (!(0, match_helpers_1.isValidLikeType)(type))
        return;
    const db = (0, firestore_2.getFirestore)();
    // Check whether either user has blocked the other before doing anything.
    const [blockAB, blockBA] = await Promise.all([
        db.collection("users").doc(fromUserId).collection("blocks").doc(toUserId).get(),
        db.collection("users").doc(toUserId).collection("blocks").doc(fromUserId).get(),
    ]);
    if (blockAB.exists || blockBA.exists)
        return;
    // Check whether B already liked A (the reverse direction).
    const reverseLikeId = (0, match_helpers_1.makeReverseLikeId)(fromUserId, toUserId);
    const reverseLikeDoc = await db
        .collection("likes")
        .doc(reverseLikeId)
        .get();
    if (!reverseLikeDoc.exists) {
        // Non-mutual like — notify the recipient.
        // The match trigger (onMatchCreatedNotification) is not involved here.
        const senderName = await (0, notification_helpers_1.getSenderNickname)(fromUserId);
        await (0, notification_helpers_1.createAndSendNotification)({
            notificationId: (0, notification_helpers_1.makeLikeNotificationId)(likeId),
            userId: toUserId,
            type: "like",
            title: "New like",
            body: (0, notification_helpers_1.buildLikeBody)(senderName),
            referenceId: likeId,
            referenceType: "like",
        });
        return;
    }
    // Mutual like confirmed — create or verify the match document.
    // No like notification is sent; onMatchCreatedNotification handles both
    // participants' match notifications after the match doc is written.
    const matchId = (0, match_helpers_1.makeMatchId)(fromUserId, toUserId);
    const matchRef = db.collection("matches").doc(matchId);
    await db.runTransaction(async (tx) => {
        const matchDoc = await tx.get(matchRef);
        if (matchDoc.exists)
            return; // Already created; nothing to do.
        // Stable sorted user order, consistent with matchId.
        const sortedUsers = [fromUserId, toUserId].sort();
        tx.set(matchRef, {
            id: matchId,
            users: sortedUsers,
            compatibilityScore: 0,
            createdAt: firestore_2.FieldValue.serverTimestamp(),
            lastMessageAt: firestore_2.FieldValue.serverTimestamp(),
            lastMessagePreview: "",
            active: true,
        });
    });
});
//# sourceMappingURL=on_like_created.js.map