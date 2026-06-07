"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const presence_helpers_1 = require("../presence_helpers");
describe("isValidPresencePayload", () => {
    test("valid payload with isOnline true and numeric lastSeen passes", () => {
        expect((0, presence_helpers_1.isValidPresencePayload)({ isOnline: true, lastSeen: 1234567890 })).toBe(true);
    });
    test("valid payload with isOnline false and numeric lastSeen passes", () => {
        expect((0, presence_helpers_1.isValidPresencePayload)({ isOnline: false, lastSeen: 0 })).toBe(true);
    });
    test("missing isOnline is invalid", () => {
        expect((0, presence_helpers_1.isValidPresencePayload)({ lastSeen: 1234567890 })).toBe(false);
    });
    test("non-boolean isOnline is invalid", () => {
        expect((0, presence_helpers_1.isValidPresencePayload)({ isOnline: "true", lastSeen: 1234567890 })).toBe(false);
    });
    test("missing lastSeen is invalid", () => {
        expect((0, presence_helpers_1.isValidPresencePayload)({ isOnline: true })).toBe(false);
    });
    test("non-number lastSeen is invalid", () => {
        expect((0, presence_helpers_1.isValidPresencePayload)({ isOnline: true, lastSeen: "1234" })).toBe(false);
    });
    test("null is invalid", () => {
        expect((0, presence_helpers_1.isValidPresencePayload)(null)).toBe(false);
    });
    test("non-object value is invalid", () => {
        expect((0, presence_helpers_1.isValidPresencePayload)("presence")).toBe(false);
    });
    test("extra fields alongside valid fields are still valid", () => {
        expect((0, presence_helpers_1.isValidPresencePayload)({ isOnline: true, lastSeen: 100, extra: "ignored" })).toBe(true);
    });
});
//# sourceMappingURL=presence_helpers.test.js.map