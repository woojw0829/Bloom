import { initializeApp } from "firebase-admin/app";

initializeApp();

export { onLikeCreated } from "./on_like_created";
export { onPresenceStatusWritten } from "./on_presence_status_written";
export { onMatchCreatedNotification } from "./on_match_created_notification";
export { onMessageCreatedNotification } from "./on_message_created_notification";
export { revenueCatWebhook } from "./revenuecat_webhook";
