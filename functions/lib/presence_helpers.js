"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.isValidPresencePayload = isValidPresencePayload;
/**
 * Returns true if `value` is a well-formed RTDB presence payload.
 * Both fields must be present and of the correct type.
 */
function isValidPresencePayload(value) {
    if (value === null || typeof value !== "object")
        return false;
    const obj = value;
    return (typeof obj["isOnline"] === "boolean" &&
        typeof obj["lastSeen"] === "number");
}
//# sourceMappingURL=presence_helpers.js.map