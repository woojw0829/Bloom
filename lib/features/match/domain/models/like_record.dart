import 'swipe_action.dart';

/// The two like variants that can be written to Firestore.
enum LikeType {
  like,
  superLike;

  /// Stable Firestore string value.
  String get firestoreValue => switch (this) {
        LikeType.like => 'like',
        LikeType.superLike => 'super_like',
      };

  /// Maps a [SwipeAction] that carries like semantics to [LikeType].
  ///
  /// Throws [ArgumentError] for [SwipeAction.pass], which is not a like.
  static LikeType fromSwipeAction(SwipeAction action) => switch (action) {
        SwipeAction.like => LikeType.like,
        SwipeAction.superLike => LikeType.superLike,
        SwipeAction.pass =>
          throw ArgumentError('SwipeAction.pass is not a like action'),
      };
}

/// Returns the deterministic Firestore document ID for a like from [fromUserId]
/// to [toUserId].
///
/// Using a deterministic ID makes like writes idempotent — if the same action
/// fires twice (e.g., double-tap race), the second set() overwrites the first
/// document with identical data rather than creating a duplicate.
String makeLikeId(String fromUserId, String toUserId) =>
    '${fromUserId}_$toUserId';
