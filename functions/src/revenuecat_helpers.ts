import * as crypto from "crypto";

// ── Event types ───────────────────────────────────────────────────────────────

export const REVENUE_CAT_EVENT_TYPES = [
  "INITIAL_PURCHASE",
  "RENEWAL",
  "PRODUCT_CHANGE",
  "CANCELLATION",
  "UNCANCELLATION",
  "BILLING_ISSUE",
  "SUBSCRIBER_ALIAS",
  "EXPIRATION",
  "TRANSFER",
  "NON_SUBSCRIPTION_PURCHASE",
  "SUBSCRIPTION_PAUSED",
  "INVOICE_ISSUANCE",
] as const;

export type RevenueCatEventType = (typeof REVENUE_CAT_EVENT_TYPES)[number];

// ── Authorization extraction ──────────────────────────────────────────────────

/**
 * Extracts the Authorization header value from an incoming request.
 * Returns null when the header is absent or empty.
 */
export function extractRevenueCatAuthorization(
  headers: Record<string, string | string[] | undefined>
): string | null {
  const val = headers["authorization"];
  if (!val) return null;
  const auth = Array.isArray(val) ? val[0] : val;
  return auth || null;
}

// ── Authorization verification ────────────────────────────────────────────────

/**
 * Verifies that [authorizationHeader] exactly matches [expectedSecret] using a
 * constant-time comparison to prevent timing attacks.
 *
 * When buffer lengths differ a dummy comparison is performed against [expectedSecret]
 * to normalise execution time and reduce length-probing oracle opportunities.
 *
 * Returns false (never throws) for any invalid input.
 * Pure function — no Firebase SDK calls; fully testable without mocks.
 */
export function verifyRevenueCatAuthorizationHeader({
  authorizationHeader,
  expectedSecret,
}: {
  authorizationHeader: string;
  expectedSecret: string;
}): boolean {
  if (!authorizationHeader || !expectedSecret) return false;

  const a = Buffer.from(authorizationHeader, "utf8");
  const b = Buffer.from(expectedSecret, "utf8");

  if (a.length !== b.length) {
    // Normalise timing: perform a dummy same-length comparison before returning.
    try {
      crypto.timingSafeEqual(b, b);
    } catch {
      // ignore
    }
    return false;
  }

  try {
    return crypto.timingSafeEqual(a, b);
  } catch {
    return false;
  }
}

// ── Event parsing ─────────────────────────────────────────────────────────────

/**
 * Parses a raw JSON string into a RevenueCat event object.
 * Throws if the body is not valid JSON or not an object.
 */
export function parseRevenueCatEvent(body: string): Record<string, unknown> {
  const parsed: unknown = JSON.parse(body);
  if (typeof parsed !== "object" || parsed === null || Array.isArray(parsed)) {
    throw new Error("RevenueCat event body must be a JSON object.");
  }
  return parsed as Record<string, unknown>;
}

/**
 * Returns true when [value] is a known RevenueCat event type string.
 * Pure guard — does not validate the full event payload.
 */
export function isRevenueCatWebhookEventType(
  value: unknown
): value is RevenueCatEventType {
  return (REVENUE_CAT_EVENT_TYPES as readonly unknown[]).includes(value);
}
