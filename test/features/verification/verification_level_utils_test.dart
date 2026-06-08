import 'package:bloom/features/verification/domain/utils/verification_level_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizedVerificationLevel', () {
    test('null returns none', () {
      expect(normalizedVerificationLevel(null), 'none');
    });

    test('empty string returns none', () {
      expect(normalizedVerificationLevel(''), 'none');
    });

    test('whitespace returns none', () {
      expect(normalizedVerificationLevel('   '), 'none');
    });

    test('photo returns photo', () {
      expect(normalizedVerificationLevel('photo'), 'photo');
    });

    test('government_id returns government_id', () {
      expect(normalizedVerificationLevel('government_id'), 'government_id');
    });

    test('unknown string returns none', () {
      expect(normalizedVerificationLevel('premium'), 'none');
    });
  });

  group('isVerifiedLevel', () {
    test('none returns false', () {
      expect(isVerifiedLevel('none'), false);
    });

    test('null returns false', () {
      expect(isVerifiedLevel(null), false);
    });

    test('unknown returns false', () {
      expect(isVerifiedLevel('admin'), false);
    });

    test('photo returns true', () {
      expect(isVerifiedLevel('photo'), true);
    });

    test('government_id returns true', () {
      expect(isVerifiedLevel('government_id'), true);
    });
  });

  group('isPhotoVerified', () {
    test('photo returns true', () {
      expect(isPhotoVerified('photo'), true);
    });

    test('government_id returns false', () {
      expect(isPhotoVerified('government_id'), false);
    });

    test('none returns false', () {
      expect(isPhotoVerified('none'), false);
    });

    test('null returns false', () {
      expect(isPhotoVerified(null), false);
    });
  });
}
