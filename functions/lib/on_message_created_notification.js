"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onMessageCreatedNotification = void 0;
const firestore_1 = require("firebase-functions/v2/firestore");
const firestore_2 = require("firebase-admin/firestore");
const notification_helpers_1 = require("./notification_helpers");
/**
 * Triggered when a new message document is created at
 * matches/{matchId}/messages/{messageId}.
 *
 * Sends a notification to the recipient (the participant who is not the sender).
 * Uses a deterministic notification ID (message_{matchId}_{messageId}) so
 * retries are idempotent.
 *
 * Guards:
 * - Soft-deleted messages are skipped (deleted === true on creation).
 * - Messages in inactive matches (match.active !== true) are skipped.
 * - The sender never receives their own message notification.
 *
 * Push body uses the sender's nickname when available; falls back to generic text.
 * Message content and imageUrl are never included in the push payload.
 *
 * Does NOT modify the match or message document.
 * Does NOT read private subcollections or location data.
 */
exports.onMessageCreatedNotification = (0, firestore_1.onDocumentCreated)("matches/{matchId}/messages/{messageId}", async (event) => {
    const snapshot = event.data;
    if (!snapshot)
        return;
    const { matchId, messageId } = event.params;
    const messageData = snapshot.data();
    const senderId = messageData.senderId;
    if (typeof senderId !== "string" || senderId.trim() === "")
        return;
    // Soft-deleted messages should not generate notifications.
    if (messageData.deleted === true)
        return;
    const db = (0, firestore_2.getFirestore)();
    const matchDoc = await db.collection("matches").doc(matchId).get();
    if (!matchDoc.exists)
        return;
    const matchData = matchDoc.data();
    // Do not notify on messages in inactive (unmatched) conversations.
    if (matchData.active !== true)
        return;
    const users = matchData.users;
    if (!Array.isArray(users) || users.length < 2)
        return;
    const recipientId = users.find((u) => typeof u === "string" && u !== senderId);
    if (!recipientId)
        return;
    const senderName = await (0, notification_helpers_1.getSenderNickname)(senderId);
    const isImage = messageData.type === "image";
    const body = (0, notification_helpers_1.buildMessageBody)(senderName, isImage);
    await (0, notification_helpers_1.createAndSendNotification)({
        notificationId: (0, notification_helpers_1.makeMessageNotificationId)(matchId, messageId),
        userId: recipientId,
        type: "message",
        title: "New message",
        body,
        referenceId: matchId,
        referenceType: "message",
    });
});
//# sourceMappingURL=on_message_created_notification.js.map