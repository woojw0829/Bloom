import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";

export type NotificationType = "like" | "match" | "message" | "verification";
export type NotificationReferenceType =
  | "like"
  | "match"
  | "message"
  | "verification_request";

export interface CreateNotificationParams {
  notificationId: string;
  userId: string;
  type: NotificationType;
  title: string;
  body: string;
  referenceId?: string;
  referenceType?: NotificationReferenceType;
}

// FCM error codes that indicate a stale or unregistered token.
// The notification document is still kept; only the push is silently skipped.
const UNREGISTERED_TOKEN_CODES = new Set([
  "messaging/registration-token-not-registered",
  "messaging/invalid-registration-token",
]);

// ── Pure helpers (testable without Firebase) ──────────────────────────────────

export function isValidNotificationType(
  type: unknown
): type is NotificationType {
  return (
    typeof type === "string" &&
    ["like", "match", "message", "verification"].includes(type)
  );
}

export function makeMatchNotificationId(
  matchId: string,
  userId: string
): string {
  return `match_${matchId}_${userId}`;
}

export function makeMessageNotificationId(
  matchId: string,
  messageId: string
): string {
  return `message_${matchId}_${messageId}`;
}

export function makeLikeNotificationId(likeId: string): string {
  return `like_${likeId}`;
}

/**
 * Builds the push body for a message notification.
 * Uses the sender's display name when available; falls back to generic text.
 */
export function buildMessageBody(senderName: string, isImage: boolean): string {
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
export function buildLikeBody(senderName: string): string {
  return senderName.trim() ? `${senderName} liked you.` : "Someone liked you.";
}

// ── Async Firebase helpers ────────────────────────────────────────────────────

/**
 * Fetches the sender's nickname from the public user document.
 * Returns empty string on any error or if the field is absent.
 * Never reads private subcollections or location.
 */
export async function getSenderNickname(userId: string): Promise<string> {
  const db = getFirestore();
  try {
    const userDoc = await db.collection("users").doc(userId).get();
    if (!userDoc.exists) return "";
    const nickname: unknown = userDoc.data()?.nickname;
    return typeof nickname === "string" ? nickname.trim() : "";
  } catch {
    return "";
  }
}

/**
 * Reads the FCM token from users/{userId}/private/notificationTokens.
 * Returns null if the document is missing, the token field is absent,
 * or the token is an empty string.
 * Never logs the token value.
 */
export async function getUserFcmToken(userId: string): Promise<string | null> {
  const db = getFirestore();
  try {
    const tokenDoc = await db
      .collection("users")
      .doc(userId)
      .collection("private")
      .doc("notificationTokens")
      .get();

    if (!tokenDoc.exists) return null;
    const token: unknown = tokenDoc.data()?.fcmToken;
    if (typeof token !== "string" || token.trim() === "") return null;
    return token;
  } catch {
    return null;
  }
}

/**
 * Reads notificationSettings.{type} from users/{userId}.
 * Defaults to true when the document, the settings map, or the specific field
 * is absent — ensures notifications are on by default for new users.
 */
export async function getNotificationSetting(
  userId: string,
  type: NotificationType
): Promise<boolean> {
  const db = getFirestore();
  try {
    const userDoc = await db.collection("users").doc(userId).get();
    if (!userDoc.exists) return true;

    const settings: unknown = userDoc.data()?.notificationSettings;
    if (settings == null || typeof settings !== "object") return true;

    const setting: unknown = (settings as Record<string, unknown>)[type];
    return typeof setting === "boolean" ? setting : true;
  } catch {
    return true;
  }
}

/**
 * Writes a notification document to notifications/{notificationId}.
 * Uses deterministic IDs so Cloud Function retries are idempotent.
 * createdAt is set server-side; clients cannot create notification documents.
 */
export async function createNotificationDoc(
  params: CreateNotificationParams
): Promise<void> {
  const db = getFirestore();

  const doc: Record<string, unknown> = {
    id: params.notificationId,
    userId: params.userId,
    type: params.type,
    title: params.title,
    body: params.body,
    read: false,
    createdAt: FieldValue.serverTimestamp(),
  };

  if (params.referenceId !== undefined) doc.referenceId = params.referenceId;
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
export async function sendPushNotification(
  token: string,
  title: string,
  body: string,
  data: Record<string, string>
): Promise<void> {
  try {
    await getMessaging().send({
      token,
      notification: { title, body },
      data,
    });
  } catch (err: unknown) {
    const code = (err as { code?: string })?.code ?? "";
    if (UNREGISTERED_TOKEN_CODES.has(code)) return; // Stale token — skip silently.
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
export async function createAndSendNotification(
  params: CreateNotificationParams
): Promise<void> {
  const enabled = await getNotificationSetting(params.userId, params.type);
  if (!enabled) return;

  await createNotificationDoc(params);

  const token = await getUserFcmToken(params.userId);
  if (!token) return;

  const data: Record<string, string> = {
    notificationId: params.notificationId,
    type: params.type,
  };
  if (params.referenceId) data.referenceId = params.referenceId;
  if (params.referenceType) data.referenceType = params.referenceType;

  await sendPushNotification(token, params.title, params.body, data);
}
