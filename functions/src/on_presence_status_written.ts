import { onValueWritten } from "firebase-functions/v2/database";
import { getFirestore, FieldValue, Timestamp } from "firebase-admin/firestore";
import { isValidPresencePayload } from "./presence_helpers";

/**
 * Triggered on any write to status/{userId} in Realtime Database.
 *
 * Syncs isOnline and lastSeen to Firestore users/{userId} via a partial
 * set-with-merge so no other user fields are overwritten.
 *
 * Admin SDK bypasses Firestore security rules — no client rule changes needed.
 * Does NOT write notifications, modify profile data, or touch private location.
 */
export const onPresenceStatusWritten = onValueWritten(
  {
    ref: "status/{userId}",
    instance: "bloom-371e1-default-rtdb",
  },
  async (event) => {
    const userId = event.params.userId;
    if (!userId || userId.trim() === "") return;

    const db = getFirestore();
    const userRef = db.collection("users").doc(userId);
    const after = event.data.after;

    // Node deleted — mark user offline with server timestamp so Firestore
    // stays consistent even if the client never wrote an explicit offline state.
    if (!after.exists()) {
      await userRef.set(
        { isOnline: false, lastSeen: FieldValue.serverTimestamp() },
        { merge: true }
      );
      return;
    }

    const value = after.val() as unknown;
    if (!isValidPresencePayload(value)) return;

    // Partial update only — no other user fields are read or written.
    await userRef.set(
      {
        isOnline: value.isOnline,
        lastSeen: Timestamp.fromMillis(value.lastSeen),
      },
      { merge: true }
    );
  }
);
