import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import {
  makeMatchId,
  makeReverseLikeId,
  isValidLikeType,
} from "./match_helpers";
import {
  createAndSendNotification,
  makeLikeNotificationId,
  buildLikeBody,
  getSenderNickname,
} from "./notification_helpers";

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
export const onLikeCreated = onDocumentCreated(
  "likes/{likeId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const likeId = event.params.likeId;
    const data = snapshot.data();
    const fromUserId: unknown = data.fromUserId;
    const toUserId: unknown = data.toUserId;
    const type: unknown = data.type;

    // Validate required fields before any Firestore reads.
    if (typeof fromUserId !== "string" || fromUserId.trim() === "") return;
    if (typeof toUserId !== "string" || toUserId.trim() === "") return;
    if (fromUserId === toUserId) return;
    if (!isValidLikeType(type)) return;

    const db = getFirestore();

    // Check whether either user has blocked the other before doing anything.
    const [blockAB, blockBA] = await Promise.all([
      db.collection("users").doc(fromUserId).collection("blocks").doc(toUserId).get(),
      db.collection("users").doc(toUserId).collection("blocks").doc(fromUserId).get(),
    ]);
    if (blockAB.exists || blockBA.exists) return;

    // Check whether B already liked A (the reverse direction).
    const reverseLikeId = makeReverseLikeId(fromUserId, toUserId);
    const reverseLikeDoc = await db
      .collection("likes")
      .doc(reverseLikeId)
      .get();

    if (!reverseLikeDoc.exists) {
      // Non-mutual like — notify the recipient.
      // The match trigger (onMatchCreatedNotification) is not involved here.
      const senderName = await getSenderNickname(fromUserId);
      await createAndSendNotification({
        notificationId: makeLikeNotificationId(likeId),
        userId: toUserId,
        type: "like",
        title: "New like",
        body: buildLikeBody(senderName),
        referenceId: likeId,
        referenceType: "like",
      });
      return;
    }

    // Mutual like confirmed — create or verify the match document.
    // No like notification is sent; onMatchCreatedNotification handles both
    // participants' match notifications after the match doc is written.
    const matchId = makeMatchId(fromUserId, toUserId);
    const matchRef = db.collection("matches").doc(matchId);

    await db.runTransaction(async (tx) => {
      const matchDoc = await tx.get(matchRef);
      if (matchDoc.exists) return; // Already created; nothing to do.

      // Stable sorted user order, consistent with matchId.
      const sortedUsers = [fromUserId, toUserId].sort();

      tx.set(matchRef, {
        id: matchId,
        users: sortedUsers,
        compatibilityScore: 0,
        createdAt: FieldValue.serverTimestamp(),
        lastMessageAt: FieldValue.serverTimestamp(),
        lastMessagePreview: "",
        active: true,
      });
    });
  }
);
