import { onRequest } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";

import {
  extractRevenueCatAuthorization,
  verifyRevenueCatAuthorizationHeader,
  parseRevenueCatEvent,
  isRevenueCatWebhookEventType,
} from "./revenuecat_helpers";

// Secret is stored in Firebase Secret Manager.
// Set before deploying: firebase functions:secrets:set REVENUECAT_WEBHOOK_SECRET
// The value must match the Authorization header value configured in the
// RevenueCat Dashboard under Webhooks > Authorization.
const revenueCatWebhookSecret = defineSecret("REVENUECAT_WEBHOOK_SECRET");

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
export const revenueCatWebhook = onRequest(
  { secrets: [revenueCatWebhookSecret] },
  async (req, res) => {
    // Only accept POST.
    if (req.method !== "POST") {
      res.status(405).set("Allow", "POST").send("Method Not Allowed");
      return;
    }

    // Firebase Functions v2 exposes the raw request bytes as req.rawBody.
    const rawBody = (req as unknown as { rawBody?: Buffer }).rawBody?.toString("utf8");
    if (!rawBody) {
      res.status(400).send("Bad Request: empty body");
      return;
    }

    // ── Authorization verification ────────────────────────────────────────────
    // Must succeed before any payload data is inspected.

    const authorizationHeader = extractRevenueCatAuthorization(
      req.headers as Record<string, string | string[] | undefined>
    );
    if (!authorizationHeader) {
      res.status(401).send("Unauthorized: missing Authorization header");
      return;
    }

    const secret = revenueCatWebhookSecret.value();
    const isAuthorized = verifyRevenueCatAuthorizationHeader({
      authorizationHeader,
      expectedSecret: secret,
    });

    if (!isAuthorized) {
      res.status(401).send("Unauthorized: invalid Authorization header");
      return;
    }

    // ── Parse and acknowledge ─────────────────────────────────────────────────

    let event: Record<string, unknown>;
    try {
      event = parseRevenueCatEvent(rawBody);
    } catch {
      res.status(400).send("Bad Request: malformed JSON");
      return;
    }

    // Log only the event type — never log user identifiers, subscription
    // details, the Authorization header, or the raw body.
    const eventPayload = event["event"];
    if (
      typeof eventPayload === "object" &&
      eventPayload !== null &&
      !Array.isArray(eventPayload)
    ) {
      const eventType = (eventPayload as Record<string, unknown>)["type"];
      if (isRevenueCatWebhookEventType(eventType)) {
        console.log("RevenueCat webhook event received:", eventType);
      }
    }

    // Task 13.1: foundation only — subscription writes deferred to Task 13.2.
    res.status(200).send("OK");
  }
);
