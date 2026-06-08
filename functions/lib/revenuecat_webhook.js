"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.revenueCatWebhook = void 0;
const https_1 = require("firebase-functions/v2/https");
const params_1 = require("firebase-functions/params");
const revenuecat_helpers_1 = require("./revenuecat_helpers");
// Secret is stored in Firebase Secret Manager.
// Set before deploying: firebase functions:secrets:set REVENUECAT_WEBHOOK_SECRET
// The value must match the Authorization header value configured in the
// RevenueCat Dashboard under Webhooks > Authorization.
const revenueCatWebhookSecret = (0, params_1.defineSecret)("REVENUECAT_WEBHOOK_SECRET");
/**
 * HTTPS endpoint that receives RevenueCat subscription webhook events.
 *
 * Security: verifies the Authorization header against REVENUECAT_WEBHOOK_SECRET
 * using a constant-time comparison before processing any payload. Rejects all
 * unauthenticated requests with 401.
 *
 * Task 13.1 scope: foundation only — acknowledges verified events without
 * writing subscription data. Subscription synchronisation is Task 13.2.
 */
exports.revenueCatWebhook = (0, https_1.onRequest)({ secrets: [revenueCatWebhookSecret] }, async (req, res) => {
    // Only accept POST.
    if (req.method !== "POST") {
        res.status(405).set("Allow", "POST").send("Method Not Allowed");
        return;
    }
    // Firebase Functions v2 exposes the raw request bytes as req.rawBody.
    const rawBody = req.rawBody?.toString("utf8");
    if (!rawBody) {
        res.status(400).send("Bad Request: empty body");
        return;
    }
    // ── Authorization verification ────────────────────────────────────────────
    // Must succeed before any payload data is inspected.
    const authorizationHeader = (0, revenuecat_helpers_1.extractRevenueCatAuthorization)(req.headers);
    if (!authorizationHeader) {
        res.status(401).send("Unauthorized: missing Authorization header");
        return;
    }
    const secret = revenueCatWebhookSecret.value();
    const isAuthorized = (0, revenuecat_helpers_1.verifyRevenueCatAuthorizationHeader)({
        authorizationHeader,
        expectedSecret: secret,
    });
    if (!isAuthorized) {
        res.status(401).send("Unauthorized: invalid Authorization header");
        return;
    }
    // ── Parse and acknowledge ─────────────────────────────────────────────────
    let event;
    try {
        event = (0, revenuecat_helpers_1.parseRevenueCatEvent)(rawBody);
    }
    catch {
        res.status(400).send("Bad Request: malformed JSON");
        return;
    }
    // Log only the event type — never log user identifiers, subscription
    // details, the Authorization header, or the raw body.
    const eventPayload = event["event"];
    if (typeof eventPayload === "object" &&
        eventPayload !== null &&
        !Array.isArray(eventPayload)) {
        const eventType = eventPayload["type"];
        if ((0, revenuecat_helpers_1.isRevenueCatWebhookEventType)(eventType)) {
            console.log("RevenueCat webhook event received:", eventType);
        }
    }
    // Task 13.1: foundation only — subscription writes deferred to Task 13.2.
    res.status(200).send("OK");
});
//# sourceMappingURL=revenuecat_webhook.js.map