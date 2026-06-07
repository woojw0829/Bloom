"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onMessageCreatedNotification = exports.onMatchCreatedNotification = exports.onPresenceStatusWritten = exports.onLikeCreated = void 0;
const app_1 = require("firebase-admin/app");
(0, app_1.initializeApp)();
var on_like_created_1 = require("./on_like_created");
Object.defineProperty(exports, "onLikeCreated", { enumerable: true, get: function () { return on_like_created_1.onLikeCreated; } });
var on_presence_status_written_1 = require("./on_presence_status_written");
Object.defineProperty(exports, "onPresenceStatusWritten", { enumerable: true, get: function () { return on_presence_status_written_1.onPresenceStatusWritten; } });
var on_match_created_notification_1 = require("./on_match_created_notification");
Object.defineProperty(exports, "onMatchCreatedNotification", { enumerable: true, get: function () { return on_match_created_notification_1.onMatchCreatedNotification; } });
var on_message_created_notification_1 = require("./on_message_created_notification");
Object.defineProperty(exports, "onMessageCreatedNotification", { enumerable: true, get: function () { return on_message_created_notification_1.onMessageCreatedNotification; } });
//# sourceMappingURL=index.js.map