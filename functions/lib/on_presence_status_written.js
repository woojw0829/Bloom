"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onPresenceStatusWritten = void 0;
const database_1 = require("firebase-functions/v2/database");
const firestore_1 = require("firebase-admin/firestore");
const presence_helpers_1 = require("./presence_helpers");
/**
 * Triggered on any write to status/{userId} in Realtime Database.
 *
 * Syncs isOnline and lastSeen to Firestore users/{userId} via a partial
 * set-with-merge so no other user fields are overwritten.
 *
 * Admin SDK bypasses Firestore security rules — no client rule changes needed.
 * Does NOT write notifications, modify profile data, or touch private location.
 */
exports.onPresenceStatusWritten = (0, database_1.onValueWritten)({
    ref: "status/{userId}",
    instance: "bloom-371e1-default-rtdb",
}, async (event) => {
    const userId = event.params.userId;
    if (!userId || userId.trim() === "")
        return;
    const db = (0, firestore_1.getFirestore)();
    const userRef = db.collection("users").doc(userId);
    const after = event.data.after;
    // Node deleted — mark user offline with server timestamp so Firestore
    // stays consistent even if the client never wrote an explicit offline state.
    if (!after.exists()) {
        await userRef.set({ isOnline: false, lastSeen: firestore_1.FieldValue.serverTimestamp() }, { merge: true });
        return;
    }
    const value = after.val();
    if (!(0, presence_helpers_1.isValidPresencePayload)(value))
        return;
    // Partial update only — no other user fields are read or written.
    await userRef.set({
        isOnline: value.isOnline,
        lastSeen: firestore_1.Timestamp.fromMillis(value.lastSeen),
    }, { merge: true });
});
//# sourceMappingURL=on_presence_status_written.js.map