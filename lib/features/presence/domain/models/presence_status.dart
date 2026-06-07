enum PresenceState { online, offline, unknown }

class PresenceStatus {
  const PresenceStatus({
    required this.userId,
    required this.state,
    this.lastChanged,
  });

  final String userId;
  final PresenceState state;
  final DateTime? lastChanged;

  bool get isOnline => state == PresenceState.online;

  // RTDB shape: { isOnline: boolean, lastSeen: number (epoch ms) }
  factory PresenceStatus.fromRtdb(String userId, Object? value) {
    if (value == null || value is! Map) {
      return PresenceStatus(userId: userId, state: PresenceState.unknown);
    }
    final map = Map<Object?, Object?>.from(value);
    final rawOnline = map['isOnline'];
    final state = rawOnline == true
        ? PresenceState.online
        : rawOnline == false
            ? PresenceState.offline
            : PresenceState.unknown;
    final rawLastSeen = map['lastSeen'];
    final lastChanged = rawLastSeen is int
        ? DateTime.fromMillisecondsSinceEpoch(rawLastSeen)
        : null;
    return PresenceStatus(
      userId: userId,
      state: state,
      lastChanged: lastChanged,
    );
  }
}
