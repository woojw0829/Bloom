import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { getFirestore } from "firebase-admin/firestore";
import {
  createAndSendNotification,
  makeMessageNotificationId,
  buildMessageBody,
  getSenderNickname,
} from "./notification_helpers";

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
export const onMessageCreatedNotification = onDocumentCreated(
  "matches/{matchId}/messages/{messageId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const { matchId, messageId } = event.params;
    const messageData = snapshot.data();

    const senderId: unknown = messageData.senderId;
    if (typeof senderId !== "string" || senderId.trim() === "") return;

    // Soft-deleted messages should not generate notifications.
    if (messageData.deleted === true) return;

    const db = getFirestore();

    const matchDoc = await db.collection("matches").doc(matchId).get();
    if (!matchDoc.exists) return;

    const matchData = matchDoc.data()!;

    // Do not notify on messages in inactive (unmatched) conversations.
    if (matchData.active !== true) return;

    const users: unknown = matchData.users;
    if (!Array.isArray(users) || users.length < 2) return;

    const recipientId = users.find(
      (u): u is string => typeof u === "string" && u !== senderId
    );
    if (!recipientId) return;

    const senderName = await getSenderNickname(senderId);
    const isImage = messageData.type === "image";
    const body = buildMessageBody(senderName, isImage);

    await createAndSendNotification({
      notificationId: makeMessageNotificationId(matchId, messageId),
      userId: recipientId,
      type: "message",
      title: "New message",
      body,
      referenceId: matchId,
      referenceType: "message",
    });
  }
);
