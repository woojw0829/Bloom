import 'package:bloom/features/presence/domain/models/presence_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PresenceStatus.fromRtdb', () {
    test('state is online when isOnline is true', () {
      final status = PresenceStatus.fromRtdb('user1', {'isOnline': true, 'lastSeen': 0});
      expect(status.state, PresenceState.online);
      expect(status.isOnline, isTrue);
    });

    test('state is offline when isOnline is false', () {
      final status = PresenceStatus.fromRtdb('user1', {'isOnline': false, 'lastSeen': 0});
      expect(status.state, PresenceState.offline);
      expect(status.isOnline, isFalse);
    });

    test('state is unknown when value is null', () {
      final status = PresenceStatus.fromRtdb('user1', null);
      expect(status.state, PresenceState.unknown);
    });

    test('state is unknown when value is not a map', () {
      final status = PresenceStatus.fromRtdb('user1', 'invalid');
      expect(status.state, PresenceState.unknown);
    });

    test('state is unknown for unexpected isOnline value', () {
      final status = PresenceStatus.fromRtdb('user1', {'isOnline': 'yes', 'lastSeen': 0});
      expect(status.state, PresenceState.unknown);
    });

    test('lastChanged is parsed from lastSeen timestamp', () {
      final epochMs = DateTime(2024, 6, 1).millisecondsSinceEpoch;
      final status = PresenceStatus.fromRtdb('user1', {'isOnline': true, 'lastSeen': epochMs});
      expect(status.lastChanged, isNotNull);
      expect(status.lastChanged!.millisecondsSinceEpoch, epochMs);
    });

    test('lastChanged is null when lastSeen is missing', () {
      final status = PresenceStatus.fromRtdb('user1', {'isOnline': true});
      expect(status.lastChanged, isNull);
    });

    test('userId is preserved', () {
      final status = PresenceStatus.fromRtdb('userXYZ', {'isOnline': true, 'lastSeen': 0});
      expect(status.userId, 'userXYZ');
    });
  });
}
