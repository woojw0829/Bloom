import 'package:bloom/features/match/domain/models/swipe_action.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SwipeAction', () {
    test('enum has pass, like, and superLike values', () {
      expect(SwipeAction.values, contains(SwipeAction.pass));
      expect(SwipeAction.values, contains(SwipeAction.like));
      expect(SwipeAction.values, contains(SwipeAction.superLike));
    });

    test('has exactly three values', () {
      expect(SwipeAction.values.length, 3);
    });

    test('values are distinct', () {
      expect(SwipeAction.pass, isNot(SwipeAction.like));
      expect(SwipeAction.like, isNot(SwipeAction.superLike));
      expect(SwipeAction.pass, isNot(SwipeAction.superLike));
    });

    test('left swipe direction maps to pass', () {
      const direction = -1.0;
      const action = direction > 0 ? SwipeAction.like : SwipeAction.pass;
      expect(action, SwipeAction.pass);
    });

    test('right swipe direction maps to like', () {
      const direction = 1.0;
      const action = direction > 0 ? SwipeAction.like : SwipeAction.pass;
      expect(action, SwipeAction.like);
    });

    test('pass and like can be used in a switch without default', () {
      SwipeAction? result;
      for (final action in SwipeAction.values) {
        result = switch (action) {
          SwipeAction.pass => SwipeAction.pass,
          SwipeAction.like => SwipeAction.like,
          SwipeAction.superLike => SwipeAction.superLike,
        };
      }
      expect(result, SwipeAction.superLike);
    });
  });
}
