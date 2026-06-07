import 'package:bloom/features/home/presentation/screens/home_shell.dart';
import 'package:bloom/features/notifications/presentation/widgets/notification_tile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── badgeLabelForCount ──────────────────────────────────────────────────────

  group('badgeLabelForCount', () {
    test('returns empty string for 0', () {
      expect(badgeLabelForCount(0), '');
    });

    test('returns empty string for negative count', () {
      expect(badgeLabelForCount(-1), '');
    });

    test('returns count as string for 1', () {
      expect(badgeLabelForCount(1), '1');
    });

    test('returns count as string for 99', () {
      expect(badgeLabelForCount(99), '99');
    });

    test('returns 99+ for 100', () {
      expect(badgeLabelForCount(100), '99+');
    });

    test('returns 99+ for large counts', () {
      expect(badgeLabelForCount(999), '99+');
    });
  });

  // ── formatNotificationTime ──────────────────────────────────────────────────

  group('formatNotificationTime', () {
    test('returns "now" for 0 minutes ago', () {
      final now = DateTime(2024, 6, 1, 12, 0, 0);
      expect(
        formatNotificationTime(now.subtract(const Duration(seconds: 30)),
            now: now),
        'now',
      );
    });

    test('returns minutes for less than 1 hour ago', () {
      final now = DateTime(2024, 6, 1, 12, 0, 0);
      expect(
        formatNotificationTime(now.subtract(const Duration(minutes: 15)),
            now: now),
        '15m',
      );
    });

    test('returns hours for less than 1 day ago', () {
      final now = DateTime(2024, 6, 1, 12, 0, 0);
      expect(
        formatNotificationTime(now.subtract(const Duration(hours: 3)), now: now),
        '3h',
      );
    });

    test('returns days for less than 7 days ago', () {
      final now = DateTime(2024, 6, 1, 12, 0, 0);
      expect(
        formatNotificationTime(now.subtract(const Duration(days: 4)), now: now),
        '4d',
      );
    });

    test('returns month and day for 7 or more days ago', () {
      final now = DateTime(2024, 6, 15, 12, 0, 0);
      final dt = DateTime(2024, 6, 1, 12, 0, 0);
      expect(formatNotificationTime(dt, now: now), 'Jun 1');
    });

    test('returns correct month abbreviation', () {
      final now = DateTime(2024, 12, 31, 12, 0, 0);
      final dt = DateTime(2024, 11, 1, 12, 0, 0);
      expect(formatNotificationTime(dt, now: now), 'Nov 1');
    });
  });
}
