import { onDocumentCreated } from "firebase-functions/v2/firestore";
import {
  createAndSendNotification,
  makeMatchNotificationId,
} from "./notification_helpers";

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
export const onMatchCreatedNotification = onDocumentCreated(
  "matches/{matchId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const matchId = event.params.matchId;
    const data = snapshot.data();
    const users: unknown = data.users;

    if (!Array.isArray(users) || users.length < 2) return;

    const participantIds = users.filter(
      (u): u is string => typeof u === "string" && u.trim() !== ""
    );

    if (participantIds.length < 2) return;

    await Promise.all(
      participantIds.map((userId) =>
        createAndSendNotification({
          notificationId: makeMatchNotificationId(matchId, userId),
          userId,
          type: "match",
          title: "New match",
          body: "You have a new match.",
          referenceId: matchId,
          referenceType: "match",
        })
      )
    );
  }
);
