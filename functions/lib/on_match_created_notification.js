"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onMatchCreatedNotification = void 0;
const firestore_1 = require("firebase-functions/v2/firestore");
const notification_helpers_1 = require("./notification_helpers");
/**
 * Triggered when a new match document is created at matches/{matchId}.
 *
 * Creates one notification document per participant and sends a push
 * notification to each user whose FCM token is present and whose match
 * notifications are enabled.
 *
 * Uses deterministic notification IDs (match_{matchId}_{userId}) so retries
 * are idempotent — the set() call overwrites with the same data on re-runs.
 *
 * Does NOT modify the match document or any user document.
 * Does NOT send a like notification — that is handled by onLikeCreated.
 */
exports.onMatchCreatedNotification = (0, firestore_1.onDocumentCreated)("matches/{matchId}", async (event) => {
    const snapshot = event.data;
    if (!snapshot)
        return;
    const matchId = event.params.matchId;
    const data = snapshot.data();
    const users = data.users;
    if (!Array.isArray(users) || users.length < 2)
        return;
    const participantIds = users.filter((u) => typeof u === "string" && u.trim() !== "");
    if (participantIds.length < 2)
        return;
    await Promise.all(participantIds.map((userId) => (0, notification_helpers_1.createAndSendNotification)({
        notificationId: (0, notification_helpers_1.makeMatchNotificationId)(matchId, userId),
        userId,
        type: "match",
        title: "New match",
        body: "You have a new match.",
        referenceId: matchId,
        referenceType: "match",
    })));
});
//# sourceMappingURL=on_match_created_notification.js.map