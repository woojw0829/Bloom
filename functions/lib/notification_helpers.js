"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.isValidNotificationType = isValidNotificationType;
exports.makeMatchNotificationId = makeMatchNotificationId;
exports.makeMessageNotificationId = makeMessageNotificationId;
exports.makeLikeNotificationId = makeLikeNotificationId;
exports.buildMessageBody = buildMessageBody;
exports.buildLikeBody = buildLikeBody;
exports.getSenderNickname = getSenderNickname;
exports.getUserFcmToken = getUserFcmToken;
exports.getNotificationSetting = getNotificationSetting;
exports.createNotificationDoc = createNotificationDoc;
exports.sendPushNotification = sendPushNotification;
exports.createAndSendNotification = createAndSendNotification;
const firestore_1 = require("firebase-admin/firestore");
const messaging_1 = require("firebase-admin/messaging");
// FCM error codes that indicate a stale or unregistered token.
// The notification document is still kept; only the push is silently skipped.
const UNREGISTERED_TOKEN_CODES = new Set([
    "messaging/registration-token-not-registered",
    "messaging/invalid-registration-token",
]);
// ── Pure helpers (testable without Firebase) ──────────────────────────────────
function isValidNotificationType(type) {
    return (typeof type === "string" &&
        ["like", "match", "message", "verification"].includes(type));
}
function makeMatchNotificationId(matchId, userId) {
    return `match_${matchId}_${userId}`;
}
function makeMessageNotificationId(matchId, messageId) {
    return `message_${matchId}_${messageId}`;
}
function makeLikeNotificationId(likeId) {
    return `like_${likeId}`;
}
/**
 * Builds the push body for a message notification.
 * Uses the sender's display name when available; falls back to generic text.
 */
function buildMessageBody(senderName, isImage) {
    if (senderName.trim()) {
        return isImage
            ? `${senderName} sent you a photo.`
            : `${senderName} sent you a message.`;
    }
    return isImage ? "You received a photo." : "You have a new message.";
}
/**
 * Builds the push body for a like notification.
 * Uses the sender's display name when available; falls back to generic text.
 */
function buildLikeBody(senderName) {
    return senderName.trim() ? `${senderName} liked you.` : "Someone liked you.";
}
// ── Async Firebase helpers ────────────────────────────────────────────────────
/**
 * Fetches the sender's nickname from the public user document.
 * Returns empty string on any error or if the field is absent.
 * Never reads private subcollections or location.
 */
async function getSenderNickname(userId) {
    const db = (0, firestore_1.getFirestore)();
    try {
        const userDoc = await db.collection("users").doc(userId).get();
        if (!userDoc.exists)
            return "";
        const nickname = userDoc.data()?.nickname;
        return typeof nickname === "string" ? nickname.trim() : "";
    }
    catch {
        return "";
    }
}
/**
 * Reads the FCM token from users/{userId}/private/notificationTokens.
 * Returns null if the document is missing, the token field is absent,
 * or the token is an empty string.
 * Never logs the token value.
 */
async function getUserFcmToken(userId) {
    const db = (0, firestore_1.getFirestore)();
    try {
        const tokenDoc = await db
            .collection("users")
            .doc(userId)
            .collection("private")
            .doc("notificationTokens")
            .get();
        if (!tokenDoc.exists)
            return null;
        const token = tokenDoc.data()?.fcmToken;
        if (typeof token !== "string" || token.trim() === "")
            return null;
        return token;
    }
    catch {
        return null;
    }
}
/**
 * Reads notificationSettings.{type} from users/{userId}.
 * Defaults to true when the document, the settings map, or the specific field
 * is absent — ensures notifications are on by default for new users.
 */
async function getNotificationSetting(userId, type) {
    const db = (0, firestore_1.getFirestore)();
    try {
        const userDoc = await db.collection("users").doc(userId).get();
        if (!userDoc.exists)
            return true;
        const settings = userDoc.data()?.notificationSettings;
        if (settings == null || typeof settings !== "object")
            return true;
        const setting = settings[type];
        return typeof setting === "boolean" ? setting : true;
    }
    catch {
        return true;
    }
}
/**
 * Writes a notification document to notifications/{notificationId}.
 * Uses deterministic IDs so Cloud Function retries are idempotent.
 * createdAt is set server-side; clients cannot create notification documents.
 */
async function createNotificationDoc(params) {
    const db = (0, firestore_1.getFirestore)();
    const doc = {
        id: params.notificationId,
        userId: params.userId,
        type: params.type,
        title: params.title,
        body: params.body,
        read: false,
        createdAt: firestore_1.FieldValue.serverTimestamp(),
    };
    if (params.referenceId !== undefined)
        doc.referenceId = params.referenceId;
    if (params.referenceType !== undefined)
        doc.referenceType = params.referenceType;
    await db.collection("notifications").doc(params.notificationId).set(doc);
}
/**
 * Sends an FCM push notification.
 * Silently ignores stale / unregistered token errors so the notification
 * document already created is not rolled back.
 * All other FCM errors are re-thrown to the caller.
 */
async function sendPushNotification(token, title, body, data) {
    try {
        await (0, messaging_1.getMessaging)().send({
            token,
            notification: { title, body },
            data,
        });
    }
    catch (err) {
        const code = err?.code ?? "";
        if (UNREGISTERED_TOKEN_CODES.has(code))
            return; // Stale token — skip silently.
        throw err;
    }
}
/**
 * Checks the user's notification setting, creates the Firestore document,
 * fetches the FCM token, and sends the push notification.
 *
 * If the setting is disabled: does nothing (no doc, no push).
 * If the token is missing: creates doc only, skips push.
 * If FCM send fails with a stale token: keeps the doc, ignores the error.
 */
async function createAndSendNotification(params) {
    const enabled = await getNotificationSetting(params.userId, params.type);
    if (!enabled)
        return;
    await createNotificationDoc(params);
    const token = await getUserFcmToken(params.userId);
    if (!token)
        return;
    const data = {
        notificationId: params.notificationId,
        type: params.type,
    };
    if (params.referenceId)
        data.referenceId = params.referenceId;
    if (params.referenceType)
        data.referenceType = params.referenceType;
    await sendPushNotification(token, params.title, params.body, data);
}
//# sourceMappingURL=notification_helpers.js.map