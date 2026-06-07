/**
 * Describes a valid RTDB status/{userId} document as written by the client.
 * Shape: { isOnline: boolean, lastSeen: number (epoch ms) }
 */
export interface PresencePayload {
  isOnline: boolean;
  lastSeen: number;
}

/**
 * Returns true if `value` is a well-formed RTDB presence payload.
 * Both fields must be present and of the correct type.
 */
export function isValidPresencePayload(value: unknown): value is PresencePayload {
  if (value === null || typeof value !== "object") return false;
  const obj = value as Record<string, unknown>;
  return (
    typeof obj["isOnline"] === "boolean" &&
    typeof obj["lastSeen"] === "number"
  );
}
